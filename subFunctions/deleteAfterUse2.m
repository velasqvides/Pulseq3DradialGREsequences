
a=SOSkernel(inputs);
G=a.createMaxGzPartition;
dispersionDueToGzPartition_max = 2 * pi * a.protocol.partitionThickness * abs(G.area);
[Gspo, dispersionPerTR] = a.createGzSpoilers;

% Gp = a.createAllGzPartitions;
% Grp=a.createGzRephAndPartitions;
% [~, ~, GzReph] = a.createSlabSelectionEvents;
% spoiler= a.createGzSpoilers;
