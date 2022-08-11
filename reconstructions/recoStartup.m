% set the paths for BART and the functions required for image reconstruction

% users have to change this path for BART
bartPath = '~/Documents/tools/bart';
run(fullfile(bartPath, 'startup.m'));
% radial_GRE_sequences reconstruction setup
radialPath = fullfile(pwd, 'functions');
addpath(genpath(radialPath));

clear radialPath bartPath;