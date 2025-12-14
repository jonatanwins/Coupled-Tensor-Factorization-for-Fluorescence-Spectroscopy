setup_paths();
rng(1) % set random seed

NUM_RUNS = 100;
tolerance = 0.0005; % difference in loss.

function [X, Y, Z] = get_data_full()

    %% Load data
    load("EEM_NMR_LCMS.mat", 'X', 'Y', 'Z');
    
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    Y_structure = Y;
    Y = Y_structure.data;
    Y = tensor(Y);

    Z_structure = Z;
    Z = Z_structure.data;
    Z = tensor(Z);

end

% I could not find documentation on cmtf_AOADMM, but follow the structure from https://github.com/AOADMM-DataFusionFramework/Matlab-Code/blob/master/example_script3_matrix_CP_partialcoupling_nonneg.m
function decomp(NUM_RUNS, tolerance)
    %% Decompose X,Y,Z with coupling on mode 1 using CMTF-AO-ADMM algorithm to fit PARAFAC2 model
    [X, Y, Z] = get_data_full();

    % We choose to set missing values in X to zero, as AO-ADMM requires no NaNs in data tensors
    X_array = double(X);
    X_array(isnan(X_array)) = 0;
    X = tensor(X_array);
    % Y and Z are fully observed, only X has missing values

    % Create model object Q for AOADMM-DataFusionFramework (called Z in script_test_AOADMM tPARAFAC2)
    Q.object{1} = X;
    Q.object{2} = Y;
    Q.object{3} = Z;


    %% Metadata
    sizes_all_modes = {28, 251, 21, 28, 13324, 8, 28, 168};
    modes  = {[1 2 3], [4 5 6],[7 8]};
    
    
    %% Specify the decomposition type for X, Y, Z
    model{1} = 'CP';
    model{2} = 'CP';
    model{3} = 'CP';

    %% Coupling
    % which modes are coupled, coupled modes get the same number (0: uncoupled)
    coupling.lin_coupled_modes = [1 0 0 1 0 0 1 0]; % Mode 1, 4 and 7 represent the same mixtures
    lambdas_data = {[1 1 1], [1 1 1 1 1], [1 1 1 1 1]}; % length of each array specifies the number of components in each dataset
 
    % for each coupling number in the array lin_coupled_modes, set the coupling type: 0 exact coupling, 1: HC=Delta, 2: CH=Delta, 3: C=HDelta, 4: C=DeltaH
    coupling.coupling_type = 4; % 4: C = Delta H, where C is the coupled factor matrix, Delta is the underlying common factor matrix for mode 1 (a total of 6 components), H is the coupling selection matrix (0s and 1s). See case 3b of https://arxiv.org/abs/1506.04209
    coupling.coupl_trafo_matrices = cell(8,1); % cell array with coupling transformation matrices for each mode (if any, otherwise keep empty)
    
    % Here we describe how each coupled mode is linked to the underlying common factor matrix \Delta.
    % We are informed there are a total of 6 components, three visible in all three datasets, one only in Y and Z, and one only in Y and one only in Z.
    coupling.coupl_trafo_matrices{1} = [eye(3,3); zeros(3,3)];
    coupling.coupl_trafo_matrices{4} = [eye(5,5); 0, 0, 0, 0, 0];
    coupling.coupl_trafo_matrices{7} = [1, 0, 0, 0, 0; 
                                        0, 1, 0, 0, 0; 
                                        0, 0, 1, 0, 0;
                                        0, 0, 0, 1, 0; 
                                        0, 0, 0, 0, 0; 
                                        0, 0, 0, 0, 1];

    %% Loss functions
    loss_function{1} = 'Frobenius';
    loss_function{2} = 'Frobenius';
    loss_function{3} = 'Frobenius';

    
    %% Initialization options
    % function handle of distribution of data within each factor matrix /or Delta if linearly coupled, x,y are the size inputs 
    % coupled modes need to have same distribution. If not, just the first one will be considered
    distr_data = {@(x,y) rand(x,y), @(x,y) rand(x,y), @(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y)}; 
    
    %% check model
    check_data_input(sizes_all_modes, modes, lambdas_data, coupling, loss_function, model);

    init_options.lambdas_init = lambdas_data;
    init_options.nvecs = 0;
    init_options.distr = distr_data;
    init_options.normalize = 0; % whether to normalize factor matrices at initialization

    %% Constraints
    % All modes have non-negativity constraints
    constrained_modes = [1 1 1 1 1 1 1 1];

    constraints = cell(length(constrained_modes), 1);
    constraints{1} = {'non-negativity'};
    constraints{2} = {'non-negativity'};
    constraints{3} = {'non-negativity'};
    constraints{4} = {'non-negativity'};
    constraints{5} = {'non-negativity'};
    constraints{6} = {'non-negativity'};
    constraints{7} = {'non-negativity'};
    constraints{8} = {'non-negativity'};

    %% Set dataset weights (equal weights here)
    weights = [1/3, 1/3, 1/3]; 

    %% Define model object
    Q.loss_function = loss_function;
    Q.model = model;
    Q.modes = modes;
    Q.size  = sizes_all_modes;
    Q.coupling = coupling;
    Q.constrained_modes = constrained_modes;
    Q.constraints = constraints;
    Q.weights = weights;

    %% Options 
    options.Display ='no'; %  set to 'iter' or 'final' or 'no'
    options.DisplayIters = 10;
    options.MaxOuterIters = 4000;
    options.MaxInnerIters = 5;
    options.AbsFuncTol   = 1e-4;
    options.OuterRelTol = 1e-8;
    options.innerRelPrTol_coupl = 1e-3;
    options.innerRelPrTol_constr = 1e-3;
    options.innerRelDualTol_coupl = 1e-3;
    options.innerRelDualTol_constr = 1e-3;
    options.bsum = 0; % wether or not to use AO with BSUM regularization

    %% Initialize storage of results
    models = cell(1, NUM_RUNS);
    losses = zeros(1,NUM_RUNS);
    best_loss = 1e99;
    best_index = 0;
    best_Zhat = {};

    %% Fit NUM_RUNS models
    for i = 1:NUM_RUNS
        %% Random initialization
        init_fac = init_coupled_AOADMM_CMTF(Q, 'init_options', init_options);

        %% Run algorithm
        fprintf("Run model %d \n", i);
        
        % Zhat contains the normalized factor matrices (ref documentation cmtf_AOADMM.m)
        tic % tic starts a timer
        [Zhat, ~, ~, out] = cmtf_AOADMM(Q, 'alg_options', options, 'init', init_fac, 'init_options', init_options); 
        toc % toc stops the timer and prints elapsed time

        %% A guide as to what the loss should be:
            %% From cmtf_fun_AOADMM.m we have that these are the attributes of out:
                % out.f_tensors = f_tensors;
                % out.f_couplings = f_couplings;
                % out.f_constraints = f_constraints;
                % out.f_PAR2_couplings = f_PAR2_couplings;
                % out.exit_flag = exit_flag;
                % out.OuterIterations = iter-1;
                % out.func_val_conv = func_val;
                % out.func_coupl_conv = func_coupl;
                % out.func_constr_conv = func_constr;
                % out.func_PAR2_coupl = func_PAR2_coupl;
                % out.time_at_it = time_at_it;
            %% Furthermore we find in CMTF_AOADMM_func_eval, in the same file that
                % ftensors = sum_i w_i ||T_i-[|C_i,1,C_i,2,C_i,3|]||_F^2 + g_i,d(C_i,d) (for all regularizations g_i,d)
                % f_couplings = sum_i ||C_i-Delta_i||_F^2
                % f_constraints = sum_i ||C_i-Z_i||_F^2

        loss = out.f_tensors + out.f_couplings + out.f_constraints;
        %% Get the best model
        if loss < best_loss
            best_loss = loss;
            best_Zhat = Zhat;
            best_index = i;
        end
        losses(i) = loss;
        models{i} = Zhat;
    end

    %% Get other models close to best 
    tol = 1 + tolerance; % 1% tolerance
    close_model_indices = [];
    for i = 1:NUM_RUNS
        if losses(i) <= tol*best_loss
            close_model_indices = [close_model_indices i];
        end
    end

    %% Check uniqueness and calculate FMS
    num_close_models = length(close_model_indices);
    fms_X = zeros(num_close_models, 1);
    fms_Y = zeros(num_close_models, 1);
    fms_Z = zeros(num_close_models, 1);
    relative_losses = zeros(num_close_models, 1);

    for ii = 1:num_close_models
        i = close_model_indices(ii);
        relative_losses(ii) = losses(i) / best_loss;
        fms_X(ii) = score(best_Zhat{1}, models{i}{1});
        fms_Y(ii) = score(best_Zhat{2}, models{i}{2});
        fms_Z(ii) = score(best_Zhat{3}, models{i}{3});
        
        fprintf('Model %d: rel_loss=%.8f, FMS=[%.4f, %.4f, %.4f]\n', ...
                i, relative_losses(ii), fms_X(ii), fms_Y(ii), fms_Z(ii));
    end

    %% Save FMS scores to LaTeX-friendly file
    dataDir = get_data_directory();
    fms_file = fullfile(dataDir, 'fms_coupled.txt');
    fid = fopen(fms_file, 'w');
    fprintf(fid, '%% FMS for coupled models (close to optimal)\n');
    fprintf(fid, '%% Model & Relative Loss & FMS X & FMS Y & FMS Z \\\\\n');
    for ii = 1:num_close_models
        fprintf(fid, '%d & %.10f & %.4f & %.4f & %.4f \\\\\n', ...
                close_model_indices(ii), relative_losses(ii), ...
                fms_X(ii), fms_Y(ii), fms_Z(ii));
    end
    fclose(fid);
    
    fprintf('FMS saved to: %s\n', fms_file);

    %% Plotting
    plot_factors_XYZ(best_Zhat{1}, "EEM")
    plot_factors_XYZ(best_Zhat{2}, "3-way NMR")
    plot_factors_XYZ(best_Zhat{3}, "LCMS")
end


decomp(NUM_RUNS, tolerance);
    