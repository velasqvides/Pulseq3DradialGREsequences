function AlignedSeqEvents = alignSeqEvents(obj)
SeqEvents = collectSequenceEvents(obj);
RF = SeqEvents.RF;
GzCombinedCell = SeqEvents.GzCombinedCell;
Gx = SeqEvents.Gx;
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
% region of Gx
addDelay = Gx.riseTime + Gx.flatTime;
for kk=1:size(GzSpoilersCell,2)
    % GzSpoiler can appear after flat region of Gx in the same block
    GzSpoilersCell{kk}.delay = GzSpoilersCell{kk}.delay + addDelay;
end

% return the aligned events in a struct, from here
% Gx is not neccesary anymore,
AlignedSeqEvents.RF = RF;
AlignedSeqEvents.GzCombinedCell = GzCombinedCell;
AlignedSeqEvents.GxPre = GxPre;
AlignedSeqEvents.GxPlusSpoiler = GxPlusSpoiler;
AlignedSeqEvents.GzSpoilersCell = GzSpoilersCell;
AlignedSeqEvents.ADC = ADC;
end % end of alignSeqEvents
