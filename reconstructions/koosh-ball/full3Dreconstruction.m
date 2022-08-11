
clearvars,
% 0. Parameters.
load(fullfile(pwd,'raw_data','info4Reco.mat'));
nSamples = info4Reco.nSamples;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;

% 1. Load preprocessed data and corrected 2D trajectory
filePath = fullfile(pwd,'processed_data','scanData');
k = readcfl(filePath);
filePath = fullfile(pwd,'processed_data','trajectoryCorrected');
t = readcfl(filePath);
% to account for oversampling factor of 2
t = bart(sprintf('scale %4.2f',1/readoutOversampling), t);

% 2. Get the spokes requiered for reconstruction
nSpokesReco = nSpokes;
assert(nSpokes >= nSpokesReco);
if nSpokes ~= nSpokesReco
    radialKsp = radialKsp(:,:,1:nSpokesReco,:,:);
    t = t(:,:,1:nSpokesReco,:);
end

% 4. 3D reconstruction
recoMethod = 'pics'; % 'NUFFT', 'gridding', 'nlinv', 'pics'

bitmask1 = str2double(evalc("bart('bitmask 3')"));
bitmask2 = str2double(evalc("bart('bitmask 0 1 2')"));
switch recoMethod
    case 'gridding' 
        dcf = densityCompRamLak3D(t);
        imageVolume = ...
                bart(sprintf(...
                'nufft -a -d%i:%i:%i',nSamples,nSamples,nSamples), ...
                t, k.*dcf);
        imageVolume = bart(sprintf('rss %i',bitmask1), imageVolume); 
    case 'NUFFT' 
        imageVolume = ...
                bart(sprintf(...
                'nufft -i -d%i:%i:%i',nSamples,nSamples,nSamples),t, k);
        mage = bart(sprintf('rss %i',bitmask1), imageVolume);
    case 'pics' 
        dcf = densityCompRamLak3D(t);
        coil_img = ...
                bart(sprintf(...
                'nufft -a -d%i:%i:%i',nSamples,nSamples,nSamples),...
                t, k.*dcf);
        k = bart(sprintf('fft -u %i', bitmask2), coil_img);
        sens = bart('ecalib  -m1 ', k);
        writecfl('dcf_file',dcf);
        imageVolume = bart(sprintf(...
            'pics -S -R W:%i:0:0.013 -i100 -e -p dcf_file -t',...
            bitmask2), t, k, sens);         
end
imageVolume = bart(sprintf(...
    'resize -c 0 %i 1 %i 2 %i',nSamples,nSamples,nSamples), imageVolume);
delete *.cfl *.hdr
clearvars -except imageVolume

% 5. save the reconstructed image volume
filePath = fullfile(pwd,'processed_data','imageVolume');
writecfl(filePath,imageVolume); 

