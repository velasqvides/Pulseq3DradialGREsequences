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
[delayTE, delayTR] = calculateDelays(obj);
% last alignement
GxPre.delay = GxPre.delay + delayTE;

switch scenario
    case 'testing'
        selectedDummies = obj.DUMMY_SCANS_TESTING;
    case'writing'
        selectedDummies = obj.protocol.nDummyScans;
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
        sequenceObject.addBlock( mr.rotate('z', allAngles(iF), GxPlusSpoiler, ADC, GzSpoilersCell{iZ}, ...
            mr.makeDelay(durationSecondBlock)) );
    else % no ADC event
        sequenceObject.addBlock( mr.rotate('z', allAngles(iF), GxPlusSpoiler, GzSpoilersCell{iZ}, ...
            mr.makeDelay(durationSecondBlock)) );
    end
    
    RFcounter = RFcounter + 1;
end
end % end of createSequenceObject
