function sequenceObject = createSequenceObject(obj,scenario)
if nargin < 2
    scenario = 'writing';
end
isValidated = obj.protocol.isValidated;
if ~isValidated
    msg = 'The input parameters must be validated first.';
    error(msg)
end

[allTheta, allPhi] = calculateAnglesForAllSpokes(obj,scenario);
RfPhasesRad = calculateRfPhasesRad(obj);
AlignedSeqEvents = alignSeqEvents(obj);
RF = AlignedSeqEvents.RF;
Gz = AlignedSeqEvents.Gz;
GzReph = AlignedSeqEvents.GzReph;
GxPreModified = AlignedSeqEvents.GxPreModified;
GxPlusSpoiler = AlignedSeqEvents.GxPlusSpoiler;
ADC = AlignedSeqEvents.ADC;
[delayTE, delayTR] = calculateDelays(obj);
RfExcitation = obj.protocol.RfExcitation;
sys = obj.protocol.systemLimits;

switch scenario
    case 'testing'
        selectedDummies = obj.DUMMY_SCANS_TESTING;
    case'writing'
        selectedDummies = obj.protocol.nDummyScans;
end

sequenceObject = mr.Sequence();
RFcounter = 1; % to keep track of the number of applied RF pulses.
durationFirstBlock = delayTE + mr.calcDuration(GxPreModified);
durationSecondBlock = delayTR + mr.calcDuration(GxPlusSpoiler);
for iF = 1:length(allTheta)
    RF.phaseOffset = RfPhasesRad(RFcounter);
    ADC.phaseOffset = RfPhasesRad(RFcounter);
    
    [GXpre, GYpre, GZpre] = rotate3D(GxPreModified, allTheta(iF), allPhi(iF));
    mergedGZpre = mergeGzRephAndGZpre(obj, GzReph, GZpre);    
    if strcmp(RfExcitation, 'selectiveSinc')
        GzCombined = mr.addGradients({Gz, mergedGZpre}, 'system', sys);
        sequenceObject.addBlock(RF, GzCombined, GXpre, GYpre, mr.makeDelay(durationFirstBlock));
    else
        sequenceObject.addBlock(RF, mergedGZpre, GXpre, GYpre, mr.makeDelay(durationFirstBlock));
    end
    [GX, GY, GZ] = rotate3D(GxPlusSpoiler, allTheta(iF), allPhi(iF));
    if iF > selectedDummies % include ADC events 
        sequenceObject.addBlock( GX, GY, GZ, ADC, mr.makeDelay(durationSecondBlock) );
    else % no ADC event
        sequenceObject.addBlock( GX, GY, GZ, mr.makeDelay(durationSecondBlock) );
    end
    
    RFcounter = RFcounter + 1;
end
end % end of createSequenceObject
