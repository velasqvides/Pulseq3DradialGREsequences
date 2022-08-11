
clearvars,
% 0. Parameters
load(fullfile(pwd,'raw_data','info4Reco.mat')); 
nSamples = info4Reco.nSamples; 
readoutOversampling = info4Reco.readoutOversampling; 
nSpokes = info4Reco.nSpokes; 
nPartitions = info4Reco.nPartitions; 
viewOrder = info4Reco.viewOrder; 
readoutSamples = nSamples * readoutOversampling;
totalNspokes = nSpokes * nPartitions;

% 1. Read raw data
rawDataName = 'meas_MID107_SoS_Slab_0_5_max225V_FID105552.dat';
filePath = fullfile(pwd,'raw_data',rawDataName);
rawData = bart(sprintf('twixread -x%i -r%i -z%i -A',...
               readoutSamples,totalNspokes,nPartitions),filePath);
 
% 2. Coil compression; if not required, set nFinalCoils = nCoils
nCoils = size(rawData,4);
nFinalCoils = 15;
assert(nCoils >= nFinalCoils);
if nFinalCoils ~= nCoils
    rawData = bart(sprintf('cc -p%i -A -S',nFinalCoils), rawData);
end

% 3. Rearrange the raw data.
p = rawData(1,1,1,1);
rearrangedRawData = ...
          zeros(1,readoutSamples,nSpokes,nFinalCoils,nPartitions,'like',p);
switch viewOrder
    case 'partitionsInInnerLoop'
        % spokes for a particular partition appears every Nz spokes
        for i=1:nPartitions
            index = i:nPartitions:totalNspokes;
            partitionTmp = rawData(:,:,index,:);
            rearrangedRawData(:,:,:,:,i) = partitionTmp;
        end
    case 'partitionsInOuterLoop'
        % spokes for a particular partition appears consecutively
        rearrangedRawData = ...
       reshape(rawData,[1,readoutSamples,nSpokes,nFinalCoils,nPartitions]);
end 
clearvars -except rearrangedRawData

% 4. Decode partitions performing an invese fft along partition dim
bitmask = str2double(evalc("bart('bitmask 4')"));
rawDataDecodedZ = bart(sprintf('fft -i -u %i',bitmask),rearrangedRawData);
clear rearrangedRawData;

% 5. Save decoded raw data 
filePath = fullfile(pwd,'processed_data','rawDataDecodedZ');
writecfl(filePath,rawDataDecodedZ);
clearvars;
