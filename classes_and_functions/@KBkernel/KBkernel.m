classdef KBkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
           
    properties(Hidden, Constant)        
        N_PRESCANS = 360;
        DUMMY_SCANS_TESTING = 5         
        SPOKES_TESTING = 200
        
    end
    
    methods
        % method signatures
        
        GxPreModified = modifyDurationGxPre(obj) 
        
        mergedGZPre = mergeGzRephAndGZpre(obj, GzReph, GZpre)
        
        SeqEvents = collectSequenceEvents(obj) 
        
        AlignedSeqEvents = alignSeqEvents(obj) 
        
        RfPhasesRad = calculateRfPhasesRad(obj) 
        
        [thetaArray, phiArray] = calculateScanAngles(obj) 
        
        [thetaArrayPre, phiArrayPre] = calculatePreScanAngles(ob) 
          
        [allTheta, allPhi] = calculateAnglesForAllSpokes(obj,scenario) 
        
        singleTrKernel = createSingleTrKernel(obj) 
        
        sequenceObject = createSequenceObject(obj,scenario)               
         
        saveInfo4Reco(obj,fileName) 
        
        giveInfoAboutTestingEvents(obj)
        
    end % end of methods
    
    methods(Static)
        
        function giveInfoAboutMergedEvents()            
            fprintf('**G_slab_Reph and Gz_readout_Pre are merged.\n');
            fprintf('**G_readout and G_readoutSpoiler are merged.\n');
        end % end of static methods
        
        
        
%         [GX, GY, GZ ] = rotate3D(gradient, theta, phi)
   end
    
end % end of the class




