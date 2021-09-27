classdef kernel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        protocol (1,1) protocol
    end
    
    methods
        function obj = kernel(v)
            obj.protocol = v;
        end
        
        function [RF, Gz, GzReph] = createSlabSelectionEvents(obj)
            RfExcitation = obj.protocol.RfExcitation;
            flipAngle = obj.protocol.flipAngle;
            RfPulseDuration = obj.protocol.RfPulseDuration;
            slabThickness = obj.protocol.slabThickness;
            RfPulseApodization = obj.protocol.RfPulseApodization;
            timeBwProduct = obj.protocol.timeBwProduct;
            systemLimits = obj.protocol.systemLimits;
            
            switch RfExcitation
                case 'selectiveSinc'
                    [RF, Gz, GzReph] = mr.makeSincPulse(flipAngle*pi/180,'Duration',RfPulseDuration,...
                        'SliceThickness',slabThickness,'apodization',RfPulseApodization,...
                        'timeBwProduct',timeBwProduct,'system',systemLimits);
                    
                case 'nonSelective'
                    RF = mr.makeBlockPulse(flipAngle*pi/180,systemLimits,'Duration',RfPulseDuration);
                    Gz = []; GzReph = [];
            end
            
        end
        
        function [Gx, GxPre, ADC] = createReadoutEvents(obj)
            nSamples = obj.protocol.nSamples;
            deltaKx = obj.protocol.deltaKx;
            systemLimits = obj.protocol.systemLimits;
            readoutOversampling = obj.protocol.readoutOversampling;
            dwellTime = obj.protocol.dwellTime;
            readoutGradientAmplitude = obj.protocol.readoutGradientAmplitude;
            readoutGradientFlatTime = obj.protocol.readoutGradientFlatTime;
            
            Gx = mr.makeTrapezoid('x','Amplitude',readoutGradientAmplitude,'FlatTime',readoutGradientFlatTime,'system',systemLimits);
            ADC = mr.makeAdc(nSamples * readoutOversampling,'Dwell',dwellTime,'Delay',Gx.riseTime,'system',systemLimits);
            %             Gx = mr.makeTrapezoid('x','FlatArea',nSamples * deltaKx,'FlatTime',readoutDuration,'system',systemLimits);
            %             ADC = mr.makeAdc(nSamples * readoutOversampling,'Duration',readoutDuration,'Delay',Gx.riseTime,'system',systemLimits);
            GxPre = mr.makeTrapezoid('x','Area',-(nSamples * deltaKx)/nSamples*floor(nSamples/2)-(Gx.riseTime*Gx.amplitude)/2,'system',systemLimits);
        end
    end
    
    methods(Static)
       function phaseDispersion = calculatePhaseDispersion(SpoilerArea, voxelDimension)
           phaseDispersion = 2 * pi * voxelDimension * SpoilerArea;
       end
   end
    
end

