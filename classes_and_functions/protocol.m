classdef protocol < handle
    %PROTOCOL Verify and make changes to the input parameter
    %   
    
    properties
        FOV (1,1) double {mustBeNumeric, mustBePositive}=256e-3
        nSamples (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=256
        nSpokes (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=256
        bandwidthPerPixel (1,1) double {mustBeNumeric, mustBePositive}=1628
        readoutOversampling (1,1) {mustBeMember(readoutOversampling, [1, 2])}=2
        nDummyScans (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}=450
        phaseDispersionReadout (1,1) double {mustBeNumeric, mustBeNonnegative}=2*pi
        RfSpoilingIncrement (1,1) double {mustBeNumeric, mustBeNonnegative}=117
        RfExcitation string {mustBeMember(RfExcitation, {'selectiveSinc','nonSelective'})}='selectiveSinc'
        RfPulseDuration(1,1) double {mustBeNumeric, mustBePositive}=400e-6
        RfPulseApodization (1,1) double {mustBeMember(RfPulseApodization, [0, 0.46, 0.5])}=0.5
        timeBwProduct (1,1) double {mustBeNumeric, mustBePositive}=2
        maxGradient  (1,1) double {mustBeGreaterThan(maxGradient,0), mustBeLessThan(maxGradient,73)}=50
        maxSlewRate  (1,1) double {mustBeGreaterThan(maxSlewRate,0), mustBeLessThan(maxSlewRate,201)}=150
        flipAngle (1,1) double {mustBeGreaterThan(flipAngle,0), mustBeLessThan(flipAngle,90)}=5
        TE (1,1) double {mustBeNumeric}=1.45e-3
        TR (1,1) double {mustBeNumeric}=3.04e-3
        systemLimits (1,1) struct
        T1 (1,1) double {mustBeNumeric, mustBePositive}=1284e-3
        error (1,1) double {mustBeNumeric, mustBePositive}=0.10
    end
    
    properties(Hidden)    
    isValidated = false; 
    end
        
    properties(Hidden, Constant)
        nSamples_min = 64
        nSamples_max = 1024;
        FOV_min = 12.8e-3
        FOV_max = 500e-3;
        bandwidthPerPixel_min = 100
        bandwidthPerPixel_max = 2000;
        spatialResolution_max = 0.2e-3;
        TR_max = 100e-3 
        ADCrasterTime = 0.1e-6; % ADC raster time for Siemens machines 
    end
    
    properties(Dependent,Hidden)
        deltaKx
        readoutDuration
        spatialResolution        
        realBandwidthPerPixel % to distinguish it from the one given by the user
        dwellTime 
        readoutGradientFlatTime
        readoutGradientAmplitude
    end
    
    methods
        function deltaKx = get.deltaKx(obj)
            deltaKx = 1/obj.FOV;
        end
        
        function dwellTime = get.dwellTime(obj)
           samplingPeriod = obj.nSamples * obj.readoutOversampling * obj.bandwidthPerPixel;
           dwellTime =  obj.ADCrasterTime * round( 1 / (samplingPeriod) / obj.ADCrasterTime );
        end
        
        function readoutDuration = get.readoutDuration(obj)            
            readoutDuration = obj.dwellTime *(obj.nSamples * obj.readoutOversampling); 
        end
                
        function readoutGradientAmplitude = get.readoutGradientAmplitude(obj)
            % To keep a fixed spatial resolution and even when the sampling 
            % rate of the receiver is doubled, the gradients are unchanged
            readoutGradientAmplitude = obj.nSamples / (obj.FOV * obj.readoutDuration);
        end
        
        function spatialResolution = get.spatialResolution(obj)
            spatialResolution = obj.FOV / obj.nSamples;
        end
                        
        function realBandwidthPerPixel = get.realBandwidthPerPixel(obj)
            realBandwidthPerPixel = (1/obj.readoutDuration); 
        end
                        
        function readoutGradientFlatTime = get.readoutGradientFlatTime(obj)            
            % due to gradient raster time constraints, the flat time may not
            % be the same as the readoutDuration, but a bit larger.
            gradRasterTime = obj.systemLimits.gradRasterTime;
            readoutGradientFlatTime =...
                (gradRasterTime) * ceil( obj.readoutDuration / (gradRasterTime) );
        end
        
        function estimateNdummyScans(obj)
            flipAngleRad = obj.flipAngle * pi / 180;
            % Liang, Z. P., & Lauterbur, P. C. (2000). Principles of 
            % magnetic resonance imaging: a signal processing perspective. 
            % p. 299, eq. (9.22).
            requieredDummyScans =  log( (obj.error)*(1 - exp(-obj.TR/obj.T1)) / (1 - cos(flipAngleRad)) ) /...
                log( cos(flipAngleRad) * exp(-obj.TR/obj.T1) );
            
            requieredDummyScans = round(requieredDummyScans);
            errorPercentage = obj.error * 100;
            
            if obj.nDummyScans == requieredDummyScans
                fprintf('**The number of dummy scans seems to be optimal.\n\n')
            else    
                fprintf(['**For the current TR and flip angle, the Suggested', ...
                    ' # of dummy scans to have a signal within\n'])
                fprintf('%4.2f%% of the steady-sate value is: %i. Current value: %i.\n\n', ...
                    errorPercentage, requieredDummyScans,obj.nDummyScans)
            end
        end
                        
        function validateResolution(obj)
            report = {sprintf('### Checking in-plane resolution ...\n')};
            
            % fix FOV
            if obj.FOV < obj.FOV_min
                report{end+1} = sprintf('**FOV =%6.3f is below lower limit %6.3f, FOV set to:%6.3f\n', ...
                    obj.FOV, obj.FOV_min, obj.FOV_min);
                obj.FOV = obj.FOV_min;
            elseif obj.FOV > obj.FOV_max
                report{end+1} = sprintf('**FOV =%6.3f is above upper limit %6.3f, FOV set to:%6.3f\n', ...
                    obj.FOV, obj.FOV_max, obj.FOV_max);
                obj.FOV = obj.FOV_max;            
            end
            obj.FOV = round(obj.FOV,3); %round to milimeters
            
            % fix nSamples
            toPrint = ' ';
            nSamples_old = obj.nSamples;
            if obj.nSamples < obj.nSamples_min
                toPrint = sprintf('**nSamples = %i is below lower limit %i, nSamples set to: %i\n', ...
                    nSamples_old, obj.nSamples_min, obj.nSamples_min);                               
                obj.nSamples = obj.nSamples_min;
            elseif obj.nSamples > obj.nSamples_max
                toPrint = sprintf('**nSamples = %i is above upper limit %i, nSamples set to: %i\n', ...
                    nSamples_old, obj.nSamples_max, obj.nSamples_max);                
                obj.nSamples = obj.nSamples_max;            
            end
            % fix nSamples further to comply with the max spatialResolution
            if obj.spatialResolution < obj.spatialResolution_max
                nSamples_new = floor(obj.FOV / obj.spatialResolution_max);
                toPrint = sprintf(['**nSamples = %i has to be changed to %i to keep the', ...
                    ' spatial resolution above the limit:%5.4f\n'], ...
                    nSamples_old, nSamples_new, obj.spatialResolution_max);
                obj.nSamples = nSamples_new;            
            end
            if ~strcmp(' ',toPrint)
            report{end+1} = toPrint;
            end
            
            % fix bandwidthPerPixel
            toPrint = ' ';
            BWpixel_old = obj.bandwidthPerPixel;
            if obj.bandwidthPerPixel < obj.bandwidthPerPixel_min
                toPrint = sprintf(['**bandwidthPerPixel = %4.0f Hz/pixel is below lower limit %4.0f Hz/pixel,'...
                    ' bandwidthPerPixel set to: %i Hz/pixel\n'],...
                    BWpixel_old, obj.bandwidthPerPixel_min, obj.bandwidthPerPixel_min);
                obj.bandwidthPerPixel = obj.bandwidthPerPixel_min;
            elseif obj.bandwidthPerPixel > obj.bandwidthPerPixel_max
                toPrint = sprintf(['**bandwidthPerPixel = %4.0f Hz/pixel is above upper limit %4.0f Hz/pixel,'...
                    'bandwidthPerPixel set to: %i Hz/pixel\n'],...
                    BWpixel_old, obj.bandwidthPerPixel_max, obj.bandwidthPerPixel_max);
                obj.bandwidthPerPixel = obj.bandwidthPerPixel_max;            
            end
            % fix bandwidthPerPixel further to comply wit the max gradient amplitude 
            maxGrad = obj.systemLimits.maxGrad;
            if obj.readoutGradientAmplitude > maxGrad % maxGrad in Hertz
                approxDwellTime = 1/(maxGrad*obj.FOV*obj.readoutOversampling);
                % ceil is mandatory here to comply with both, ADCraster and
                % the calculaiton done above.
                dwellTime_new = obj.ADCrasterTime * ceil( approxDwellTime / obj.ADCrasterTime ); 
                BWpixel_new = 1/(dwellTime_new*obj.nSamples*obj.readoutOversampling);                
                text1 = sprintf('**bandwidthPerPixel = %4.2f Hz/pixel was changed to %4.2f Hz/pixel',...
                    obj.bandwidthPerPixel, BWpixel_new);
                text2 = sprintf('\n   to keep the maximum gradient amplitude below the limit:%6.3f mT/m\n',...
                    mr.convert(maxGrad,'Hz/m','mT/m'));                
                toPrint = append(text1,text2);
                 obj.bandwidthPerPixel = BWpixel_new;           
            end   
            if ~strcmp(' ',toPrint)
            report{end+1} = toPrint;
            end
            tolerance = 0.05;
            if abs(obj.bandwidthPerPixel - obj.realBandwidthPerPixel) > tolerance
                obj.bandwidthPerPixel = obj.realBandwidthPerPixel;
                report{end+1} = sprintf(['**Update: the exact bandwidthPerPixel (due to raster time'...
                    ' constraints) will be %4.2f Hz/pixel\n'],obj.realBandwidthPerPixel);
            end
            if size(report,2) == 1
                report{end+1} = sprintf('All in-plane resolution parameters accepted\n');
            end
            report{end+1} = sprintf('###...Done.\n\n');            
            fprintf([report{:}]);
        end % end of validate resolution
    end % end of methods
end % end of the class

