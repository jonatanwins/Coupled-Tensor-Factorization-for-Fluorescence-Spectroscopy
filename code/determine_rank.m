% Read the data X of size 28 × 251 × 21 as third-order tensor containing fluorescence spectroscopy data with modes mixtures, emission wavelengths and excitation wavelengths from "EEM_NMR_LCMS.mat"
function determine_rank(MAX_RANK, NUM_RUNS)
    
    dataDir = get_data_directory();
    [X, W] = get_data();

    relative_fit_list = zeros(MAX_RANK,1); % for interpretability
    lowest_error_list = zeros(MAX_RANK,1); %
    loss_improvement_list = zeros(MAX_RANK,1); %

    for r = 1:MAX_RANK
        lowest_error = 1e99;
        relative_fit_of_best_model = 0;

        % Fit the rank r NUM_RUNS times and keep the best model
        for i = 1:NUM_RUNS
            % cell array of factor matrices U{1}, U{2}, U{3} initialized with uniform random values in [0,1], 
                % size(U{1}) = 28 x r, size(U{2}) = 251 x r, size(U{3}) = 21 x r
            X0_init = create_guess('Data', X, 'Num_Factors', r); 
            % uses lbfgsb on ||W * (X-K)||_F^2 with non-negativity constraint (lower bound 0) to fit CP model
            [X0, ~, output] = cp_wopt(X.*W, W, r, 'init', X0_init, 'lower', 0, 'opt', 'lbfgsb');
            
            if output.f < lowest_error % .f is the error for the computed decomposition X0
                lowest_error = output.f; 
                relative_fit_of_best_model = get_relative_fit(X, X0);
            end
        end

        % Store the best metrics for this rank
        lowest_error_list(r) = lowest_error;
        relative_fit_list(r) = relative_fit_of_best_model;
        
        % Calculate percentage improvement from previous rank
        if r == 1
            loss_improvement_list(r) = 0; % No previous rank to compare
        else
            previous_error = lowest_error_list(r-1);
            loss_improvement_list(r) = 100 * (previous_error - lowest_error) / previous_error;
        end

    end

    %% Save results to file

    % renaming variables for table
    rank = (1:MAX_RANK)';
    loss = lowest_error_list;
    relative_fit = relative_fit_list;
    improvement_percentage = loss_improvement_list;

    outFile = fullfile(dataDir, 'rank_results.txt');  % .../cp_simula/data/rank_results.txt
    T = table(rank, loss, relative_fit, improvement_percentage);
    writetable(T,  outFile);
    type(outFile);
end