function createSequence(inputs, seqEvents, info, sys, mode)
%This function create the sequence and write the final .seq file.
% It has two modes of operation controlled by the parameter 'mode'. In
% 'debugginMode', beside writing the .seq file, this function also gives
% debug information, like the k-space trajectory plot, and a test report
% containing the real TE and TR, total scan duration, number of blocks,
% spatial resolution, max gradients and slew rate and more.
% In 'debuggingMode', usually only a few hundred spokes will be simulated 
% to speed up the process, and once everything looks fine, one can pass to
% 'writingMode' to get the final .seq file using the complete set of
% spokes.
%
% Inputs
%   - inputs: a struct with input data to create the sequence events. 
%   - sys: a struct with the system limits.
%   - seqEvents: a struct will all the sequence events needed in the
%   sequence (RF,Gx,Gy,Gz,GSpoilers, ADC).
%   - info: a struct with all the information gathered in the main script, 
%   which is needed to create the sequence.
%   - mode: 'debuggingMode', 'writingMode'. In debuggingMode only certain
%   spokes and certain partitions will be simulated. The exact number will
%   be given in the command window, together with extra debug information. 
%   In writtingMode the complete sequence will be created, but debug 
%   information wont be given as it slower the finalization of the process.  
% Output
%   - .seq file: a .seq file that can be interpreted and simulated in IDEA
%   environtment, or run in the scanner.

% 0. Bring some info to the user 
fprintf('\n## Creating the sequence ##\n\n');
pause(1);
fprintf('**GzReph and GzPartition are merged.\n\n');
pause(1);
   
% 1. Create a sequence object
seq = mr.Sequence(); 

%% 2. Extract the required parameters from the inputs struct and rename them conveniently.
FOV = inputs.FOV;
slabThickness = inputs.slabThickness;
RfExcitation = inputs.RfExcitation;
nDummyScans = inputs.nDummyScans;
nSpokes = inputs.nSpokes;
Nz = inputs.Nz;
viewOrder = inputs.viewOrder;

RF = seqEvents.RF;
ADC = seqEvents.ADC;
Gz = seqEvents.Gz;
GzPartition = seqEvents.GzPartition;
GzRephPlusGzPartition = seqEvents.GzRephPlusGzPartition;
GxPre = seqEvents.GxPre ;
Gx = seqEvents.Gx;
GxSpoiler = seqEvents.GxSpoiler;
GxPlusSpoiler = seqEvents.GxPlusSpoiler;
GzSpoiler = seqEvents.GzSpoiler;

delayTE = info.delayTE;
delayTR = info.delayTR;
spokeAngles = info.spokeAngles;
partRotAngles = info.partitionRotationAngles;
RfPhasesRad = info.RfPhasesRad;

if ~isempty(GxPlusSpoiler)
    fprintf('**G_readout and G_readoutSpoiler are merged.\n\n');
    pause(1);
end

%% 3. Final Modifications
% 3.1 Align GxPre to the right, in case that both, GzRephPlusGzPartition (or
%     GzPartition) and GxPre, are applied in the same block.  
if strcmp(RfExcitation, 'selectiveSinc') && delayTE < mr.calcDuration(GzRephPlusGzPartition(1)) 
    if mr.calcDuration(GzRephPlusGzPartition(1)) > mr.calcDuration(GxPre)
        % align GzRephPlusGzPartition and GxPre to the right
        addDelay = mr.calcDuration(GzRephPlusGzPartition(1)) - mr.calcDuration(GxPre);
        GxPre.delay = GxPre.delay + (addDelay / sys.gradRasterTime) * sys.gradRasterTime;
    end
elseif strcmp(RfExcitation, 'nonSelective') && delayTE < mr.calcDuration(GzPartition(1))
    if mr.calcDuration(GzPartition(1)) > mr.calcDuration(GxPre)
        % align GzRephPlusGzPartition and GxPre to the right
        addDelay = mr.calcDuration(GzPartition(1)) - mr.calcDuration(GxPre);
        GxPre.delay = GxPre.delay + (addDelay / sys.gradRasterTime) * sys.gradRasterTime;
    end
end 

% 3.2 Add delays to the GzSpoiler as (most of the time) they will be 
%     applied in the same block with Gx (or GxPlusSpoiler).
addDelay = Gx.riseTime + Gx.flatTime;
for i=1:Nz
    GzSpoiler(i).delay = addDelay; % GzSpoiler can appear after flat region of Gx in the same block 
end

% 3.3 Only five dummy scans will be shown in debugging mode, if nDummyScnas > 0
if strcmp(mode, 'debuggingMode')
    if nDummyScans > 0
        nDummyScans = 5;  
    end   
end

% 3.4 Calculate the spokes angles for all the spokes and for all the partitions.
% By doing that, we can merge the dummy and normal scans within the same for loop.
% Also, only one for loop will be necessary in the next step if all the spokes angles are
% pre-calculated before hand.
% In debuggingMode, this function will bring information in the
% command window about how many spokes and partitions will be shown in the
% simulation depending on the chosen viewOrder.
% Important: in case more scans in debuggingMode are required to be simulated, one has to modified this function.  
[allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(spokeAngles,partRotAngles,viewOrder,nSpokes,Nz,nDummyScans,mode);

 %% 4. Main for loop to create the blocks for the sequence  
RFcounter = 1; % to keep track of the number of applied RF pulses.
for iF = 1:length(allAngles)
    
    iZ = allPartitionIndx(iF);
    RF.phaseOffset = RfPhasesRad(RFcounter);
    ADC.phaseOffset = RfPhasesRad(RFcounter);
    
    if strcmp(RfExcitation, 'selectiveSinc')
        seq.addBlock(RF, Gz);
        if delayTE == 0
            seq.addBlock(mr.rotate('z', allAngles(iF), GzRephPlusGzPartition(iZ), GxPre));
        elseif delayTE > 0  &&  delayTE < mr.calcDuration(GzRephPlusGzPartition(iZ))
            seq.addBlock(mr.makeDelay(delayTE));
            seq.addBlock(mr.rotate('z', allAngles(iF), GzRephPlusGzPartition(iZ), GxPre));
        elseif delayTE >= mr.calcDuration(GzRephPlusGzPartition(iZ))
            seq.addBlock(mr.rotate('z', allAngles(iF), GzRephPlusGzPartition(iZ), mr.makeDelay(delayTE)));
            seq.addBlock(mr.rotate('z', allAngles(iF), GxPre));
        end
    else % nonSelective excitation
        seq.addBlock(RF);
        if delayTE == 0
            seq.addBlock(mr.rotate('z', allAngles(iF), GzPartition(iZ), GxPre));
        elseif delayTE > 0  &&  delayTE < mr.calcDuration(GzPartition(iZ))
            seq.addBlock(mr.makeDelay(delayTE));
            seq.addBlock(mr.rotate('z', allAngles(iF), GzPartition(iZ), GxPre));
        elseif delayTE >= mr.calcDuration(GzPartition(iZ))
            seq.addBlock(mr.rotate('z', allAngles(iF), GzPartition(iZ), mr.makeDelay(delayTE)));
            seq.addBlock(mr.rotate('z', allAngles(iF), GxPre));
        end
    end
    
    if iF > nDummyScans % include ADC events
        
        if isempty(GxSpoiler)
            seq.addBlock(mr.rotate('z', allAngles(iF), Gx, ADC, GzSpoiler(iZ)));
        else
            if ~isempty(GxPlusSpoiler)
                seq.addBlock(mr.rotate('z', allAngles(iF), GxPlusSpoiler, ADC, GzSpoiler(iZ)));
            else
                seq.addBlock(mr.rotate('z', allAngles(iF), Gx, ADC));
                GzSpoiler(iZ).delay = 0;
                seq.addBlock(mr.rotate('z', allAngles(iF), GxSpoiler, GzSpoiler(iZ)));
            end
        end
        
    else % no ADC event
        
        if isempty(GxSpoiler)
            seq.addBlock(mr.rotate('z', allAngles(iF), Gx, GzSpoiler(iZ)));
        else
            if ~isempty(GxPlusSpoiler)
                seq.addBlock(mr.rotate('z', allAngles(iF), GxPlusSpoiler, GzSpoiler(iZ)));
            else
                seq.addBlock(mr.rotate('z', allAngles(iF), Gx));
                GzSpoiler(iZ).delay = 0;
                seq.addBlock(mr.rotate('z', allAngles(iF), GxSpoiler, GzSpoiler(iZ)));
            end
        end
    end   
        
    
    if delayTR > 0
        seq.addBlock(mr.makeDelay(delayTR))
    end
    
    RFcounter = RFcounter + 1;    
    
end

%% 5. Give debug info if required
if strcmp(mode, 'debuggingMode')
    
    seq.plot();
    % seq.sound();
    
    %% trajectory calculation
    [ktraj_adc, ktraj, t_excitation, t_refocusing, t_adc] = seq.calculateKspace();
    
    % plot k-spaces
    time_axis = (1:(size(ktraj,2))) * sys.gradRasterTime;
    figure; plot(time_axis, ktraj'); % plot the entire k-space trajectory
    hold; plot(t_adc,ktraj_adc(1,:),'.'); % and sampling points on the kx-axis
    figure; plot(ktraj(1,:),ktraj(2,:),'b'); % a 2D plot
    axis('equal'); % enforce aspect ratio for the correct trajectory display
    hold; plot(ktraj_adc(1,:),ktraj_adc(2,:),'r.'); % plot the sampling points
    
    %% very optional slow step, but useful for testing during development e.g. for the real TE, TR or for staying within slewrate limits
    
    rep = seq.testReport;
    fprintf([rep{:}]);
    
end

%% 6. Write sequence
seq.setDefinition('FOV', [FOV FOV slabThickness]);
seq.setDefinition('Name', '3D_stackOfStars');

seq.write('3D_stackOfStars.seq')       % Write to pulseq file

%seq.install('siemens');
end

%% 7. Local functions
function [allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(spokeAngles,partRotAngles, ...
                                         viewOrder,nSpokes,Nz,nDummyScans,mode)
%calculateAnglesForAllSpokes convieniently calculates before hand the angles
%for all the spokes and for all partitions, inlcuding dummy scans.
% In debuggingMode, this function will bring information in the
% command window about how many spokes and partitions will be simulated
% depending on the chosen viewOrder.
% Important: in case more scans in debuggingMode are required to be simulated, 
% one has to modified this function, specifically the variables nDebugSpokes and
% nDebugPartitions, and depeding on the viewOrder.
% We consider that, when the partitions are in outer loop, 21 spokes per
% partittion and only the first, central and last partitions are enough to
% check if the sequence is correctly created.
% When the partitions are in the inner loop, we prefer to go through all
% the partitions but only for two different spokes angles to see the
% pattern and check that the sequence is working fine.
 
counter = 1;

switch mode
    case 'debuggingMode'
        switch viewOrder
            case 'partitionsInOuterLoop'
                nDebugSpokes = 21;
                nDebugPartitions = [1, Nz / 2 + 1, Nz];
                angles = zeros(1, nDebugSpokes*length(nDebugPartitions));
                partitionIndx = zeros(1, nDebugSpokes*length(nDebugPartitions));
                for iZ = nDebugPartitions
                    for iR = 1:nDebugSpokes
                        angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                        partitionIndx(counter) = iZ;
                        counter = counter + 1;
                    end
                end
                fprintf('**For debugging mode and partitions in the outer loop, %i dummy scans are used.\n',nDummyScans);
                fprintf('  Then, %i spokes for the first, central and last partitions are used.\n\n',nDebugSpokes);
                pause(1);
            case 'partitionsInInnerLoop'
                nDebugSpokes = 2;
                nDebugPartitions = 1:Nz;
                angles = zeros(1, nDebugSpokes*length(nDebugPartitions));
                partitionIndx = zeros(1, nDebugSpokes*length(nDebugPartitions));
                for iR = 1:nDebugSpokes
                    for iZ = nDebugPartitions
                        angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                        partitionIndx(counter) = iZ;
                        counter = counter + 1;
                    end
                end
                fprintf('**For debugging mode and partitions in the inner loop, %i dummy scans are used.\n',nDummyScans);
                fprintf('  Then, only %i spokes for all the partitions are used.\n\n',nDebugSpokes);
                pause(1);                
        end
        
        if nDummyScans > 0
            allAngles = [angles(1:nDummyScans) angles]; % replicate the first nDummyScans angles for the dummy scans
            allPartitionIndx = [partitionIndx(1:nDummyScans) partitionIndx]; % replicate the first partitionIndx indexes for the dummy scans
        else
            allAngles = angles;
            allPartitionIndx = partitionIndx;
        end
        
    case 'writingMode'
        switch viewOrder
            case 'partitionsInOuterLoop'
                angles = zeros(1, nSpokes * Nz);
                partitionIndx = zeros(1, nSpokes * Nz);
                for iZ=1:Nz
                    for iR=1:nSpokes
                        angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                        partitionIndx(counter) = iZ;
                        counter = counter + 1;
                    end
                end
            case 'partitionsInInnerLoop'
                angles = zeros(1, nSpokes * Nz);
                partitionIndx = zeros(1, nSpokes * Nz);
                for iR=1:nSpokes
                    for iZ=1:Nz
                        angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                        partitionIndx(counter) = iZ;
                        counter = counter + 1;
                    end
                end
        end
        
        if nDummyScans > 0
            allAngles = [angles(1:nDummyScans) angles]; % replicate the first nDummyScans angles for the dummy scans
            allPartitionIndx = [partitionIndx(1:nDummyScans) partitionIndx]; % replicate the first partitionIndx indexes for the dummy scans
        else
            allAngles = angles;
            allPartitionIndx = partitionIndx;
        end
end

end
