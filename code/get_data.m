function [X, W] = get_data()
    %% Load data
    load('EEM_NMR_LCMS.mat', 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X); % from Tensor Toolbox

    %% Create weights
    mask = ~isnan(double(X)); % All entries which are not NaN
    W = tensor(double(mask)); % Weight tensor with 1 for known entries and 0 for missing entries
end