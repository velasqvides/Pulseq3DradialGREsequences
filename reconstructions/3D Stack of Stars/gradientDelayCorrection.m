
clc, clearvars,
% 0. Parameters.
load('info4Reco.mat'); % load a struct with info required for reconstruction
Nx = info4Reco.Nx;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
Nz = info4Reco.Nz;
spokeAngles = info4Reco.spokeAngles;
partitionRotationAngles = info4Reco.partitionRotationAngles;
readoutSamples = Nx * readoutOversampling;

% 1. Load the pre-processed data.
rawDataDecodedZ = readcfl('rawDataDecodedZ');

% 2. Partition-by-partition trajectory correction
% preallocate
allDelays = ones(Nx,3,'double');
trajectoryCorrected = zeros(3,readoutSamples,nSpokes,Nz,'double');% hm: init the array with the final size
for indx = 1 : Nz % 1-based index, first partition is 1
    % take the spokes from each partition
    k = rawDataDecodedZ(:,:,:,:,indx); 
    % take off the first measurement from all the spokes to make our
    % asymmetric spokes, symmetric around DC measurement
    kACadapt = k(:,2:end,:,:);    
    % Create a proper trajectory for each partition.
    % custom angles have to given in a column vector and in .cfl format
    customAngles = spokeAngles + partitionRotationAngles(indx);
    writecfl('customAngles',customAngles'); 
    % create a trajectory with -x readout samples, -y spokes and which is
    % -r radial, -c asymmetric and with -C custom angles
    t = bart(sprintf('traj -x%i -y%i -r -c -C customAngles',readoutSamples,nSpokes));
    % take off the first location for each trajectory spoke to make the
    % trajectory symmetric around zero coordinate
    tACadapt = t(:,2:end,:);
    % get the gradient delays (for the AC Adapative method the spokes and trajectories are requiered to be symmetric!)
    GradDelays = evalc("bart('estdelay', tACadapt, kACadapt)");
    startIndex = regexp(GradDelays,':'); % get the places in string with ':'
    Sx = str2double(GradDelays(1:startIndex(1) -1 )); % get everything before first ':'
    Sy = str2double(GradDelays(startIndex(1)+1:startIndex(2)-1)); % get everything after first ':' and before second ":"
    Sxy = str2double(GradDelays(startIndex(2)+1:end)); % get everything after second ':' 
    allDelays(indx,:) = [Sx Sy Sxy]; % save delays for each partition for further analysis
    % create a trajectory as before, but using -O and -q to correct the
    % transverse gradient errors
    tCorrected = bart(sprintf('traj -x%i -y%i -r -c -C customAngles -O -q%8.6f:%8.6f:%8.6f',...
                 readoutSamples,nSpokes,Sx,Sy,Sxy)); 
    % save the complete trajectory corrected        
    trajectoryCorrected(:,:,:,indx) = tCorrected;
    
end

clear k t kACadapt tACadapt tCorrected rawDataDecodedZ,

% 3. Save the corrected 2D trajectories for each partition in a .cfl file (or .mat file).
writecfl('trajectoryCorrected',trajectoryCorrected);
writecfl('allDelays',allDelays); % optional
