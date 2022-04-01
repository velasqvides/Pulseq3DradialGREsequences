
clc, clearvars,
% 0. Parameters.
load('info4Reco.mat'); % load a struct with info required for reconstruction
Nx = info4Reco.Nx; % radial base resolution
readoutOversampling = info4Reco.readoutOversampling; % 1x or 2x
nSpokes = info4Reco.nSpokes; % number of spokes per partition
Nz = info4Reco.Nz; % number of partitions
viewOrder = info4Reco.viewOrder; % 'partitionsInInnerLoop' or 'partitionsInOuterLoop'
readoutSamples = Nx * readoutOversampling;
totalNspokes = nSpokes * Nz;

% 1. Read raw data, using the twixread bart command.
rawData = ...
     bart(sprintf('twixread -x%i -r%i -z%i -v1 -A -a%i',...
     readoutSamples,totalNspokes,Nz,totalNspokes),...
     'meas_MID103_3D_stackOfStars_100_FID94539.dat');
 
 nCoils = size(rawData,4);
 nFinalCoils = 15; % desired number of virtual channels after coil compression
 
% 2. Coil compression         
rawData = bart(sprintf('cc -p%i -A -S',nFinalCoils), rawData); %-S singular value decomposition method

% 3. Rearrange the raw data.
% preallocate a 5D array 
p = rawData(1,1,1,1);
rearrangedRawData = zeros(1,readoutSamples,nSpokes,nCoils,Nz,'like',p);
% depending on view order used in the data acquisition, we reshape dimension
% 2 (totalNspokes = nSpokes * Nz) into dimension 2 (nSpokes) and dimension 4 (Nz).
switch viewOrder
    case 'partitionsInInnerLoop' % spokes for a particular partition appears every Nz spokes
        for i=1:Nz
            index = i:Nz:totalNspokes;
            partitionTmp = rawData(:,:,index,:);
            rearrangedRawData(:,:,:,:,i) = partitionTmp;
        end
    case 'partitionsInOuterLoop' % spokes for a particular partition appears consecutively
        mask = str2double(evalc("bart('bitmask 2 4')"));
        rearrangedRawData = bart(sprintf('reshape %i %i %i',mask,nSpokes,Nz),rawData);
end
clear rawData partitionTmp; % hm: clear large-size variables

% 4. Decode the partitions performing an invese fft along dimension 4
mask2 = str2double(evalc("bart('bitmask 4')"));
rawDataDecodedZ = bart(sprintf('fft -i -u %i',mask2),rearrangedRawData);

clear rearrangedRawData;

% 5. Save the decoded raw data in a .cfl file (or .mat file).
writecfl('rawDataDecodedZ',rawDataDecodedZ);
