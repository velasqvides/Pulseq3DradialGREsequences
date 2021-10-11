classdef SOSkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
           
    properties(Access = private, Constant)        
        DUMMY_SCANS_TESTING = 5         
        SPOKES_TESTING_INNER = 2
        SPOKES_TESTING_OUTER = 21
    end
    
    methods
        %method signatures
        GzPartitionMax = createGzPartitionMax(obj)
        
        GzPartitionsCell = createAllGzPartitions(obj)
        
        GzRephPlusPartitionsCell = createGzRephPlusPartitions(obj)
        
        GzCombinedCell = combineGzWithGzRephPlusPartitions(obj)
        
        [GzSpoilersCell, dispersionsPerTR] = createGzSpoilers(obj)
        
        SeqEvents = collectSequenceEvents(obj)
        
        AlignedSeqEvents = alignSeqEvents(obj)
        
        RfPhasesRad = calculateRfPhasesRad(obj)
        
        spokeAngles = calculateSpokeAngles(obj)
        
        partitionRotationAngles = calculatePartitionRotationAngles(obj)
        
        singleTrKernel = createSingleTrKernel(obj)
        
        [allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(obj,scenario)
        
        sequenceObject = createSequenceObject(obj,scenario)
               
        writeSequence(obj,scenario)
        
        saveInfo4Reco(obj)         
        
    end % end of methods
    
    methods(Static)
        
        function giveInfoAboutSequence()
            fprintf('## Creating the sequence...\n');
            fprintf('**GzReph and GzPartition are merged.\n');
            fprintf('**G_readout and G_readoutSpoiler are merged.\n');
        end % end of static methods
        
   end
    
end % end of the class




