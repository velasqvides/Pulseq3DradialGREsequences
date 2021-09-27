
a=SOSkernel(inputs);
% G=a.createGzPartitionMax;
% dispersionDueToGzPartition_max = 2 * pi * a.protocol.partitionThickness * abs(G.area);
% [Gspo, dispersionPerTR] = a.createGzSpoilers;
[Gx, GxPre, ADC] = a.createReadoutEvents;
% Gp = a.createAllGzPartitions;
% Grp=a.createGzRephAndPartitions;
% [~, ~, GzReph] = a.createSlabSelectionEvents;
% spoiler= a.createGzSpoilers;
