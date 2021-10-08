classdef KBprotocol < protocol
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        angularOrdering string {mustBeMember(angularOrdering,{'uniform', 'goldenAngle'})}='goldenAngle'
    end
    
    properties(Access = private, Constant)        
        transmitterBandwidth_min = 1500;
        transmitterBandwidth_max = 250e3;        
        RfPulseDuration_min = 20e-6;
        RfPulseDuration_max = 12e-3;
        timeBwProduct_min = 2;
        timeBwProduct_max = 20;
    end
    
    properties(Dependent,Hidden)        
        transmitterBandwidth
        slabGradientAmplitude
    end
    
    methods
        
        function slabGradientAmplitude = get.slabGradientAmplitude(obj)
            slabGradientAmplitude = obj.timeBwProduct / (obj.FOV * obj.RfPulseDuration);
        end
        
        function transmitterBandwidth = get.transmitterBandwidth(obj)
            transmitterBandwidth = obj.timeBwProduct / obj.RfPulseDuration;
        end
            
        % method signatures
        validateSlabSelection(obj) 
        
        validateTEandTR(obj) 
        
        validateProtocol(obj)
        
    end % end of methods
    
end %end of the class

