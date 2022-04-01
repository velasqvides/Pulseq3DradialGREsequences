
clc, clearvars,
% 0. Parameters.
load('info4Reco'); % load a struct variable called info4Reco
Nx = info4Reco.Nx;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
nPreScans = info4Reco.nPreScans;

nPreScansPerPlane = nPreScans / 3;
readoutSamples = Nx * readoutOversampling;
 
% get the angles and create the custom angles to be feed in the traj tool
thetaArray = info4Reco.thetaArray;
phiArray = info4Reco.phiArray;
thetaArrayPre = info4Reco.thetaArrayPre;
phiArrayPre = info4Reco.phiArrayPre;
% this is my best guess about how the custom angles have to be feed into bart:
% the polar angle is defined from x-y plane to z in bart, then we have to feed
% our polar angle as (pi/2 -polar angle)
scanAngles = ((phiArray) +1i*(pi/2 - thetaArray))'; 
writecfl('scanAngles',scanAngles);
% preScanAngles = ((phiArrayPre) +1i*(pi/2 - thetaArrayPre))';
writecfl('preScanAnglesXY',phiArrayPre(1:nPreScansPerPlane)');
writecfl('preScanAnglesXZ',pi/2 - thetaArrayPre(nPreScansPerPlane+1:2*nPreScansPerPlane)');
writecfl('preScanAnglesYZ',pi/2 - thetaArrayPre(2*nPreScansPerPlane+1:3*nPreScansPerPlane)');

% 2. Load the pre-processed data.
preScanData = readcfl('preScanData');

% 3. Create trajectories for the three planes of the pre-scans
tt(:,:,:,1) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesXY',readoutSamples,nPreScansPerPlane));
tt(:,:,:,2) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesXZ',readoutSamples,nPreScansPerPlane));
tt(:,:,:,3) = bart(sprintf('traj -x%i -y%i -r -c -C preScanAnglesYZ',readoutSamples,nPreScansPerPlane));

% 4. Get global Sx, Sy, Sz, Sxy, Sxz, Syz using the pre-scan spokes
allDelays = ones(3,3,'double');
for indx = 1 : 3 % 1-based index, we used 3 planes    
    k = preScanData(:,:,:,:,indx); % take the spokes from first partition
    % take off the first measurement from all the spokes to make our
    % asymmetric spokes, symmetric around DC measurement
    kACadapt = k(:,2:end,:,:); 
    % 
    t = tt(:,:,:,indx);
    % take off the first location for each trajectory spoke to make the
    % trajectory symmetric around zero coordinate
    tACadapt = t(:,2:end,:);
    % get the gradient delays (for the AC Adapative method the spokes and trajectories are requiered to be symmetric)
    GradDelays = evalc("bart('estdelay', tACadapt, kACadapt)");
    startIndex = regexp(GradDelays,':'); % get the places in string with ':'
    Sx = str2double(GradDelays(1:startIndex(1) -1 )); % get everything before first ':'
    Sy = str2double(GradDelays(startIndex(1)+1:startIndex(2)-1)); % get everything after first ':' and before second ":"
    Sxy = str2double(GradDelays(startIndex(2)+1:end)); % get everything after second ':' 
    allDelays(indx,:) = [Sx Sy Sxy]; % save delays for each partition for further analysis        
end
% Sx = -18.8085; Sy = -19.2757; Sz = -19.2233;
% Sxy = -0.0376; Sxz = -0.2312; Syz = 0.0869;
Sx = (allDelays(1,1) + allDelays(2,1))/2; Sxy = allDelays(1,3);
Sy = (allDelays(1,2) + allDelays(3,1))/2; Sxz = allDelays(2,3);
Sz = (allDelays(2,2) + allDelays(3,2))/2; Syz = allDelays(3,3);

% 5. Create the corrected 3D trajectory
trajectoryCorrected = ...
    bart(sprintf('traj -x%i -y%i -r -3 -c -C scanAngles -O -q%8.6f:%8.6f:%8.6f -Q%8.6f:%8.6f:%8.6f',...
    readoutSamples,nSpokes,Sx,Sy,Sxy,Sz,Sxz,Syz));


% clear k t kACadapt tACadapt  preScanData scanData,

% 6. Save the corrected 2D trajectories for each partition in a .cfl file (or .mat file).
writecfl('trajectoryCorrected',trajectoryCorrected);
writecfl('allDelays',allDelays); % optional
