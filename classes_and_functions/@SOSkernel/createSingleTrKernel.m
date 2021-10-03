function singleTrKernel = createSingleTrKernel(obj)
AlignedSeqEvents = alignSeqEvents(obj);
RF = AlignedSeqEvents.RF;
GzCombinedCell = AlignedSeqEvents.GzCombinedCell;
GxPre = AlignedSeqEvents.GxPre;
GxPlusSpoiler = AlignedSeqEvents.GxPlusSpoiler;
GzSpoilersCell = AlignedSeqEvents.GzSpoilersCell;
ADC = AlignedSeqEvents.ADC;
singleTrKernel = mr.Sequence();
% add events for a single TR with no delays
singleTrKernel.addBlock(RF, GzCombinedCell{1},GxPre);
singleTrKernel.addBlock(GxPlusSpoiler, ADC, GzSpoilersCell{1});
end % end of createSingleTrKernel