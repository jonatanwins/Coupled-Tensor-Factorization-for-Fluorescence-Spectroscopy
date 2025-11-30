setup_paths();
rng(2025) % set random seed

MAX_RANK = 6;
NUM_RUNS = 30;

% Determine the right number of components for the CP model 
determine_rank(MAX_RANK, NUM_RUNS);

% Find the number of missing values in the data
[X, W] = get_data();
num_missing = sum(double(W(:)) == 0);
fprintf('Number of missing values in the data: %d\n', num_missing);


% Demonstrate the uniqueness of the factors by inspecting those returning the minimum error
tolerance = 0.01; % 1% tolerance for close to optimal models
for rank = 1:MAX_RANK
    disp("Running model for rank " + string(rank));
    run_model(rank, NUM_RUNS, tolerance);
end


