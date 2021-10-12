function GzRephPlusPartitionsCell = createGzRephPlusPartitions(obj)
nPartitions = obj.protocol.nPartitions;
sys = obj.protocol.systemLimits;
deltaKz = obj.protocol.deltaKz;
[~, ~, GzReph] = obj.createSlabSelectionEvents;
if isempty(GzReph)
    GzRephArea = 0;
else
    GzRephArea = GzReph.area;
end

GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
% get a dummy gradient with the maximum area of all GzPartitions
dummyGradient = mr.makeTrapezoid('z',sys,'Area',max(abs(GzPartitionAreas)) + abs(GzRephArea));
% Use the duration of the dummy gradient for all the GzPartitions to keep
% the TE and TR constant.
fixedGradientDuration = mr.calcDuration(dummyGradient);

GzRephPlusPartitionsCell = cell(1,nPartitions);
for iz = 1:nPartitions
    % here, the area of the slab-rephasing lobe and partition-encoding lobes are added together
    GzRephPlusPartitionsCell{iz} = mr.makeTrapezoid('z',sys,...
        'Area',GzPartitionAreas(iz) + GzRephArea,...
        'Duration',fixedGradientDuration);
end

end % end of createGzRephPlusPartitions
