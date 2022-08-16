% test the stack-of-stars reconstruction pipeline using simulated data
currentFolder = cd;
addpath(genpath(fullfile(pwd,'info4Test')));
cd ('../reconstructions');
run("recoStartup.m");
cd(currentFolder);
load('info4RecoSOS.mat');
info4Reco = info4RecoSOS;
createCorruptedKspace2D(info4Reco);
filePath = '../reconstructions/stack_of_stars/raw_data/info4Reco';
save(filePath,'info4Reco');
rawDataDecodedZ = readcfl('rawDataDecodedZ');
filePath = ...
fullfile(...
'../reconstructions/stack_of_stars/processed_data/rawDataDecodedZ');
writecfl(filePath,rawDataDecodedZ);
cd('../reconstructions/stack_of_stars');
run("gradientDelayCorrection.m");
run("partitionByPartitionReconstruction.m");
cd(currentFolder);
figure, imagesc(imageVolume); 
axis equal; axis off; colormap('gray');
delete *.cfl *.hdr
clearvars -except currentFolder 



% test the koosh-ball reconstruction pipeline using simulated data
load('info4RecoKB.mat');
info4Reco = info4RecoKB;
createCorruptedKspace3D(info4Reco);
filePath = '../reconstructions/koosh_ball/raw_data/info4Reco';
save(filePath,'info4Reco');
preScanData = readcfl('preScanData');
filePath = ...
fullfile(...
'../reconstructions/koosh_ball/processed_data/preScanData');
writecfl(filePath,preScanData);
scanData = readcfl('scanData');
filePath = ...
fullfile(...
'../reconstructions/koosh_ball/processed_data/scanData');
writecfl(filePath,scanData);
cd('../reconstructions/koosh_ball');
run("gradientDelayCorrection.m");
run("full3Dreconstruction.m");
cd(currentFolder);
figure, imagesc(imageVolume(:,:,129)); 
axis equal; axis off; colormap('gray');
delete *.cfl *.hdr;

rmpath(genpath(fullfile(pwd,'info4Test')));
fprintf('### test passed ###');
clearvars; 


