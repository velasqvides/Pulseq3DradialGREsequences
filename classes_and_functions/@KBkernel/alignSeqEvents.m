function AlignedSeqEvents = alignSeqEvents(obj)
SeqEvents = collectSequenceEvents(obj);
RF = SeqEvents.RF;
Gz = SeqEvents.Gz;
GzReph = SeqEvents.GzReph;
GxPreModified = SeqEvents.GxPreModified;
GxPlusSpoiler = SeqEvents.GxPlusSpoiler;
ADC = SeqEvents.ADC;
RfExcitation = obj.protocol.RfExcitation;
rfRingdownTime = obj.protocol.systemLimits.rfRingdownTime;

% 1. fix the first block 
if strcmp(RfExcitation,'selectiveSinc')
    GxPreModified.delay = GxPreModified.delay + mr.calcDuration(Gz);
else % nonSelective
    addDelay = mr.calcDuration(RF)- rfRingdownTime;
    GxPreModified.delay = GxPreModified.delay + addDelay;
end
% 2 fix the second block (GxPlusSpoiler, ADC, GzSpoilersCell)
% 2.1 add delay to the ADC event to appear at the same time as
% the flat region of Gx
ADC.delay = GxPlusSpoiler.riseTime;
% 2.2 add delay to GzSpoliers to appear just after the flat
% region of Gx

% return the aligned events in a struct, from here
AlignedSeqEvents.RF = RF;
AlignedSeqEvents.Gz = Gz;
AlignedSeqEvents.GzReph = GzReph;
AlignedSeqEvents.GxPreModified = GxPreModified;
AlignedSeqEvents.GxPlusSpoiler = GxPlusSpoiler;
AlignedSeqEvents.ADC = ADC;
end % end of alignSeqEvents
