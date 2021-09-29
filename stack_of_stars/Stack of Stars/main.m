tic
% This script calculates all the sequences events necessary for the imple- 
% mentation of the sequence. Also, as many calculations as possible are
% done here before calling the final function to create the sequence.
tic
% 0. Parameters
load('parametersSoS'); % Load two struct variables: inputs and systemLimits
sys = systemLimits;

Nz = inputs.Nz;
RfExcitation = inputs.RfExcitation;
TE = inputs.TE;
TR = inputs.TR;
nSpokes = inputs.nSpokes;
nDummyScans = inputs.nDummyScans;
angularOrdering = inputs.angularOrdering;
goldenAngleSequence = inputs.goldenAngleSequence;
angleRange = inputs.angleRange;
partitionRotation = inputs.partitionRotation;
RfSpoilingIncrement = inputs.RfSpoilingIncrement;

% 1. Calculate sequence objects; RF, Gz, Gx, GxSpoiler, etc.
seqEvents = createSequenceEvents(inputs, sys);
% 2. Calculate minTE, minTR, delayTE, delayTR
[minTE, minTR] = calculateMinTeTr(seqEvents, RfExcitation, sys);
[info.delayTE, info.delayTR] = calculateTeAndTrDelays(TE, TR, minTE, minTR, sys);
% 3. Calculate the base spoke angles for one partition
info.spokeAngles = calculateSpokeAngles(nSpokes, angularOrdering, goldenAngleSequence, angleRange);
% 4. Calculate partition rotation angles
info.partitionRotationAngles = calculatePartitionRotationAngles(nSpokes,Nz,partitionRotation);
% 5. Caculate the phases of all the RF pulses according to a Phase-cycling schedule
info.RfPhasesRad = calculateRfPhasesRad(nDummyScans, nSpokes, RfSpoilingIncrement, Nz);

% 6. Save all the information required for reconstruction
info4Reco.FOV = inputs.FOV;       
info4Reco.Nx = inputs.Nx;
info4Reco.Nz = inputs.Nz;
info4Reco.readoutOversampling = inputs.readoutOversampling;
info4Reco.nSpokes = inputs.nSpokes;
info4Reco.viewOrder = inputs.viewOrder;
info4Reco.spokeAngles = info.spokeAngles;
info4Reco.partitionRotationAngles = info.partitionRotationAngles;
save('info4RecoSoS.mat','info4Reco');

% 7. Create the sequence in .seq format
mode = 'debuggingMode'; % 'debuggingMode', 'writingMode'
createSequence(inputs, seqEvents, info, sys, mode);
toc
