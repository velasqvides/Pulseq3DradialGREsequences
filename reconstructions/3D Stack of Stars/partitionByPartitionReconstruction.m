%%
% clc, clearvars,
% 0. Parameters.
load('info4Reco.mat'); % load a struct with info required for reconstruction
Nx = info4Reco.Nx;
readoutOversampling = info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
Nz = info4Reco.Nz;

% 1. Load the pre-processed data and the corrected 2D trajectories
rawDataDecodedZ = readcfl('rawDataDecodedZ');
trajectoryCorrected = readcfl('trajectoryCorrected');
% to account for oversampling factor of 2
trajectoryCorrected = bart(sprintf('scale %4.2f',1/readoutOversampling), trajectoryCorrected);

% custom number of spokes to be used for reconstruction in case of golden
% angle angular orderings
nSpokesReco = nSpokes;
% 2. Get the spokes requiered for reconstruction
assert(nSpokes >= nSpokesReco);
if nSpokes ~= nSpokesReco
    rawDataDecodedZ = rawDataDecodedZ(:,:,1:nSpokesReco,:,:);
    trajectoryCorrected = trajectoryCorrected(:,:,1:nSpokesReco,:);
end

%% 3. Partition-by-partition 2D reconstruction
tic
reconstructionMethod = 'pics'; % 'NUFFT', 'gridding', 'nlinv', 'pics', 'enlive'

pics = ones(Nx,Nx,Nz,'double'); % preallocation
nufft = ones(Nx,Nx,Nz,'double'); % preallocation
grid = ones(Nx,Nx,Nz,'double'); % preallocation
nlinv = ones(Nx,Nx,Nz,'double'); % preallocation
enlinve = ones(Nx,Nx,Nz,'double'); % preallocation
mask1 = str2double(evalc("bart('bitmask 3')"));
mask4 = str2double(evalc("bart('bitmask 0 1')"));
mask5 = str2double(evalc("bart('bitmask 0 1')"));
for indx = 1:Nz % 1-based index,     
    k = rawDataDecodedZ(:,:,:,:,indx); 
    t = trajectoryCorrected(:,:,:,indx);        
     
    switch reconstructionMethod
        
        case 'gridding' % density compensation + adjoint NUFFT
            dcf = calculateRadialDCF(t); % density compensation function
            image = bart(sprintf('nufft -a'), t, k.*dcf);            
            image = bart(sprintf('rss %i',mask1), image); % root of sum of squares along dim 3
            image = bart('resize -c 0 256 1 256', image);
            grid(:,:,indx) = image; % save reconstructed partitions
            
            
        case 'NUFFT' % inverse NUFFT
            image = bart(sprintf('nufft -i'), t, k);            
            image = bart(sprintf('rss %i',mask1), image); % root of sum of squares along dim 3
            image = bart('resize -c 0 256 1 256', image);
            nufft(:,:,indx) = image; % save reconstructed partitions
            
        case 'pics' % parallel imaging + compressed sensing + density compensation as preconditioner (-p option)            
            dcf = calculateRadialDCF(t);
            % convert the radial k-space data into cartesian k-space data
            % (apply inverse NUFFT and then inverse FFT) to be able to use ESPIRit 
            coil_img = bart(sprintf('nufft -i'), t, k); % inverse NUFFT 
            % if desired, finish the NUFFT reocnstruction in the next
            % three lines, other case comment them
            image = bart(sprintf('rss %i',mask1), coil_img); % root of sum of squares along dim 3
            image = bart('resize -c 0 256 1 256', image);
            nufft(:,:,indx) = image; % NUFFT is save here to save time            
            % continue with sensitivity maps calculations
            ksp = bart (sprintf('fft -u %i', mask4), coil_img); % inverse FFT along dim 0 and 1           
            sens = bart ('ecalib -W -m1 ', ksp); % Estimate coil sensitivities using ESPIRiT calibration.
            
            writecfl('dcf_file',sqrt(dcf)); % the weights have to be passed to pics command in a .cfl file
            % pics reconstruction: -R W:%i:0:0.005 l1-wavelet regularization and lambda=0.005, 
            % -i100 iterations, -p dcf_file pattern of weights
            image = bart (sprintf('pics -S -R W:%i:0:0.0075 -i100 -e -p dcf_file -t',mask5), t, k, sens); 
            image = bart('resize -c 0 256 1 256', image);
            pics(:,:,indx) = image; % save reconstructed partitions

        case 'nlinv'
            % -n: non-cartesian flag, -d4: debuglevel, -m1: 1 ENLIVE map,
            % -i8: 8 iteartions
            image  = bart('nlinv -n -d1 -m1 -i10 -t', t, k);%added -a1000 based on tutorial
            image = bart('resize -c 0 256 1 256', image);
            nlinv(:,:,indx) = image; % save reconstructed partitions
            

            
        case 'enlive'
            for sft =[1.5]
                tOs = bart(sprintf('scale %8.6f',sft), t);
                ones1 = bart('ones 4 1 512 256 12');
                tmp0 = bart(sprintf('nufft -a'), tOs, ones1);
                psf = bart('fft -u 3', tmp0);
                for sf=[3.90625e-3]
                    psfReco = bart (sprintf('scale %8.6f',sf), psf);
                    ktmp0 = bart(sprintf('nufft -a'), tOs, k);
                    gk = bart('fft -u 3', ktmp0);
                    
                    image = bart('nlinv -n -d4 -m2  -i15 -p', psfReco, gk);
                    image = bart('resize -c 0 256 1 256', image);
                    enlinve(:,:,indx) = image; % save reconstructed partitions
                end
            end
            
    end         
end

toc


%% STEP 4: save the reconstructed image volume
% writecfl('Grid',grid);
% writecfl('NUFFT',nufft);


