function [validNz, validSlabThickness, validRfPulseDuration, validTimeBWProduct ] = validateResolutionZ(inputs,sys)
%validateResolutionZ checks if the current values for Nz, slabThickness and
%transmittedBandwidth are allowed; if yes, it will further check if the maximum
%partition thickness is not exceeded, decreasing Nz if neccesary. Then it will check 
% if Then it will check 
%if the maximum gradient amplitude is not exceeded, decreasing the
%transmittedBandwidth if necessary.
%
% Inputs
%   - inputs: number of partitions Nz, slabThickness , timeBWProduct, RfPulseDuration.  
%   - sys: a struct with the system limits.
% Outputs
%   - feasible Nx, FOV and bandwidthPerPixel 
%   - feedback in command window with the correction of Nx, FOV and bandwidthPerPixel

fprintf('\n\n### Checking partition resolution now...\n')
pause(1);

Nz = inputs.Nz;
slabThickness = inputs.slabThickness;
timeBWProduct = inputs.timeBWProduct;
RfPulseDuration = inputs.RfPulseDuration;

%% These are arbitrary limits that need to be changed depending on the ...
% escaner used to take the measurements. At the moments these values are
% taken from the internet from a siemenes 7T commercial escaner.
minNz = 5; maxNz = 1024;
minSlabThickness = 10e-3; maxSlabThickness= 500e-3;
minBandwidth = 1500; maxBandwidth = 250e3;
minPartitionThickness = 0.2e-3; maxPartitionThickness = 20e-3;
minRfPulseDuration = 20e-6; maxRfPulseDuration = 12e-3;
minTimeBWProduct = 2; maxTimeBWProduct = 20; 

%% Check or fix Nz 
if Nz < minNz
    fprintf('\n**Current Nz = %i is below lower limit %i. Nz set to: %i\n',Nz, minNz, minNz)
    pause(1);
    validNz = minNz;    
elseif Nz > maxNz
    fprintf('\n**Current Nz = %i is above upper limit %i. Nz set to: %i\n',Nz, maxNz, maxNz)
    pause(1);
    validNz = maxNz;
else
    validNz = Nz;
end

%% Check or fix slabThickness
if slabThickness < minSlabThickness
    fprintf('\n**Current slabThickness = %2.1f mm is below lower limit %2.1f mm. slabThickness set to: %2.1f mm\n',slabThickness*1e3, minSlabThickness*1e3, minSlabThickness*1e3)
    pause(1);
    validSlabThickness = minSlabThickness;    
elseif slabThickness > maxSlabThickness
    fprintf('\n**Current slabThickness = %2.1f mm is above upper limit %2.1f mm. slabThickness set to: %2.1f mm\n',slabThickness*1e3, maxSlabThickness*1e3, maxSlabThickness*1e3)
    pause(1);
    validSlabThickness = maxSlabThickness;  
else
%     fprintf('\n## slabThickness accepted ##\n')
%     pause(1);
    validSlabThickness = slabThickness;
end

%% Check or fix timeBWProduct
if timeBWProduct < minTimeBWProduct
    fprintf('\n**Current time-bandwidth product = %i is below lower limit %i. timeBWProduct set to: %i\n',timeBWProduct, minTimeBWProduct, minTimeBWProduct)
    pause(1);
    validTimeBWProduct = minTimeBWProduct;    
elseif timeBWProduct > maxTimeBWProduct
    fprintf('\n**Current time-bandwidth product = %i is above upper limit %i. timeBWProduct set to: %i\n',timeBWProduct, maxTimeBWProduct, maxTimeBWProduct)
    pause(1);
    validTimeBWProduct = maxTimeBWProduct;
elseif mod(timeBWProduct,2) ~= 0
    TBW = 2 * ceil(timeBWProduct / 2);
    fprintf('\n**Current time-bandwidth product = %i is not a multiple of 2. timeBWProduct set to: %i\n',timeBWProduct, TBW)
    pause(1);
    validTimeBWProduct = TBW;
else
    validTimeBWProduct = timeBWProduct;
end

%% Check or fix RF pulse duration
if RfPulseDuration < minRfPulseDuration
    fprintf('\n**Current RF pulse duration = %3.1f us is below lower limit %3.1f us. RfPulseDuration set to: %3.1f us\n',RfPulseDuration*1e6, minRfPulseDuration*1e6, minRfPulseDuration*1e6)
    pause(1);
    validRfPulseDuration = minRfPulseDuration;    
elseif RfPulseDuration > maxRfPulseDuration
    fprintf('\n**Current RF pulse duration = %3.1f us is above upper limit %3.1f us. RfPulseDuration set to: %3.1f us\n',RfPulseDuration*1e6, maxRfPulseDuration*1e6, maxRfPulseDuration*1e6)
    pause(1);
    validRfPulseDuration = maxRfPulseDuration;  
else
    validRfPulseDuration = RfPulseDuration;
end

%% Further check and fix Nz to to be within partition thickness limits
if validSlabThickness / validNz < minPartitionThickness    
    br = round(validSlabThickness,3)/minPartitionThickness;
    fprintf('\n**Current Nz = %i has to be changed to %i to keep the partition thickness above the lower limit: %2.1f mm\n',validNz, br, minPartitionThickness*1e3)
    pause(1);
    validNz = br;
elseif validSlabThickness / validNz > maxPartitionThickness
    br = round(validSlabThickness,3)/maxPartitionThickness;
    fprintf('\n**Current Nz = %i has to be changed to %i to keep the partition thickness below the upper limit: %2.1f\n',validNz, br, maxPartitionThickness*1e3)
    pause(1);
    validNz = br;
else    
%     fprintf('\n## Nz accepted ##\n')
%     pause(1);
end    

%% Further check and fix the timeBWProduct for the bandwidth to be between the limits
if validTimeBWProduct / validRfPulseDuration < minBandwidth 
    TBW = 2 * ceil(minBandwidth * validRfPulseDuration / 2); % to be sure timeBWProduct is multiple of 2 
    fprintf('\n**Current timeBWProduct = %i has to be changed to %i',validTimeBWProduct, TBW)
    fprintf('\n  to keep the transmiter bandwidth above the lower limit: %2.1f KHz\n',minBandwidth*1e-3);
    pause(1);
    validTimeBWProduct = TBW;
elseif validTimeBWProduct / validRfPulseDuration > maxBandwidth 
    TBW = 2 * floor(maxBandwidth * validRfPulseDuration / 2); % to be sure timeBWProduct is multiple of 2
    fprintf('\n**Current timeBWProduct = %i has to be changed to %i',validTimeBWProduct, TBW)
    fprintf('\n  to keep the transmiter bandwidth below the upper limit: %3.0f KHz\n',maxBandwidth*1e-3);
    pause(1);
    validTimeBWProduct = TBW;
else    
%     fprintf('\n## timeBWProduct accepted ##\n')
%     pause(1);
end   

%% Further check and fix the the duration of the RF pulse ...
%  for the amplitude of Gslab to be below  maxGradientAmplitude
if validTimeBWProduct / (validSlabThickness * validRfPulseDuration) > sys.maxGrad % maxGrad in Hertz
    RFduration = round((validTimeBWProduct / (validSlabThickness * sys.maxGrad)),6) + 1e-6;% +1e-6 to be usre we dont exceed the maxGrad limit 
    fprintf('\n**Current RfPulseDuration = %3.1f us has to be changed to %3.1f us',validRfPulseDuration*1e6, RFduration*1e6)
    fprintf('\n  to keep the maximum gradient amplitude below the limit: %2.0f mT/m\n',mr.convert(sys.maxGrad,'Hz/m','mT/m'));
    pause(1);
    validRfPulseDuration = RFduration;
else    
%     fprintf('\n## RfPulseDuration accepted ##')
%     pause(1);
end    
    
end