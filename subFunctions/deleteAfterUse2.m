
a=SOSkernel(inputs);
% G=a.createGzPartitionMax;
% dispersionDueToGzPartition_max = 2 * pi * a.protocol.partitionThickness * abs(G.area);
% [Gspo, dispersionsPerTR] = a.createGzSpoilers;
[Gx, GxPre, ADC] = a.createReadoutEvents;
[GxPlusSpoiler, dispersionPerTR] = a.createGxPlusSpoiler;
% Gp = a.createAllGzPartitions;
% Grp=a.createGzRephAndPartitions;
[RF, ~, GzReph] = a.createSlabSelectionEvents;
% spoiler= a.createGzSpoilers;
