classdef SOSkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function GzPartitionsCell = createGzPartitions(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            
            GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
            % get a dummy gradient with the maximum area of all GzPartitions
            dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',max(abs(GzPartitionAreas)));
            % Use the duration of the dummy gradient for all the GzPartitions to keep
            % the TE and TR constant.
            fixedGradientDuration = mr.calcDuration(dummyGradient);
            
            % make partition encoding gradients
            GzPartitionsCell = cell(1,nPartitions);
            for iz = 1:nPartitions
                GzPartitionsCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionAreas(iz),'Duration',fixedGradientDuration);
            end
            
        end
        
        function GzRephPlusPartitionsCell = createGzRephAndPartitions(obj)                        
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            [~, ~, GzReph] = obj.createSlabSelectionEvents;
            if isempty(GzReph)
                GzRephArea = 0;
            else
                GzRephArea = GzReph.area;
            end
            
            GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
            % get a dummy gradient with the maximum area of all GzPartitions
            dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',max(abs(GzPartitionAreas)) + abs(GzRephArea));
            % Use the duration of the dummy gradient for all the GzPartitions to keep
            % the TE and TR constant.
            fixedGradientDuration = mr.calcDuration(dummyGradient);
            
            GzRephPlusPartitionsCell = cell(1,nPartitions);
            for iz = 1:nPartitions
                % here, the area of the slab-rephasing lobe and partition-encoding lobes are added together
                GzRephPlusPartitionsCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionAreas(iz) + GzRephArea,...
                    'Duration',fixedGradientDuration);
            end
            
        end
        
    end
end

