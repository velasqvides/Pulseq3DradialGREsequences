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
        
        estimateNdummyScans(obj) % method signature
        
        validateResolution(obj) % method signature
        
    end % end of methods
end % end of the class

