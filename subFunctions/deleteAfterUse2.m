
a=SOSkernel(inputs);
% [allAngles, allPartitionIndx] = a.calculateAnglesForAllSpokes('testing');
a.writeSequence('testing')
% [TE_min, TR_min, delayTE, delayTR] =  a.calculateMinTeTrAndDelays
% G=a.createGzPartitionMax;
% dispersionDueToGzPartition_max = 2 * pi * a.protocol.partitionThickness * abs(G.area);
% [Gspo, dispersionsPerTR] = a.createGzSpoilers;
% [Gx, GxPre, ADC] = a.createReadoutEvents;
% [GxPlusSpoiler, dispersionPerTR] = a.createGxPlusSpoiler;
% Gp = a.createAllGzPartitions;
% Grp=a.createGzRephPlusPartitions;
% [RF, Gz, ~] = a.createSlabSelectionEvents;
%  comb = a.combineGzWithGzRephPlusPartitions;
%  [GxPlusSpoiler,~] = a.createGxPlusSpoiler;
% [RF, ~, GzReph] = a.createSlabSelectionEvents;
% spoiler= a.createGzSpoilers;
% AlignedSeqEvents = a.alignSeqEvents;
% SeqEvents = a.collectSequenceEvents;
% a.simulateSequence;