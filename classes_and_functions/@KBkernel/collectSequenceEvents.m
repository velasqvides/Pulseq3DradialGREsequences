function SeqEvents = collectSequenceEvents(obj)
[RF, Gz, GzReph] = createSlabSelectionEvents(obj);
[~, ~, ADC] = createReadoutEvents(obj);
GxPreModified = modifyDurationGxPre(obj);
[GxPlusSpoiler,~] = createGxPlusSpoiler(obj);


SeqEvents.RF = RF;
SeqEvents.Gz = Gz;
SeqEvents.GzReph = GzReph;
SeqEvents.GxPreModified = GxPreModified;
SeqEvents.GxPlusSpoiler = GxPlusSpoiler;
SeqEvents.ADC = ADC;
end % end of collectSequenceEvents
