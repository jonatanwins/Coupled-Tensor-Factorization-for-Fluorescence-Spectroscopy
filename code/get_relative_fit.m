function output = get_relative_fit(X, X0)
    arguments
        X tensor
        X0 ktensor % Returned by cp_wopt
        % W tensor  % weight tensor, 0 for missing entries of X, 1 for known entries
    end

    mask = ~isnan(double(X)); % All entries which are not NaN

    % zero out missing entries inX and X0
    X_array = double(X);
    X_array(~mask) = 0;
    X = tensor(X_array);

    X0_array = double(tensor(X0));
    X0_array(~mask) = 0;
    X0 = tensor(X0_array); % reconstruct ktensor with

    % Compute 100 x (1 - ||X-X0||^2 / ||X||^2)
    numerator = (X-X0).*(X-X0);
    denominator = X.*X;

    numerator = double(numerator);
    denominator = double(denominator);

    output = 100*(1-(sum(numerator(:))./sum(denominator(:))));
end