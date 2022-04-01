classdef kernel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        protocol (1,1) protocol
    end
    
    methods
        
        function obj = kernel(inputProtocol)
            obj.protocol = inputProtocol;
        end % end constructor
        
        % method signatures
        [RF, Gz, GzReph] = createSlabSelectionEvents(obj) 
        
        [Gx, GxPre, ADC] = createReadoutEvents(obj) 
        
        [GxPlusSpoiler,dispersionPerTR] = createGxPlusSpoiler(obj)        
          
        [TE_min, TR_min] = calculateMinTeTr(obj) 
    
        [delayTE, delayTR] = calculateDelays(obj)
        
        giveTestingInfo(obj,sequenceObject)
        
        saveProtocol(obj)
        
        writeSequence(obj, fileName, scenario)
        
        showSlabProfile(obj)
        
        RfPhasesRad = calculateRfPhasesRad(obj)
        
    end % end methods    
    
    methods(Static)
        
       function phaseDispersion = calculatePhaseDispersion(SpoilerArea, dimensionAlongSpoiler)
           phaseDispersion = 2 * pi * dimensionAlongSpoiler * SpoilerArea;
       end
       
    end % end static methods
    
end % end class kernel

