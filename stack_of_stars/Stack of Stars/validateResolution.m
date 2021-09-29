function [validNx, validFOV, validBandwidthPerPixel ] = validateResolution(Nx,FOV,bandwidthPerPixel,sys)
%validateResolution checks if the current values for Nx, FOV and
%bandwidthPerPixel are allowed; if yes, it will further check if the maximum
%resolution is not exceeded, decreasing Nx if neccesary. Then it will check 
%if the maximum gradient amplitude is not exceeded, decreasing the
%bandwidth per pixel if necessary.
%
% Inputs
%   - inputs: base resolution Nx, field
%   of view FOV, bandwidth per pixel.  
%   - sys: a struct with the system limits.
% Outputs
%   - feasible Nx, FOV and bandwidthPerPixel 
%   - feedback in command window with the correction of Nx, FOV and bandwidthPerPixel

fprintf('### Checking in-plane resolution now...\n')
pause(1);

% These are arbitrary limits than need to be changed depending on the
% escaner used to take the measurements. At the moments these values are
% taken from the internet from a siemenes 7t escaner.
minNx = 64; maxNx = 1024;
minFOV = 10e-3; maxFOV = 500e-3;
minBandwidthPerPixel = 100; maxBandwidthPerPixel = 2000;
maxSpatialResolution = 0.2e-3;

% Check or fix Nx 
if Nx < minNx
    fprintf('\n**Current Nx = %i is below lower limit %i. Nx set to:%i\n',Nx, minNx, minNx)
    pause(1);
    validNx = minNx;    
elseif Nx > maxNx
    fprintf('\n**Current Nx =%i is above upper limit %i. Nx set to:%i\n',Nx, maxNx, maxNx)
    pause(1);
    validNx = maxNx;
else
    validNx = Nx;
end

% Check or fix FOV
if FOV < minFOV
    fprintf('\n**Current FOV =%6.3f is below lower limit %6.3f. FOV set to:%6.3f\n',FOV, minFOV, minFOV)
    pause(1);
    validFOV = minFOV;    
elseif FOV > maxFOV
    fprintf('\n**Current FOV =%6.3f is above upper limit %6.3f. FOV set to:%6.3f\n',FOV, maxFOV, maxFOV)
    pause(1);
    validFOV = maxFOV;  
else
%     fprintf('\n## FOV accepted ##')
%     pause(1);
    validFOV = FOV;
end

% Check or fix bandwidthPerPixel
if bandwidthPerPixel < minBandwidthPerPixel
    fprintf('\n**Current bandwidthPerPixel =%6.3f is below lower limit %6.3f. bandwidthPerPixel set to:%6.3f\n',bandwidthPerPixel, minBandwidthPerPixel, minBandwidthPerPixel)
    pause(1);
    validBandwidthPerPixel = minBandwidthPerPixel;    
elseif bandwidthPerPixel > maxBandwidthPerPixel
    fprintf('\n**Current bandwidthPerPixel =%6.3f is above upper limit %6.3f. bandwidthPerPixel set to:%6.3f\n',bandwidthPerPixel, maxBandwidthPerPixel, maxBandwidthPerPixel)
    pause(1);
    validBandwidthPerPixel = maxBandwidthPerPixel;  
else
    validBandwidthPerPixel = bandwidthPerPixel;
end

% Further check and fix Nx to to be above maxSpatialResolution
if validFOV / validNx < maxSpatialResolution    
    br = round(validFOV,3)/maxSpatialResolution;
    fprintf('\n**Current Nx =%i has to be changed to %i to keep the spatial resolution above the limit:%5.4f\n',validNx, br, maxSpatialResolution)
    pause(1);
    validNx = br;
else    
%     fprintf('\n## Nx accepted ##')
%     pause(1);
end    

% Further check and fix bandwidthPerPixel for the GxAmplitude to be below
% maxGradientAmplitude
if validNx * validBandwidthPerPixel / validFOV > sys.maxGrad % maxGrad in Hertz
    BWpixel = floor(sys.maxGrad * round(validFOV,3) / validNx) - 1;% -1 to be usre we dont exceed the maxGrad limit 
    fprintf('\n**Current bandwidthPerPixel = %i has to be changed to %i',validBandwidthPerPixel, BWpixel)
    fprintf('\n  to keep the maximum gradient amplitude below the limit:%6.3f mT/m\n',mr.convert(sys.maxGrad,'Hz/m','mT/m'));
    pause(1);
    validBandwidthPerPixel = BWpixel;
else    
%     fprintf('\n## bandwidthPerPixel accepted ##')
%     pause(1);
end    
    
end
