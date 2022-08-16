function createCorruptedKspace3D(info4Reco)
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
writecfl('scanAngles', scanAngles);

writecfl('preScanAnglesXY', phiArrayPre(1:nPreScansPerPlane)');
writecfl('preScanAnglesXZ', pi/2 - ...
    thetaArrayPre(nPreScansPerPlane+1:2*nPreScansPerPlane)');
writecfl('preScanAnglesYZ', pi/2 - ...
    thetaArrayPre(2*nPreScansPerPlane+1:3*nPreScansPerPlane)');

% 3. Create corrupted trajectories for the three planes of the pre-scans
tt(:,:,:,1) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesXY -q0.5:0.8:0.09 -O',...
    readoutSamples,nPreScansPerPlane));
tt(:,:,:,2) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesXZ -q0.5:0.2:0.05 -O',...
    readoutSamples,nPreScansPerPlane));
tt(:,:,:,3) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesYZ -q0.8:0.2:0.04 -O',...
    readoutSamples,nPreScansPerPlane));

% 4. create corrupted preScanData
preScanData(:,:,:,:,1) =  bart('phantom -s3 -k -t',tt(:,:,:,1)); 
preScanData(:,:,:,:,2) =  bart('phantom -s3 -k -t',tt(:,:,:,2)); 
preScanData(:,:,:,:,3) =  bart('phantom -s3 -k -t',tt(:,:,:,3));
writecfl(fullfile(pwd,'preScanData'),preScanData);

tCorrupted = bart(sprintf(...
    ['traj -x%i -y%i -r -3 -c -C scanAngles ...' ...
    '-O -q0.5:0.8:0.09 -Q0.2:0.05:0.04'],readoutSamples,nSpokes));
scanData =  bart('phantom -s2 -k -t',tCorrupted);
writecfl(fullfile(pwd,'scanData'),scanData);

end

