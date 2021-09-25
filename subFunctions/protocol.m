classdef protocol < handle
    %PROTOCOL Verify and make changes to the input parameter
    %   Detailed explanation goes here
    
    properties
        FOV (1,1) double {mustBeNumeric, mustBePositive}=256e-3
        nSamples (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=256
        nSpokes (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=256
        bandwidthPerPixel (1,1) double {mustBeNumeric, mustBePositive}=1667
        readoutOversampling (1,1) {mustBeMember(readoutOversampling, [1, 2])}=2
        nDummyScans (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}=468
        phaseDispersionReadout (1,1) double {mustBeNumeric, mustBeNonnegative}=2*pi
        RfSpoilingIncrement (1,1) double {mustBeNumeric, mustBeNonnegative}=117
        RfExcitation string {mustBeMember(RfExcitation, {'selectiveSinc','nonSelective'})}='selectiveSinc'
        RfPulseDuration(1,1) double {mustBeNumeric, mustBePositive}=400e-6
        RfPulseApodization (1,1) double {mustBeMember(RfPulseApodization, [0, 0.2, 0.46, 0.5])}=0.5
        timeBwProduct (1,1) double {mustBeNumeric, mustBePositive}=2
        maxGradient  (1,1) double {mustBeGreaterThan(maxGradient,0), mustBeLessThan(maxGradient,73)}=50
        maxSlewRate  (1,1) double {mustBeGreaterThan(maxSlewRate,0), mustBeLessThan(maxSlewRate,201)}=150
        flipAngle (1,1) double {mustBeGreaterThan(flipAngle,0), mustBeLessThan(flipAngle,90)}=5
        TE (1,1) double {mustBeNumeric}=2.21e-3
        TR (1,1) double {mustBeNumeric}=4.36e-3
        systemLimits (1,1) struct
        end
    
    properties(Constant,Hidden)
        nSamples_min = 64
        nSamples_max = 1024;
        FOV_min = 10e-3
        FOV_max = 500e-3;
        bandwidthPerPixel_min = 100
        bandwidthPerPixel_max = 2000;
        spatialResolution_max = 0.2e-3;
        TR_max = 100e-3
    end
    
    properties(Dependent,Hidden)
        deltaKx
        readoutDuration
        spatialResolution
        gradientAmplitude
    end
    
    methods
        function deltaKx = get.deltaKx(obj)
            deltaKx = 1/obj.FOV;
        end
        
        function readoutDuration = get.readoutDuration(obj)
            % when divided by 2, the result will still be multiple of the
            % gradient raster time
            gradRasterTime = obj.systemLimits.gradRasterTime;
            readoutDuration = (2*gradRasterTime) * ceil( (1/obj.bandwidthPerPixel) / (2*gradRasterTime) );
        end
        
        function spatialResolution = get.spatialResolution(obj)
            spatialResolution = obj.FOV / obj.nSamples;
        end
        
        function gradientAmplitude = get.gradientAmplitude(obj)
            gradientAmplitude = obj.nSamples * obj.bandwidthPerPixel / obj.FOV;
        end
        
        function estimateNdummyScans(obj,T1,error)
            flipAngleRad = obj.flipAngle * pi / 180;
            % eq. (9.22) of the book.
            requieredDummyScans =  log( (error)*(1 - exp(-obj.TR/T1)) / (1 - cos(flipAngleRad)) ) /...
                log( cos(flipAngleRad) * exp(-obj.TR/T1) );
            
            requieredDummyScans = round(requieredDummyScans);
            error = error * 100;
            
            if obj.nDummyScans == requieredDummyScans
                fprintf('**The number of dummy scans seem to be optimal.\n\n')
            else    
                fprintf('**For the current TR and flip angle, the Suggested # of dummy scans to have a signal within\n')
                fprintf('%4.2f%% of the steady-sate value is: %i. Current value: %i.\n\n',error, requieredDummyScans,obj.nDummyScans)
            end
        end
        
        function validateResolution(obj)
            report = {sprintf('### Checking in-plane resolution ...\n')};
            
            % fix FOV
            if obj.FOV < obj.FOV_min
                report{end+1} = sprintf('**FOV =%6.3f is below lower limit %6.3f. FOV set to:%6.3f\n',obj.FOV, obj.FOV_min, obj.FOV_min);
                obj.FOV = obj.FOV_min;
            elseif obj.FOV > obj.FOV_max
                report{end+1} = sprintf('**FOV =%6.3f is above upper limit %6.3f. FOV set to:%6.3f\n',obj.FOV, obj.FOV_max, obj.FOV_max);
                obj.FOV = obj.FOV_max;            
            end
                 
            % fix nSamples
            toPrint = ' ';
            nSamples_old = obj.nSamples;
            if obj.nSamples < obj.nSamples_min
                toPrint = sprintf('**nSamples = %i is below lower limit %i. nSamples set to:%i\n',nSamples_old, obj.nSamples_min, obj.nSamples_min);                               
                obj.nSamples = obj.nSamples_min;
            elseif obj.nSamples > obj.nSamples_max
                toPrint = sprintf('**nSamples =%i is above upper limit %i. nSamples set to:%i\n',nSamples_old, obj.nSamples_max, obj.nSamples_max);                
                obj.nSamples = obj.nSamples_max;            
            end
            % fix nSamples further to comply with the max spatialResolution
            if obj.spatialResolution < obj.spatialResolution_max
                nSamples_new = floor(obj.FOV / obj.spatialResolution_max);
                toPrint = sprintf('**nSamples =%i has to be changed to %i to keep the spatial resolution above the limit:%5.4f\n',nSamples_old, nSamples_new, obj.spatialResolution_max);
                obj.nSamples = nSamples_new;            
            end
            if ~strcmp(' ',toPrint)
            report{end+1} = toPrint;
            end
            
            % fix bandwidthPerPixel
            toPrint = ' ';
            BWpixel_old = obj.bandwidthPerPixel;
            if obj.bandwidthPerPixel < obj.bandwidthPerPixel_min
                toPrint = sprintf('**bandwidthPerPixel =%6.3f is below lower limit %6.3f. bandwidthPerPixel set to:%6.3f\n',BWpixel_old, obj.bandwidthPerPixel_min, obj.bandwidthPerPixel_min);
                obj.bandwidthPerPixel = obj.bandwidthPerPixel_min;
            elseif obj.bandwidthPerPixel > obj.bandwidthPerPixel_max
                toPrint = sprintf('**bandwidthPerPixel =%6.3f is above upper limit %6.3f. bandwidthPerPixel set to:%6.3f\n',BWpixel_old, obj.bandwidthPerPixel_max, obj.bandwidthPerPixel_max);
                obj.bandwidthPerPixel = obj.bandwidthPerPixel_max;            
            end
            % fix bandwidthPerPixel further to comply wit the max
            % gradient amplitude
            if obj.gradientAmplitude > obj.systemLimits.maxGrad % maxGrad in Hertz
                BWpixel_new = floor( obj.systemLimits.maxGrad * round(obj.FOV,3) / obj.nSamples );
                text1 = sprintf('**bandwidthPerPixel = %i was changed to %i',BWpixel_old, BWpixel_new);
                text2 = sprintf('\n   to keep the maximum gradient amplitude below the limit:%6.3f mT/m\n',mr.convert(obj.systemLimits.maxGrad,'Hz/m','mT/m'));                
                toPrint = append(text1,text2);
                obj.bandwidthPerPixel = BWpixel_new;            
            end
            if ~strcmp(' ',toPrint)
            report{end+1} = toPrint;
            end
            
            if size(report,2) == 1
                report{end+1} = sprintf('All in-plane resolution parameters accepted\n');
            end
            report{end+1} = sprintf('###...Done.\n\n');            
            fprintf([report{:}]);
        end
    end
end
