function plot_factors_XYZ(data, plot_name)
    s = size(data);
    dims = length(s);

     colors = [
        0.8500 0.3250 0.0980;  % red-orange
        0.9290 0.6940 0.1250;  % yellow
        0.4940 0.1840 0.5560;  % purple
        0.4660 0.6740 0.1880;  % green
        0.3010 0.7450 0.9330;  % blue
        0.6350 0.0780 0.1840;  % magenta
        0.0000 0.4470 0.7410   % cyan
    ];

    % Create a figure
    figure;

    for dim = 1:dims
        matrix = data{dim};
        s = size(matrix);
        n = s(1);
        rank = s(2);

        subplot(3, 1, dim);

        % start the y-axis at 0
        ylim([0 inf]);

        % add gridlines
        grid on;

        hold on;
        for r = 1:rank
            plot(1:n, matrix(:,r), "Color", colors(r,:), 'LineWidth', 1);
        end
        hold off;

        if dim == 1
            title('Mixtures Mode');
            xlabel('Sample ID');
        end
        if dim == 2 && plot_name == "EEM"
            title('Emission Mode');
            xlabel('Emission Wavelength');
        end
        if dim == 2 && plot_name == "3-way NMR"
            title('Chemical Shift Mode');
            xlabel('Chemical Shifts');
        end
        if dim == 2 && plot_name == "LCMS"
            title('Feature Mode');
            xlabel('Features');
        end
        if dim == 3 && plot_name == "EEM"
            title('Excitation Mode');
            xlabel('Excitation Wavelength');
        end
        if dim == 3 && plot_name == "3-way NMR"
            title('Gradient Level Mode');
            xlabel('Gradient Levels');
        end
    end

    % Adjust layout
    sgtitle(plot_name);

    folder_name = "figures_part_2";
    dataDir = get_data_directory();

    % Check if filestructure exists, create if not
    if ~exist(fullfile(dataDir, folder_name), 'dir')
        mkdir(fullfile(dataDir, folder_name));
    end

    filename = fullfile(dataDir, folder_name, plot_name);
    
    fig = gcf;
    fig.Units = 'inches';
    % Full page size for individual plots
    fig.Position = [0 0 8.27/3 11.69/2];  % A4 size (width x height)
    fig.PaperPositionMode = 'auto';

    % Increase font sizes for readability
    set(findall(fig, '-property', 'FontSize'), 'FontSize', 9);
    
    % Tighten layout to maximize plot area
    for dim = 1:dims
        ax = subplot(3, 1, dim);
        ax.FontSize = 8;
        ax.TitleFontSizeMultiplier = 1.1;
        ax.LabelFontSizeMultiplier = 1.0;
    end

    % Export as vector PDF
    exportgraphics(fig, filename + ".pdf", 'ContentType', 'vector', 'BackgroundColor', 'white');
    
end