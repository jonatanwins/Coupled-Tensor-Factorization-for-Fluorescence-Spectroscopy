% To help MATLAB remember where the toolboxes are located
toolboxesdir = "/Users/kjeks/Documents/MATLAB/packages/";

% for part 1
addpath(toolboxesdir + "tensor_toolbox-v3.7/");
addpath(toolboxesdir + "tensor_toolbox-v3.7/libraries/lbfgsb/Matlab/");

% for part 2
addpath(toolboxesdir + "AOADMM-DataFusionFramework/");
addpath(toolboxesdir + 'AOADMM-DataFusionFramework/functions/');

addpath(toolboxesdir + 'proximity-operator/indicator');

disp("Paths set up successfully.");