classdef KBkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
           
    properties(Access = private, Constant)        
        N_PRESCANS = 360;
        DUMMY_SCANS_TESTING = 5         
        SPOKES_TESTING = 200
        
    end
    
    methods
        % method signatures
        [RF, Gz, GzReph] = createSlabSelectionEvents(obj)
        
        GxPreModified = modifyDurationGxPre(obj) %cheked
        
        mergedGZPre = mergeGzRephAndGZpre(obj, GzReph, GZpre)
        
        SeqEvents = collectSequenceEvents(obj) %checked
        
        AlignedSeqEvents = alignSeqEvents(obj) %checked
        
        RfPhasesRad = calculateRfPhasesRad(obj) %checked
        
        [thetaArray, phiArray] = calculateScanAngles(obj) %checked
        
        [thetaArrayPre, phiArrayPre] = calculatePreScanAngles(ob) %checked
          
        [allTheta, allPhi] = calculateAnglesForAllSpokes(obj,scenario) %checked
        
        singleTrKernel = createSingleTrKernel(obj) % checked
        
        sequenceObject = createSequenceObject(obj,scenario) % checked
               
        writeSequence(obj,scenario) %checked
        
        saveInfo4Reco(obj) %checked
        
    end % end of methods
    
    methods(Static)
        
        function giveInfoAboutSequence()
            fprintf('## Creating the sequence...\n');
            fprintf('**GzReph and GzPre are merged.\n');
            fprintf('**G_readout and G_readoutSpoiler are merged.\n');
        end % end of static methods
        
        
        
%         [GX, GY, GZ ] = rotate3D(gradient, theta, phi)
   end
    
end % end of the class




