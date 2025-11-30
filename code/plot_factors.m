function plot_factors(data)
arguments
    data cell % Cell array of factor matrices from ktensor
end

    dataDir = get_data_directory();

    s = size(data); % shape (modes, rank)
    modes = s(1); 

    colors = [
        0.8500 0.3250 0.0980;  % red-orange
        0.9290 0.6940 0.1250;  % yellow
        0.4940 0.1840 0.5560;  % purple
        0.4660 0.6740 0.1880;  % green
        0.3010 0.7450 0.9330;  % blue
        0.6350 0.0780 0.1840;  % magenta
        0.0000 0.4470 0.7410   % cyan
    ];

    figure;

    for mode = 1:modes % (mixtures, emission, excitation)
        matrix = data{mode};
        s = size(matrix); % (n, rank)
        n = s(1);
        rank = s(2);

        subplot(3, 1, mode);

        hold on; 
        for r = 1:rank % for each of the components
            plot(1:n, matrix(:,r), "Color", colors(r,:), 'LineWidth', 1); % plot each of the
        end
        hold off;

        if mode == 1
            title('Mixtures');
            xlabel('Sample Number');
            ylabel('Relative concentration');
        end
        if mode == 2
            title('Emission');
            xlabel('Emission Wavelength');
            ylabel('Intensity');
        end
        if mode == 3
            title('Excitation');
            xlabel('Excitation Wavelength');
            ylabel('Intensity');
        end
    end

    % Adjust layout
    sgtitle("$Rank = " + string(rank) + "$", 'Interpreter', 'latex', 'FontSize', 12);

    filename = fullfile(dataDir, "figures", "factors_rank" + string(rank));

    fig = gcf;
    fig.Units = 'inches';
    % Size for 3 columns on A4: width ≈ 8.27" / 3 ≈ 2.6" per plot
    % Height for 2 rows: A4 height ≈ 11.69" / 2 ≈ 5.5" per plot
    fig.Position = [0 0 2.6 5.5];  % Width x Height for 3-column layout
    fig.PaperPositionMode = 'auto';

    % Increase font sizes for readability in small format
    set(findall(fig, '-property', 'FontSize'), 'FontSize', 9);
    
    % Tighten layout to maximize plot area
    for mode = 1:modes
        ax = subplot(3, 1, mode);
        ax.FontSize = 8;
        ax.TitleFontSizeMultiplier = 1.1;
        ax.LabelFontSizeMultiplier = 1.0;
    end

    % Export as vector PDF
    exportgraphics(fig, filename + ".pdf", 'ContentType', 'vector', 'BackgroundColor', 'white');
end