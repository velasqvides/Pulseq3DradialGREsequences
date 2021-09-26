classdef SOSkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        
        function GzPartition = createMaxGzPartition(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            
            GzPartitionArea = (-nPartitions/2) * deltaKz; % Max area
            % get a dummy gradient with the maximum area of all GzPartitions
            GzPartition = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionArea);
        end
        
        function GzPartitionsCell = createAllGzPartitions(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            GzPartition = createMaxGzPartition(obj);
            
            GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
            fixedGradientDuration = mr.calcDuration(GzPartition);
            
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
        
        function GzCombinedCell = combineGzAndGzRephPlusPartitions(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            [~, Gz, ~] = obj.createSlabSelectionEvents(obj);
            GzRephPlusPartitionsCell = createGzRephAndPartitions(obj);
            
            GzCombinedCell = cell(1,nPartitions);
            for iz=1:nPartitions
                GzCombinedCell{iz} = mr.addGradients({Gz, GzRephPlusPartitionsCell{iz}}, 'system', systemLimits);
            end
        end
        
        function GzSpoilersCell = createGzSpoilers(obj)
            phaseDispersionZ = obj.protocol.phaseDispersionZ;
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            partitionThickness = obj.protocol.partitionThickness;
            GzPartitionsCell = createAllGzPartitions(obj);
            GzPartitionMax = createMaxGzPartition(obj);
            dispersionDueToGzPartition_max = 2 * pi * partitionThickness * abs(GzPartitionMax.area);
            % GzSpoiler
            GzSpoilersCell = cell(1,nPartitions);
            
            if phaseDispersionZ == 0 % just refocuse the phase encoding gradient in Z direction
                duration = mr.calcDuration(GzPartitionsCell{1});
                for iz = 1:nPartitions
                    GzSpoilersCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',-GzPartitionsCell{iz}.area,'Duration',duration);
                end
            elseif phaseDispersionZ > dispersionDueToGzPartition_max  
                % in case the GzSpoiler area has to change, use the same duration to keep same TR
                AreaSpoilingZ_max = phaseDispersionZ / (2 * pi * partitionThickness);
                dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',abs(AreaSpoilingZ_max));
                fixedDurationGradient = mr.calcDuration(dummyGradient);
                
                for iZ=1:nPartitions
                    % GzPartition already add some phase dispersion to the spins
                    dispersionDueToGzPartition = 2 * pi * partitionThickness * abs(GzPartitionsCell{iZ}.area);
                    % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
                    dispersionNeededZ = abs(phaseDispersionZ - dispersionDueToGzPartition);
                    AreaSpoilingNeededZ = dispersionNeededZ / (2 * pi * partitionThickness);
                    if dispersionDueToGzPartition < phaseDispersionZ % make sure the dispersions acts constructively
                        if GzPartitionsCell{iZ}.area < 0
                            GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',-AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                        else
                            GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                        end
                    end
                end
                
%             elseif
%                 % in case the GzSpoiler area has to change, use the same duration to keep same TR
%                 AreaSpoilingZ_max = (dispersionDueToGzPartition_max - phaseDispersionZ) / (2 * pi * partitionThickness);
%                 dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',abs(AreaSpoilingZ_max));
%                 fixedDurationGradient = mr.calcDuration(dummyGradient);
%                 for iZ=1:nPartitions
%                     if GzPartitionsCell{iZ}.area < 0
%                         GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
%                     else
%                         GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',-AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
%                     end
%                 end
%             elseif   
                
            end
            
        end
    end
    
end


end
