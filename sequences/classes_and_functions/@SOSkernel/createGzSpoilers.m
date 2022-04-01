function [GzSpoilersCell, dispersionsPerTR] = createGzSpoilers(obj)

phaseDispersionZ = obj.protocol.phaseDispersionZ;
nPartitions = obj.protocol.nPartitions;
sys = obj.protocol.systemLimits;
partitionThickness = obj.protocol.partitionThickness;

GzPartitionsCell = createAllGzPartitions(obj);
GzPartitionMax = createGzPartitionMax(obj);
dispersionDueToGzPartitionMax = obj.calculatePhaseDispersion(abs(GzPartitionMax.area), partitionThickness);

GzSpoilersCell = cell(1,nPartitions);
dispersionsPerTR = zeros(1,nPartitions);

if phaseDispersionZ == 0 % just refocuse the phase encoding gradient in Z direction
    duration = mr.calcDuration(GzPartitionMax);
    for iz = 1:nPartitions
        GzSpoilersCell{iz} = mr.makeTrapezoid('z',sys,'Area',-GzPartitionsCell{iz}.area,...
            'Duration',duration);
        areaTotal = GzPartitionsCell{iz}.area + GzSpoilersCell{iz}.area;
        dispersionsPerTR(iz) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
    end
    
elseif phaseDispersionZ >= dispersionDueToGzPartitionMax
    % use the same duration to keep same TR
    AreaSpoilingZ_max = phaseDispersionZ / (2 * pi * partitionThickness);
    dummyGradient = mr.makeTrapezoid('z',sys,'Area',abs(AreaSpoilingZ_max));
    fixedDurationGradient = mr.calcDuration(dummyGradient);
    for iZ=1:nPartitions
        % GzPartition already add some phase dispersion to the spins
        dispersionDueToThisPartition = obj.calculatePhaseDispersion(abs(GzPartitionsCell{iZ}.area), ...
            partitionThickness);
        % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
        dispersionNeededZ = abs(phaseDispersionZ - dispersionDueToThisPartition);
        AreaSpoilingNeededZ = dispersionNeededZ / (2 * pi * partitionThickness);
        if GzPartitionsCell{iZ}.area < 0
            GzSpoilersCell{iZ} = mr.makeTrapezoid('z',sys,'Area',-AreaSpoilingNeededZ,...
                'Duration',fixedDurationGradient);
        else
            GzSpoilersCell{iZ} = mr.makeTrapezoid('z',sys,'Area',AreaSpoilingNeededZ,...
                'Duration',fixedDurationGradient);
        end
        areaTotal = GzPartitionsCell{iZ}.area + GzSpoilersCell{iZ}.area;
        dispersionsPerTR(iZ) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
    end
    
else
    if phaseDispersionZ >= dispersionDueToGzPartitionMax/2
        % use the same duration to keep same TR
        AreaSpoilingZ_max = phaseDispersionZ / (2 * pi * partitionThickness);
        dummyGradient = mr.makeTrapezoid('z',sys,'Area',abs(AreaSpoilingZ_max));
        fixedDurationGradient = mr.calcDuration(dummyGradient);
    else
        AreaSpoilingZ_max = abs(phaseDispersionZ-dispersionDueToGzPartitionMax) / ...
            (2 * pi * partitionThickness);
        dummyGradient = mr.makeTrapezoid('z',sys,'Area',abs(AreaSpoilingZ_max));
        fixedDurationGradient = mr.calcDuration(dummyGradient);
    end
    for ii=1:nPartitions
        % GzPartition already add some phase dispersion to the spins
        dispersionDueToThisPartition = obj.calculatePhaseDispersion(abs(GzPartitionsCell{ii}.area), ...
            partitionThickness);
        % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
        dispersionNeededZ = abs(phaseDispersionZ - dispersionDueToThisPartition);
        AreaSpoilingNeededZ = dispersionNeededZ / (2 * pi * partitionThickness);
        haveSameSign1 = (GzPartitionsCell{ii}.area < 0 && (dispersionDueToThisPartition >= phaseDispersionZ));
        haveSameSign2 = (GzPartitionsCell{ii}.area > 0 && (dispersionDueToThisPartition <= phaseDispersionZ));
        if (haveSameSign1 || haveSameSign2)
            GzSpoilersCell{ii} = mr.makeTrapezoid('z',sys,'Area',AreaSpoilingNeededZ,...
                'Duration',fixedDurationGradient);
        else
            GzSpoilersCell{ii} = mr.makeTrapezoid('z',sys,'Area',-AreaSpoilingNeededZ,...
                'Duration',fixedDurationGradient);
        end
        areaTotal = GzPartitionsCell{ii}.area + GzSpoilersCell{ii}.area;
        dispersionsPerTR(ii) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
    end
end
end % end of createGzSpoilers
