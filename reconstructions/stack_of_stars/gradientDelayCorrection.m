
clearvars,
% 0. Parameters.
load(fullfile(pwd,'raw_data','info4Reco.mat')); 
nSamples = info4Reco.nSamples;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
nPartitions = info4Reco.nPartitions;
spokeAngles = info4Reco.spokeAngles;
partitionRotationAngles = info4Reco.partitionRotationAngles;
readoutSamples = nSamples * readoutOversampling ;

% 1. Load preprocessed data.
filePath = fullfile(pwd,'processed_data','rawDataDecodedZ');
rawDataDecodedZ = readcfl(filePath);

% 2. Partition-by-partition trajectory correction
allDelays = zeros(nPartitions,3,'double');
trajectoryCorrected = zeros(3,readoutSamples,nSpokes,nPartitions,'double');
for indx = 1 : nPartitions
    k = rawDataDecodedZ(:,:,:,:,indx);
    kACadapt = k(:,2:end,:,:);

    customAngles = spokeAngles + partitionRotationAngles(indx);
    writecfl('customAngles',customAngles');
    t = bart(sprintf('traj -x%i -y%i -r -c -C customAngles',...
        readoutSamples,nSpokes));
    tACadapt = t(:,2:end,:);

    spokeShifts = evalc("bart('estdelay', tACadapt, kACadapt)");
    spokeShifts = split(spokeShifts,":");
    spokeShifts = arrayfun(@convertCharsToStrings, spokeShifts);
    spokeShifts = arrayfun(@str2num, spokeShifts);
    Sx = spokeShifts(1,1);
    Sy = spokeShifts(2,1);
    Sxy = spokeShifts(3,1);
    allDelays(indx,:) = spokeShifts.';

    tCorrected = bart(sprintf(...
        'traj -x%i -y%i -r -c -C customAngles -O -q%8.6f:%8.6f:%8.6f',...
        readoutSamples,nSpokes,Sx,Sy,Sxy));
    trajectoryCorrected(:,:,:,indx) = tCorrected;
end
delete *.cfl *.hdr
clearvars -except allDelays trajectoryCorrected

% 3. Save corrected 2D trajectories 
filePath = fullfile(pwd,'processed_data','allDelays');
writecfl(filePath,allDelays); % optional
filePath = fullfile(pwd,'processed_data','trajectoryCorrected');
writecfl(filePath,trajectoryCorrected);
