classdef KBprotocol < protocol
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        angularOrdering string {mustBeMember(angularOrdering,{'uniform', 'goldenAngle'})}='goldenAngle'
    end
    
    properties(Dependent,Hidden)        
        slabGradientAmplitude
        slabSize
    end
    
    methods
        
        function slabGradientAmplitude = get.slabGradientAmplitude(obj)
            slabGradientAmplitude = obj.transmitterBandwidth / obj.FOV ;
        end
        
        function slabSize = get.slabSize(obj)
            slabSize = obj.FOV;
        end
                    
        % method signatures
        validateSlabSelection(obj) 
        
        validateTEandTR(obj) 
        
        validateProtocol(obj)
        
    end % end of methods
    
end %end of the class

