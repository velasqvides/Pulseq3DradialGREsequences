function SeqEvents = collectSequenceEvents(obj)
[RF, ~, ~] = createSlabSelectionEvents(obj);
GzCombinedCell = combineGzWithGzRephPlusPartitions(obj);
[Gx, GxPre, ADC] = createReadoutEvents(obj);
[GxPlusSpoiler,~] = createGxPlusSpoiler(obj);
[GzSpoilersCell, ~] = createGzSpoilers(obj);

SeqEvents.RF = RF;
SeqEvents.GzCombinedCell = GzCombinedCell;
SeqEvents.Gx = Gx;
SeqEvents.GxPre = GxPre;
SeqEvents.GxPlusSpoiler = GxPlusSpoiler;
SeqEvents.GzSpoilersCell = GzSpoilersCell;
SeqEvents.ADC = ADC;
end % end of collectSequenceEvents
