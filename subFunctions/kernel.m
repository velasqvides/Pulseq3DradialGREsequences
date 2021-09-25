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
        
        
        
    end
    
end

