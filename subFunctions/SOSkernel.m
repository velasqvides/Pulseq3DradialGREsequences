classdef SOSkernel < kernel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
           
    properties(Access = private, Constant)        
        DUMMY_SCANS_TESTING = 5         
        SPOKES_TESTING_INNER = 2
    end
    
    methods
        function GzPartitionMax = createGzPartitionMax(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            
            GzPartitionArea = (-nPartitions/2) * deltaKz; % Max area
            % get a dummy gradient with the maximum area of all GzPartitions
            GzPartitionMax = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionArea);
        end
        
        function GzPartitionsCell = createAllGzPartitions(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            GzPartitionMax = createGzPartitionMax(obj);
            
            GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
            fixedGradientDuration = mr.calcDuration(GzPartitionMax);
            
            % make partition encoding gradients
            GzPartitionsCell = cell(1,nPartitions);
            for iz = 1:nPartitions
                GzPartitionsCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionAreas(iz),'Duration',fixedGradientDuration);
            end
            
        end
        
        function GzRephPlusPartitionsCell = createGzRephPlusPartitions(obj)
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            deltaKz = obj.protocol.deltaKz;
            [~, ~, GzReph] = obj.createSlabSelectionEvents;
            if isempty(GzReph)
                GzRephArea = 0;
            else
                GzRephArea = GzReph.area;
            end
            
            GzPartitionAreas = ((0:nPartitions-1) - nPartitions/2) * deltaKz; % areas go from bottom to top
            % get a dummy gradient with the maximum area of all GzPartitions
            dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',max(abs(GzPartitionAreas)) + abs(GzRephArea));
            % Use the duration of the dummy gradient for all the GzPartitions to keep
            % the TE and TR constant.
            fixedGradientDuration = mr.calcDuration(dummyGradient);
            
            GzRephPlusPartitionsCell = cell(1,nPartitions);
            for iz = 1:nPartitions
                % here, the area of the slab-rephasing lobe and partition-encoding lobes are added together
                GzRephPlusPartitionsCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',GzPartitionAreas(iz) + GzRephArea,...
                    'Duration',fixedGradientDuration);
            end
            
        end
        
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
        end
        
        function [GzSpoilersCell, dispersionsPerTR] = createGzSpoilers(obj)
            
            phaseDispersionZ = obj.protocol.phaseDispersionZ;
            nPartitions = obj.protocol.nPartitions;
            systemLimits = obj.protocol.systemLimits;
            partitionThickness = obj.protocol.partitionThickness;
            
            GzPartitionsCell = createAllGzPartitions(obj);
            GzPartitionMax = createGzPartitionMax(obj);
            dispersionDueToGzPartitionMax = obj.calculatePhaseDispersion(abs(GzPartitionMax.area), partitionThickness);
            
            GzSpoilersCell = cell(1,nPartitions);
            dispersionsPerTR = zeros(1,nPartitions);
            
            if phaseDispersionZ == 0 % just refocuse the phase encoding gradient in Z direction
                duration = mr.calcDuration(GzPartitionMax);
                for iz = 1:nPartitions
                    GzSpoilersCell{iz} = mr.makeTrapezoid('z',systemLimits,'Area',-GzPartitionsCell{iz}.area,'Duration',duration);
                    areaTotal = GzPartitionsCell{iz}.area + GzSpoilersCell{iz}.area;
                    dispersionsPerTR(iz) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
                end
                
            elseif phaseDispersionZ >= dispersionDueToGzPartitionMax
                % use the same duration to keep same TR
                AreaSpoilingZ_max = phaseDispersionZ / (2 * pi * partitionThickness);
                dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',abs(AreaSpoilingZ_max));
                fixedDurationGradient = mr.calcDuration(dummyGradient);
                for iZ=1:nPartitions
                    % GzPartition already add some phase dispersion to the spins
                    dispersionDueToThisPartition = obj.calculatePhaseDispersion(abs(GzPartitionsCell{iZ}.area), partitionThickness);
                    % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
                    dispersionNeededZ = abs(phaseDispersionZ - dispersionDueToThisPartition);
                    AreaSpoilingNeededZ = dispersionNeededZ / (2 * pi * partitionThickness);
                    if GzPartitionsCell{iZ}.area < 0
                        GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',-AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                    else
                        GzSpoilersCell{iZ} = mr.makeTrapezoid('z','Area',AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                    end
                    areaTotal = GzPartitionsCell{iZ}.area + GzSpoilersCell{iZ}.area;
                    dispersionsPerTR(iZ) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
                end
                
            else
                if phaseDispersionZ >= dispersionDueToGzPartitionMax/2
                    % use the same duration to keep same TR
                    AreaSpoilingZ_max = phaseDispersionZ / (2 * pi * partitionThickness);
                    dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',abs(AreaSpoilingZ_max));
                    fixedDurationGradient = mr.calcDuration(dummyGradient);
                else
                    AreaSpoilingZ_max = abs(phaseDispersionZ-dispersionDueToGzPartitionMax) / (2 * pi * partitionThickness);
                    dummyGradient = mr.makeTrapezoid('z',systemLimits,'Area',abs(AreaSpoilingZ_max));
                    fixedDurationGradient = mr.calcDuration(dummyGradient);
                end
                for ii=1:nPartitions
                    % GzPartition already add some phase dispersion to the spins
                    dispersionDueToThisPartition = obj.calculatePhaseDispersion(abs(GzPartitionsCell{ii}.area), partitionThickness);
                    % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
                    dispersionNeededZ = abs(phaseDispersionZ - dispersionDueToThisPartition);
                    AreaSpoilingNeededZ = dispersionNeededZ / (2 * pi * partitionThickness);
                    haveSameSign1 = (GzPartitionsCell{ii}.area < 0 && (dispersionDueToThisPartition >= phaseDispersionZ));
                    haveSameSign2 = (GzPartitionsCell{ii}.area > 0 && (dispersionDueToThisPartition <= phaseDispersionZ));
                    if (haveSameSign1 || haveSameSign2)
                        GzSpoilersCell{ii} = mr.makeTrapezoid('z','Area',AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                    else
                        GzSpoilersCell{ii} = mr.makeTrapezoid('z','Area',-AreaSpoilingNeededZ,'Duration',fixedDurationGradient,'system',systemLimits);
                    end
                    areaTotal = GzPartitionsCell{ii}.area + GzSpoilersCell{ii}.area;
                    dispersionsPerTR(ii) = obj.calculatePhaseDispersion(areaTotal, partitionThickness);
                end
            end
        end
        
        function SeqEvents = collectSequenceEvents(obj)
            [RF, ~, ~] = createSlabSelectionEvents(obj);
            GzCombinedCell = combineGzWithGzRephPlusPartitions(obj);
            [~, GxPre, ADC] = createReadoutEvents(obj);
            [GxPlusSpoiler,~] = createGxPlusSpoiler(obj);
            [GzSpoilersCell, ~] = createGzSpoilers(obj);
            
            SeqEvents.RF = RF;
            SeqEvents.GzCombinedCell = GzCombinedCell;
            SeqEvents.GxPre = GxPre;
            SeqEvents.GxPlusSpoiler = GxPlusSpoiler;
            SeqEvents.GzSpoilersCell = GzSpoilersCell;
            SeqEvents.ADC = ADC;
        end
        
        function AlignedSeqEvents = alignSeqEvents(obj)
            SeqEvents = collectSequenceEvents(obj);
            RF = SeqEvents.RF;
            GzCombinedCell = SeqEvents.GzCombinedCell;
            GxPre = SeqEvents.GxPre;
            GxPlusSpoiler = SeqEvents.GxPlusSpoiler;
            GzSpoilersCell = SeqEvents.GzSpoilersCell;
            ADC = SeqEvents.ADC;
            rfRingdownTime = obj.protocol.systemLimits.rfRingdownTime;
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            RfExcitation = obj.protocol.RfExcitation;
            
            % 1. fix the first block (RF, GzCombinedCell, and GxPre)
            addDelay = mr.calcDuration(RF) - rfRingdownTime;
            if strcmp(RfExcitation,'nonSelective')
                for ii =1:size(GzCombinedCell,2)
                    GzCombinedCell{ii}.delay = GzCombinedCell{ii}.delay + addDelay; %1.1
                end
            end
            GxPre.delay = GxPre.delay + addDelay;
            
            durationGzCombined = mr.calcDuration(GzCombinedCell{1});
            durationGxPre = mr.calcDuration(GxPre);
            if durationGzCombined > durationGxPre
                % align GzRephPlusGzPartition and GxPre to the right
                addDelay = durationGzCombined - durationGxPre;
                GxPre.delay = GxPre.delay + (addDelay / gradRasterTime) * gradRasterTime; % 1.2
            end
            
            % 2 fix the second block (GxPlusSpoiler, ADC, GzSpoilersCell)
            % 2.1 add delay to the ADC event to appear at the same time as
            % the flat region of Gx
            ADC.delay = GxPlusSpoiler.riseTime;
            % 2.2 add delay to GzSpoliers to appear just after the flat
            % region of GxPlusSpoilers
            addDelay = GxPlusSpoiler.riseTime + GxPlusSpoiler.flatTime;
            for kk=1:size(GzSpoilersCell,2)
                GzSpoilersCell{kk}.delay = GzSpoilersCell{kk}.delay + addDelay; % GzSpoiler can appear after flat region of Gx in the same block
            end
            
            % return the aligned events in a struct
            AlignedSeqEvents.RF = RF;
            AlignedSeqEvents.GzCombinedCell = GzCombinedCell;
            AlignedSeqEvents.GxPre = GxPre;
            AlignedSeqEvents.GxPlusSpoiler = GxPlusSpoiler;
            AlignedSeqEvents.GzSpoilersCell = GzSpoilersCell;
            AlignedSeqEvents.ADC = ADC;
        end
        
        function RfPhasesRad = calculateRfPhasesRad(obj)
            nDummyScans = obj.protocol.nDummyScans;
            nSpokes = obj.protocol.nSpokes;
            nPartitions = obj.protocol.nPartitions;
            RfSpoilingIncrement = obj.protocol.RfSpoilingIncrement;
            
            nRfEvents = nDummyScans + nPartitions * nSpokes;
            index = 0:1:nRfEvents - 1;
            RfPhasesDeg = mod(0.5 * RfSpoilingIncrement * (index.^2 + index + 2), 360); % eq. (14.3) Bernstein 2004
            RfPhasesRad = RfPhasesDeg * pi / 180; % convert to radians.
        end
        
        function spokeAngles = calculateSpokeAngles(obj)
            %calculateSpokeAngles calculates the base spoke angles for one partition
            %depending on the number of spokes, angular ordering and the angle range.
            nSpokes = obj.protocol.nSpokes;
            angularOrdering = obj.protocol.angularOrdering;
            goldenAngleSequence = obj.protocol.goldenAngleSequence;
            angleRange = obj.protocol.angleRange;
            
            index = 0:1:nSpokes - 1;
            
            if strcmp(angularOrdering,'uniformAlternating')
                
                angularSamplingInterval = pi / nSpokes;
                spokeAngles = angularSamplingInterval * index; % array containing necessary angles for one partition
                spokeAngles(2:2:end) = spokeAngles(2:2:end) + pi; % add pi to every second spoke angle to achieved alternation
                
            else
                
                switch angularOrdering
                    case 'uniform'
                        angularSamplingInterval = pi / nSpokes;
                        
                    case 'goldenAngle'
                        tau = (sqrt(5) + 1) / 2; % golden ratio
                        N = goldenAngleSequence;
                        angularSamplingInterval = pi / (tau + N - 1);
                end
                
                spokeAngles = angularSamplingInterval * index; % array containing necessary angles for one partition
                
                switch angleRange
                    case 'fullCircle'
                        spokeAngles = mod(spokeAngles, 2 * pi); % projection angles in [0, 2*pi)
                    case 'halfCircle'
                        spokeAngles = mod(spokeAngles, pi); % projection angles in [0, pi)
                end
            end
        end
        
        function partitionRotationAngles = calculatePartitionRotationAngles(obj)
            %calculatePartitionRotationAngles calculates the angle offset across
            %partitions according to the parameter partitionRotation.
            nSpokes = obj.protocol.nSpokes;
            nPartitions = obj.protocol.nPartitions;
            partitionRotation = obj.protocol.partitionRotation;
            index = 0:1:nPartitions - 1;
            
            switch partitionRotation
                
                case 'aligned'
                    
                    partitionRotationAngles = zeros(1,nPartitions);
                    
                case 'linear'
                    
                    partitionRotationAngles = ( (pi / nSpokes) * (1 / nPartitions) ) * index;
                    
                case 'goldenAngle'
                    
                    partitionRotationAngles = ( (pi / nSpokes) * ((sqrt(5) - 1) / 2) ) * index;
                    partitionRotationAngles = mod(partitionRotationAngles, pi/nSpokes);
                    
            end
        end
        
        function [TE_min, TR_min, delayTE, delayTR] = calculateMinTeTrAndDelays(obj)
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            sequenceObject = mr.Sequence();
            AlignedSeqEvents = alignSeqEvents(obj);
            RF = AlignedSeqEvents.RF;
            GzCombinedCell = AlignedSeqEvents.GzCombinedCell;
            GxPre = AlignedSeqEvents.GxPre;
            GxPlusSpoiler = AlignedSeqEvents.GxPlusSpoiler;
            GzSpoilersCell = AlignedSeqEvents.GzSpoilersCell;
            ADC = AlignedSeqEvents.ADC;
            % add events for single TR with no delays 
            sequenceObject.addBlock(RF, GzCombinedCell{1},GxPre);
            sequenceObject.addBlock(GxPlusSpoiler, ADC, GzSpoilersCell{1});
            
            [duration, ~, ~]=sequenceObject.duration();
            [ktraj_adc, ~, t_excitation, ~, t_adc] = sequenceObject.calculateKspace();
            kabs_adc=sum(ktraj_adc.^2,1).^0.5;
            [~, index_echo]=min(kabs_adc);
            t_echo=t_adc(index_echo);
            t_ex_tmp=t_excitation(t_excitation<t_echo);
            TE_min=t_echo-t_ex_tmp(end);
            
            if (length(t_excitation)<2)
                TR_min=duration; % best estimate for now
            else
                t_ex_tmp1=t_excitation(t_excitation>t_echo);
                if isempty(t_ex_tmp1)
                    TR_min=t_ex_tmp(end)-t_ex_tmp(end-1);
                else
                    TR_min=t_ex_tmp1(1)-t_ex_tmp(end);
                end                
            end
            
            TE = obj.protocol.TE;
            TR = obj.protocol.TR;
                        
            delayTE = (TE - TE_min);
            delayTR = (TR - TR_min - delayTE);
            delayTE = gradRasterTime * round(delayTE/gradRasterTime);
            delayTR = gradRasterTime * round(delayTR/gradRasterTime);
        end
        
        
        function [allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(obj,scenario)
            if nargin < 2
                scenario = 'writing';            
            end
            viewOrder = obj.protocol.viewOrder;
            nSpokes = obj.protocol.nSpokes;
            nPartitions = obj.protocol.nPartitions;
            nDummyScans = obj.protocol.nDummyScans;
            spokeAngles = calculateSpokeAngles(obj);
            partRotAngles = calculatePartitionRotationAngles(obj);            
            switch scenario                
                case 'testing'
                    selectedDummies = obj.DUMMY_SCANS_TESTING;
                    switch viewOrder
                        case 'partitionsInOuterLoop'
                            selectedSpokes = nSpokes;
                            selectedPartitions = [1, nPartitions/2 + 1, nPartitions];
                        case 'partitionsInInnerLoop'
                            selectedSpokes = obj.SPOKES_TESTING_INNER;
                            selectedPartitions = 1:nPartitions;
                    end
                case 'writing'
                    selectedDummies = nDummyScans;
                    selectedSpokes = nSpokes;
                    selectedPartitions = 1:nPartitions;
            end
            counter = 1;
            angles = zeros(1, selectedSpokes * length(selectedPartitions));
            partitionIndx = zeros(1, selectedSpokes * length(selectedPartitions));
            switch viewOrder
                case 'partitionsInOuterLoop'
                    for iZ=selectedPartitions
                        for iR=1:selectedSpokes
                            angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                            partitionIndx(counter) = iZ;
                            counter = counter + 1;
                        end
                    end
                    
                case 'partitionsInInnerLoop'
                    for iR=1:selectedSpokes
                        for iZ=selectedPartitions
                            angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                            partitionIndx(counter) = iZ;
                            counter = counter + 1;
                        end
                    end
            end
            
            if selectedDummies > 0
                allAngles = [angles(1:selectedDummies) angles]; % replicate the first nDummyScans angles for the dummy scans
                allPartitionIndx = [partitionIndx(1:selectedDummies) partitionIndx]; % replicate the first partitionIndx indexes for the dummy scans
            else
                allAngles = angles;
                allPartitionIndx = partitionIndx;
            end
        end
        
        function sequenceObject = createSequenceObject(obj,scenario)
            if nargin < 2
                scenario = 'writing';            
            end
            isValidated = obj.protocol.isValidated;            
            if ~isValidated
                msg = 'The input parameters must be validated first.';
                error(msg)
            end            
            
            [allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(obj,scenario);            
            RfPhasesRad = calculateRfPhasesRad(obj);
            AlignedSeqEvents = alignSeqEvents(obj);
            RF = AlignedSeqEvents.RF;
            GzCombinedCell = AlignedSeqEvents.GzCombinedCell;
            GxPre = AlignedSeqEvents.GxPre;
            GxPlusSpoiler = AlignedSeqEvents.GxPlusSpoiler;
            GzSpoilersCell = AlignedSeqEvents.GzSpoilersCell;
            ADC = AlignedSeqEvents.ADC; 
            [~, ~, delayTE, delayTR] = calculateMinTeTrAndDelays(obj);
            % last alignement  
            GxPre.delay = GxPre.delay + delayTE;
            
            nDummyScans = obj.protocol.nDummyScans;
            switch scenario                
                case 'testing'
                    selectedDummies = obj.DUMMY_SCANS_TESTING;
                case'writing'
                    selectedDummies = nDummyScans;
            end
            
            sequenceObject = mr.Sequence();
            RFcounter = 1; % to keep track of the number of applied RF pulses.
            durationSecondBlock = delayTR + mr.calcDuration(GxPlusSpoiler, GzSpoilersCell{1});
            for iF = 1:length(allAngles)                
                iZ = allPartitionIndx(iF);
                RF.phaseOffset = RfPhasesRad(RFcounter);
                ADC.phaseOffset = RfPhasesRad(RFcounter);
                                
                    sequenceObject.addBlock( mr.rotate('z', allAngles(iF), RF, GzCombinedCell{iZ},GxPre) );
                if iF > selectedDummies % include ADC events
                    sequenceObject.addBlock( mr.rotate('z', allAngles(iF), GxPlusSpoiler, ADC, GzSpoilersCell{iZ}, mr.makeDelay(durationSecondBlock)) );                    
                else % no ADC event
                    sequenceObject.addBlock( mr.rotate('z', allAngles(iF), GxPlusSpoiler, GzSpoilersCell{iZ}, mr.makeDelay(durationSecondBlock)) );
                end 
                
                RFcounter = RFcounter + 1;                
            end 
        end
               
        function writeSequence(obj,scenario)
            if nargin < 2
                scenario = 'writing';            
            end
            viewOrder = obj.protocol.viewOrder;
            FOV = obj.protocol.FOV;
            slabThickness = obj.protocol.slabThickness;
            nSamples = obj.protocol.nSamples;
            obj.giveInfoAboutSequence
            sequenceObject = createSequenceObject(obj,scenario);
            
            if strcmp(scenario,'testing')
                fprintf('**Testing the sequence with: %s,\n',viewOrder);
                fprintf('  nDummyScans: %i\n',obj.DUMMY_SCANS_TESTING);                
                if strcmp(viewOrder,'partitionsInOuterLoop')
                    fprintf('  nSpokes: %i\n',nSamples);
                    fprintf('  partitions: first,central, and last\n\n');                                       
                else
                    fprintf('  nSpokes: %i\n',obj.SPOKES_TESTING_INNER);
                    fprintf('  Partitions: all\n\n');                    
                end
                giveTestingInfo(obj,sequenceObject);
            end
            
            sequenceObject.setDefinition('FOV', [FOV FOV slabThickness]);
            sequenceObject.setDefinition('Name', '3D_radial_stackOfStars');
            sequenceObject.write('3D_radial_stackOfStars.seq');
            saveInfo4Reco(obj);
            
            fprintf('## ...Done\n');            
        end
        
        function saveInfo4Reco(obj)
            info4Reco.FOV = obj.protocol.FOV;
            info4Reco.nSamples = obj.protocol.nSamples;
            info4Reco.nPartitions = obj.protocol.nPartitions;
            info4Reco.readoutOversampling = obj.protocol.readoutOversampling;
            info4Reco.nSpokes = obj.protocol.nSpokes;
            info4Reco.viewOrder = obj.protocol.viewOrder;
            info4Reco.spokeAngles = calculateSpokeAngles(obj);
            info4Reco.partitionRotationAngles = calculatePartitionRotationAngles(obj);
            save('info4RecoSoS.mat','info4Reco');
        end
        
        function giveTestingInfo(obj,sequenceObject)
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            
            sequenceObject.plot();
            % seq.sound();
            
            % trajectory calculation
            [ktraj_adc, ktraj, t_excitation, t_refocusing, t_adc] = sequenceObject.calculateKspace();
            
            % plot k-spaces
            time_axis = (1:(size(ktraj,2))) * gradRasterTime;
            figure; plot(time_axis, ktraj'); % plot the entire k-space trajectory
            hold; plot(t_adc,ktraj_adc(1,:),'.'); % and sampling points on the kx-axis
            figure; plot(ktraj(1,:),ktraj(2,:),'b'); % a 2D plot
            axis('equal'); % enforce aspect ratio for the correct trajectory display
            hold; plot(ktraj_adc(1,:),ktraj_adc(2,:),'r.'); % plot the sampling points
            
            % very optional slow step, but useful for testing during development e.g. for the real TE, TR or for staying within slewrate limits
            rep = sequenceObject.testReport;
            fprintf([rep{:}]);
        end
        
    end
    
    methods(Static)
        function giveInfoAboutSequence()
            fprintf('## Creating the sequence...\n');
            fprintf('**GzReph and GzPartition are merged.\n');
            fprintf('**G_readout and G_readoutSpoiler are merged.\n');
        end
   end
    
end




