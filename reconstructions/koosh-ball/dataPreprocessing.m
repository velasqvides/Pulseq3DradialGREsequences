
clearvars,
% 0. Parameters.
load(fullfile(pwd,'raw_data','info4Reco.mat')); 
nSamples = info4Reco.nSamples; 
readoutOversampling = info4Reco.readoutOversampling; 
nSpokes = info4Reco.nSpokes;
nPreScans = info4Reco.nPreScans;
nPreScansPerPlane = nPreScans / 3;
readoutSamples = nSamples * readoutOversampling;
TotalNspokes = nSpokes + nPreScans;

% 1. Read raw data
rawDataName = 'meas_MID103_Koosh_1_0_FID105548.dat';
filePath = fullfile(pwd,'raw_data',rawDataName);
rawData = bart(sprintf('twixread -x%i -r%i -A',...
    readoutSamples,TotalNspokes),filePath);

% 2. Coil compression; if not required, set nFinalCoils = nCoils
nCoils = size(rawData,4);
nFinalCoils = 15;
assert(nCoils >= nFinalCoils);
if nFinalCoils ~= nCoils
    rawData = bart(sprintf('cc -p%i -A -S',nFinalCoils), rawData);
end

% 3. Divide prescan and scan data 
preScanData(:,:,:,:,1) = rawData(:,:,1:nPreScansPerPlane,:);
preScanData(:,:,:,:,2) = rawData(:,:,nPreScansPerPlane+1:2*nPreScansPerPlane,:);
preScanData(:,:,:,:,3) = rawData(:,:,2*nPreScansPerPlane+1:3*nPreScansPerPlane,:);
scanData = rawData(:,:,3*nPreScansPerPlane+1:end,:);
clear rawData;

% 3. Save preprocessed data
filePath = fullfile(pwd, 'processed_data', 'preScanData');
writecfl(filePath, preScanData);
filePath = fullfile(pwd, 'processed_data', 'scanData');
writecfl(filePath, scanData);
clearvars;
