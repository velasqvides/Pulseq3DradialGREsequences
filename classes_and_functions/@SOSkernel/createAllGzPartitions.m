function GzPartitionsCell = createAllGzPartitions(obj)
nPartitions = obj.protocol.nPartitions;
systemLimits = obj.protocol.systemLimits;
deltaKz = obj.protocol.deltaKz;
GzPartitionMax = createGzPartitionMax(obj);

% areas go from bottom to top
GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz;
fixedGradientDuration = mr.calcDuration(GzPartitionMax);

% make partition encoding gradients
GzPartitionsCell = cell(1,nPartitions);
for iz = 1:nPartitions
    GzPartitionsCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionAreas(iz),...
        'Duration',fixedGradientDuration);
end

end % end of createAllGzPartitions
