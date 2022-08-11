% set the two matlab paths for the creation of sequences
% pulseq setup 
pulseqPath = '~/Documents/tools/pulseq/matlab';
addpath(genpath(pulseqPath));
% radial_GRE_sequences setup
radialPath = fullfile(pwd, 'classes_and_functions');
addpath(genpath(radialPath));

clear pulseqPath radialPath;