function GzPartitionMax = createGzPartitionMax(obj)
nPartitions = obj.protocol.nPartitions;
systemLimits = obj.protocol.systemLimits;
deltaKz = obj.protocol.deltaKz;

GzPartitionArea = (-nPartitions/2) * deltaKz; % Max area
% get a dummy gradient with the maximum area of all GzPartitions
GzPartitionMax = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionArea);
end % end of createGzPartitionMax