
clearvars,
% 0. Parameters.
load(fullfile(pwd,'raw_data','info4Reco.mat'));
nSamples = info4Reco.nSamples;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
nPreScans = info4Reco.nPreScans;
nPreScansPerPlane = nPreScans / 3;
readoutSamples = nSamples * readoutOversampling;
thetaArray = info4Reco.thetaArray;
phiArray = info4Reco.phiArray;
thetaArrayPre = info4Reco.thetaArrayPre;
phiArrayPre = info4Reco.phiArrayPre;

% 1. Create the custom angles to be feed into the traj tool
% the polar angle is defined from x-y plane to z in BART, then we have to 
% feed our polar angle as (pi/2 - polar angle)
scanAngles = ((phiArray) +1i*(pi/2 - thetaArray))';
scanAnglesFilePath = fullfile(pwd, 'processed_data', 'scanAngles');
writecfl(scanAnglesFilePath, scanAngles);
XYfilePath = fullfile(pwd, 'processed_data', 'preScanAnglesXY');
writecfl(XYfilePath, phiArrayPre(1:nPreScansPerPlane)');
XZfilePath = fullfile(pwd, 'processed_data', 'preScanAnglesXZ');
writecfl(XZfilePath, pi/2 - ...
    thetaArrayPre(nPreScansPerPlane+1:2*nPreScansPerPlane)');
YZfilePath = fullfile(pwd, 'processed_data', 'preScanAnglesYZ');
writecfl(YZfilePath, pi/2 - ...
    thetaArrayPre(2*nPreScansPerPlane+1:3*nPreScansPerPlane)');

% 2. Load preprocessed data.
preScanData = readcfl(fullfile(pwd,'processed_data','preScanData'));

% 3. Create trajectories for the three planes of the pre-scans
tt(:,:,:,1) = bart(sprintf('traj -x%i -y%i -r -c -C %s',...
    readoutSamples,nPreScansPerPlane,XYfilePath));
tt(:,:,:,2) = bart(sprintf('traj -x%i -y%i -r -c -C %s',...
    readoutSamples,nPreScansPerPlane,XZfilePath));
tt(:,:,:,3) = bart(sprintf('traj -x%i -y%i -r -c -C %s',...
    readoutSamples,nPreScansPerPlane,YZfilePath));

% 4. Get global Sx, Sy, Sz, Sxy, Sxz, Syz using the pre-scan spokes
allDelays = ones(3,3,'double');
for indx = 1:3
    k = preScanData(:,:,:,:,indx);
    kACadapt = k(:,2:end,:,:);

    t = tt(:,:,:,indx);
    tACadapt = t(:,2:end,:);

    spokeShifts = evalc("bart('estdelay', tACadapt, kACadapt)");
    spokeShifts = split(spokeShifts,":");
    spokeShifts = arrayfun(@convertCharsToStrings, spokeShifts);
    spokeShifts = arrayfun(@str2num, spokeShifts);
    allDelays(indx,:) = spokeShifts.';
end
[Sx, Sy, Sz, Sxy, Sxz, Syz] = averageDelays(allDelays);

% 5. Create the corrected 3D trajectory
trajectoryCorrected = ...
    bart(sprintf(...
    ['traj -x%i -y%i -r -3 -c -C %s ...' ...
    '-O -q%8.6f:%8.6f:%8.6f -Q%8.6f:%8.6f:%8.6f'],...
    readoutSamples,nSpokes,scanAnglesFilePath,Sx,Sy,Sxy,Sz,Sxz,Syz));
clearvars -except allDelays trajectoryCorrected

% 6. Save corrected 3D trajectory
filePath = fullfile(pwd, 'processed_data', 'allDelays');
writecfl(filePath, allDelays); % optional
filePath = fullfile(pwd, 'processed_data', 'trajectoryCorrected');
writecfl(filePath, trajectoryCorrected);
