
a=SOSkernel(inputs);
tic
Gp = a.createGzPartitions;
Grp=a.createGzRephAndPartitions;
[~, ~, GzReph] = a.createSlabSelectionEvents;
spoiler= a.createGzSpoilers;
toc