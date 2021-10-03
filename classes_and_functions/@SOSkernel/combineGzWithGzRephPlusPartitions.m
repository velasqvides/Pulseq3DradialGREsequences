function GzCombinedCell = combineGzWithGzRephPlusPartitions(obj)
nPartitions = obj.protocol.nPartitions;
systemLimits = obj.protocol.systemLimits;
[~, Gz, ~] = createSlabSelectionEvents(obj);
GzRephPlusPartitionsCell = createGzRephPlusPartitions(obj);

GzCombinedCell = cell(1,nPartitions);
for iz=1:nPartitions
    if isempty(Gz)% means that only GzPartition exist
        GzCombinedCell{iz} = GzRephPlusPartitionsCell{iz};
    else
        GzRephPlusPartitionsCell{iz}.delay = GzRephPlusPartitionsCell{iz}.delay + mr.calcDuration(Gz);
        GzCombinedCell{iz} = mr.addGradients({Gz, GzRephPlusPartitionsCell{iz}}, 'system', systemLimits);
    end
end
end % end of combineGzWithGzRephPlusPartitions
