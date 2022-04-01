
clc, clearvars,
% 0. Parameters.
load('info4Reco'); % load a struct variable called info4Reco
Nx = info4Reco.Nx;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
readoutSamples = Nx * readoutOversampling;

% STEP 1: load the pre-processed data and the corrected 2D trajectories
k = readcfl('scanData');
t = readcfl('trajectoryCorrected');

%% STEP 2: get the spokes requiered for reconstruction
nSpokesReco = nSpokes; % custom number of spokes to be used for reconstruction in case of golden angle angular ordering
assert(nSpokes >= nSpokesReco);
if nSpokes ~= nSpokesReco
    k = k(:,:,1:nSpokesReco,:,:);
    t = t(:,:,1:nSpokesReco,:);
end
t = bart(sprintf('scale %4.2f',1/readoutOversampling), t);  

%% STEP 3: partition-by-partition 2D reconstruction
tic
reconstructionMethod = 'pics'; % 'NUFFT', 'gridding', 'nlinv', 'pics'

switch reconstructionMethod
    
    case 'gridding' % density compensation + adjoint NUFFT
        dcf = calculate3DradialDCF(t); % squared Ram-Lak filter 
        image = bart(sprintf('nufft -a'), t, k.*dcf);
        mask1 = str2double(evalc("bart('bitmask 3')"));
        image = bart(sprintf('rss %i',mask1), image); % root of sum of squares along dim 3
        image = bart('resize -c 0 256 1 256 2 256', image);
        grid = flip(image,3); % flip the 3 dimension to have a similiar volume as the stack of stars sequence
    
    case 'NUFFT' % inverse NUFFT
        imageN = bart(sprintf('nufft -i'), t, k);
        mask1 = str2double(evalc("bart('bitmask 3')"));
        image = bart(sprintf('rss %i',mask1), imageN); % root of sum of squares along dim 3
        nufft = bart('resize -c 0 256 1 256 2 256', image);
    
    case 'pics' % parallel imaging + compressed sensing + density compensation as preconditioner (-p option)
        % convert the radial k-space data into cartesian k-space data
        % (apply adjoint NUFFT and then inverse FFT) to be able to use ESPIRit
        dcf = calculate2DradialDCFk(t); % normal Ram-Lak filter
        coil_img = bart (sprintf('nufft -i'), t, k); % inverse NUFFT
        % if desired, the following lines cna be uncommented to get the
        % NUFFT as the same time as pics:
%         mask1 = str2double(evalc("bart('bitmask 3')"));
%         image = bart(sprintf('rss %i',mask1), coil_img); % root of sum of squares along dim 3
%         nufft = bart('resize -c 0 256 1 256 2 256', image);
%         nufft = flip(nufft,3);
        mask4 = str2double(evalc("bart('bitmask 0 1 2')"));
        ksp = bart (sprintf('fft -u %i', mask4), coil_img); % FFT along dim 0, 1 and 2
        clear coil_img;
        sens = bart ('ecalib -W -m1', ksp); % Estimate coil sensitivities using ESPIRiT calibration.
        
        mask5 = str2double(evalc("bart('bitmask 0 1 2')"));
        writecfl('dcf_file',dcf); % this weights have to be passed to pics command in a .cfl file
        % -R W:%i:0:0.005 l1-wavelet rgularization and lambda=0.005, -i200 iterations,
        % -p dcf_file pattern of weights
        image = bart (sprintf('pics -S -R W:%i:0:0.013 -i200 -e -p dcf_file -t',mask5), t, k, sens); % pics reconstruction
        image = bart('resize -c 0 256 1 256 2 256', image);
        pics(:,:,:) = image; % save reconstructed partitions
        pics = flip(pics,3);   
        
end
toc


