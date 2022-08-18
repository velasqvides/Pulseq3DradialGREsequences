## Observations
This tutorial assumes that the requirements, necessary preparation, and code testing described in [README.md] have been fulfilled.

In the following, a short tutorial to create a stack-of-star (SOS) sequence and its reconstruction pipeline will be given. For a koosh-ball (KB) sequence, the procedure should be similar.

## Sequence development 
1. Open [SOSinputParameters], enter the desired protocol parameters and run that script. Be alert to the feedback received at the command window, as some values will be adjusted automatically by the algorithm if necessary. For instance, if the desired TE is below to certain achievable lower limit, the TE will be set to that lower limit. This script will create a variable called `inputs`.

2. Create a SOSkernel object, for instance, `mySOS = SOSkernel(inputs)`.

3. Create and test a .seq file using `mySOS.writeSequence('mySequence','testing',1)`; where,<br/>
a) the first argument is the name of the sequence,<br/> b) the second argument is the scenario, which can be `testing` or `writing`. For `testing` only a certain predefined number of spokes and partitions will be tested to accelerate the testing process.<br/>
c) the third argument is the debug level that can be `1`,`2` or `3`, being the `3` the higher level and which brings apart from the plots, a test report that is "a very slow step, but useful for testing during development, e.g. for the real TE, TR or for staying within slewrate limits".

4. After testing, create the final .seq file using `mySOS.writeSequence('mySequence','writing')`. A new folder called `mySequence` should be created in the folder [generated_seq_files], containing the `mySequence.seq` file and the `info4Reco.mat` variable.

5. Execute the `mySequence.seq` file on the scanner using the software interpreter as described in [README.md], and perform some MR measurements.

## Image reconstruction
1. Copy the raw data (usually .dat file) and the `info4Reco.mat` variable to the folder [raw_data].
2. Execute the script [dataPreprocessing.m]. The `rawDataName` and `nFinalCoils` should be change here.
3. Execute the script [gradientDelayCorrection.m].
4. Execute the script [partitionByPartitionReconstruction.m].
5. During the execution of those three scrips some `cfl` and `hdr` files will be created and saved in the folder [processed_data], including the final reconstructed imageVolume. 


[README.md]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/blob/main/README.md>

[SOSinputParameters]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/blob/main/sequences/stack_of_stars/SOSinputParameters.m>

[generated_seq_files]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/tree/main/sequences/stack_of_stars/generated_seq_files>

[raw_data]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/tree/main/reconstructions/stack_of_stars/raw_data>

[dataPreprocessing.m]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/blob/main/reconstructions/stack_of_stars/dataPreprocessing.m>

[gradientDelayCorrection.m]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/blob/main/reconstructions/stack_of_stars/gradientDelayCorrection.m>

[partitionByPartitionReconstruction.m]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/blob/main/reconstructions/stack_of_stars/partitionByPartitionReconstruction.m>


[processed_data]: <https://github.com/velasqvides/Pulseq3DradialGREsequences/tree/main/reconstructions/stack_of_stars/processed_data>


