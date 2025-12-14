% Run CP model with specified rank
function run_model(rank, NUM_RUNS, tolerance)

    dataDir = get_data_directory();
    [X, W] = get_data();

    models = cell(1, NUM_RUNS);
    losses = zeros(1, NUM_RUNS);
    best_loss = 1e99;
    best_index = 0;

    %% Fit models
    for i = 1:NUM_RUNS

        X0_init = create_guess('Data', X, 'Num_Factors', rank);
        [X0, ~, output] = cp_wopt(X.*W, W, rank, 'init', X0_init, 'lower', 0);
        
        if output.f < best_loss
            best_loss = output.f;
            best_index = i;
        end

        models{i} = X0;
        losses(i) = output.f;
    end

    %% Keep models with 1% more loss than the best model to demonstrate factor uniqueness
    tol = 1 + tolerance;
    close_model_indices = [];

    for i = 1:NUM_RUNS
        if losses(i) <= tol*best_loss
            close_model_indices = [close_model_indices i];
        end
    end

    %% Calculate and save FMS scores of close to optimal models
    num_close_models = length(close_model_indices);
    fms_scores = zeros(num_close_models, 1);
    
    for ii = 1:num_close_models
        model_idx = close_model_indices(ii);
        fms_scores(ii) = score(models{best_index}, models{model_idx});
    end
    
    % Save to file in LaTeX-friendly format
    fms_file = fullfile(dataDir, sprintf('fms_scores_rank_%d.txt', rank));
    fid = fopen(fms_file, 'w');
    fprintf(fid, '%% FMS scores for rank %d models (close to optimal)\n', rank);
    fprintf(fid, '%% Rank & Model & FMS Score \\\\\n');
    for ii = 1:num_close_models
        fprintf(fid, '%d & %d & %.4f \\\\\n', rank, close_model_indices(ii), fms_scores(ii));
    end
    fclose(fid);
    
    fprintf('FMS scores saved to: %s\n', fms_file);

    %% Plot factors for best model
    best_model = models{best_index};
    plot_factors_X(best_model.u); % .u is the cell array of factor matrices
end