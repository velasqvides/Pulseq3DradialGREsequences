
% 0. Parameters.
load(fullfile(pwd,'raw_data','info4Reco.mat'));
nSamples = info4Reco.nSamples;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
nPartitions = info4Reco.nPartitions;

% 1. Load preprocessed data and corrected 2D trajectories
filePath = fullfile(pwd,'processed_data','rawDataDecodedZ');
rawDataDecodedZ = readcfl(filePath);
filePath = fullfile(pwd,'processed_data','trajectoryCorrected');
trajectoryCorrected = readcfl(filePath);
% to account for oversampling factor of 2
trajectoryCorrected = ...
   bart(sprintf('scale %4.2f',1/readoutOversampling), trajectoryCorrected);

% 2. Get the spokes requiered for reconstruction
nSpokesReco = nSpokes;
assert(nSpokes >= nSpokesReco);
if nSpokes ~= nSpokesReco
    rawDataDecodedZ = rawDataDecodedZ(:,:,1:nSpokesReco,:,:);
    trajectoryCorrected = trajectoryCorrected(:,:,1:nSpokesReco,:);
end

% 3. Partition-by-partition reconstruction
recoMethod = 'gridding'; % 'NUFFT', 'gridding', 'nlinv', 'pics'

imageVolume = ones(nSamples,nSamples,nPartitions,'double');  
bitmask1 = str2double(evalc("bart('bitmask 3')"));
bitmask2 = str2double(evalc("bart('bitmask 0 1')"));
for indx = 1:nPartitions 
    k = rawDataDecodedZ(:,:,:,:,indx);
    t = trajectoryCorrected(:,:,:,indx);
    switch recoMethod
        case 'gridding'
            dcf = densityCompRamLak2D(t);
            image = ...
                bart(sprintf(...
                'nufft -a -d%i:%i:1',nSamples,nSamples), t, k.*dcf);
            image = bart(sprintf('rss %i',bitmask1), image);
        case 'NUFFT'
            image = ...
                bart(sprintf(...
                'nufft -i -d%i:%i:1',nSamples,nSamples), t, k);
            image = bart(sprintf('rss %i',bitmask1), image);
        case 'pics'
            coil_img = ...
                bart(sprintf(...
                'nufft -i -d%i:%i:1',nSamples,nSamples), t, k);
            ksp = bart(sprintf('fft -u %i', bitmask2), coil_img);
            sens = bart('ecalib -W -m1 ', ksp);
            dcf = densityCompRamLak2D(t);
            writecfl('dcf_file',sqrt(dcf));
            image = ...
                bart(sprintf(...
                'pics -S -R W:%i:0:0.0075 -i100 -e -p dcf_file -t',...
                bitmask2),t, k, sens);
        case 'nlinv'
            image  = bart('nlinv -S -n -d1 -m1 -i10 -t', t, k);
    end % end switch
    image = bart(sprintf('resize -c 0 %i 1 %i',nSamples,nSamples), image);
    imageVolume(:,:,indx) = image;
end % end first for
delete *.cfl *.hdr
clear rawDataDecodedZ

% 4. save the reconstructed image volume
filePath = fullfile(pwd,'processed_data','imageVolume');
writecfl(filePath,imageVolume); 
