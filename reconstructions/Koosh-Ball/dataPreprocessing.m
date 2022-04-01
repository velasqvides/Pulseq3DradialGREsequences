
clc, clearvars,
% 0. Parameters.
load('info4Reco'); % load a struct with info required for reconstruction
Nx = info4Reco.Nx; %radial base resolution
readoutOversampling = info4Reco.readoutOversampling; % 1x or 2x
nSpokes = info4Reco.nSpokes;
nPreScans = info4Reco.nPreScans;

nPreScansPerPlane = nPreScans / 3;
readoutSamples = Nx * readoutOversampling;
TotalNspokes = nSpokes + nPreScans;
nCoils = 32;
nFinalCoils = 12;

% 1. Read raw data, using the twixread bart command.
rawData = ...
     bart(sprintf('twixread -x%i -r%i -v1 -c%i -n%i -A -a%i',...
     readoutSamples,TotalNspokes,nCoils,TotalNspokes,TotalNspokes),...
     'meas_MID101_Full3DRadialSequence_100_FID94537.dat');
 
% 2. Coil compression         
rawData = bart(sprintf('cc -p%i -A -S',nFinalCoils), rawData); % -S singular value decomposition method

% 3. Divide pre-scan data and scan data and save them in a .cfl file
 preScanData(1,:,:,:,1) = rawData(1,:,1:nPreScansPerPlane,:);
 preScanData(1,:,:,:,2) = rawData(1,:,nPreScansPerPlane+1:2*nPreScansPerPlane,:);
 preScanData(1,:,:,:,3) = rawData(1,:,2*nPreScansPerPlane+1:3*nPreScansPerPlane,:);
 scanData = rawData(1, :, 3*nPreScansPerPlane+1:end, :);


% 3. Save the raw data in a .cfl file (or .mat file).
writecfl('preScanData', preScanData);
writecfl('scanData', scanData);
clear rawdata;
