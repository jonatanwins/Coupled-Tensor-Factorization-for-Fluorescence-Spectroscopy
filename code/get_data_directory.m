function dataDir = get_data_directory()
    %% Get the proper directory relative to this file (app.m)
    thisFile = mfilename('fullpath'); % /Users/kjeks/development/simula_tensor/cp_simula/code/app
    thisDir  = fileparts(thisFile);          % .../cp_simula/code
    projectRoot = fileparts(thisDir);        % .../cp_simula
    dataDir     = fullfile(projectRoot, 'data'); % .../cp_simula/data