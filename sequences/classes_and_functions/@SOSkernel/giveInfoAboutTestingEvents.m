function giveInfoAboutTestingEvents(obj)
viewOrder = obj.protocol.viewOrder;
nSamples = obj.protocol.nSamples;

fprintf('**Testing the sequence with: %s,\n',viewOrder);
fprintf('  nDummyScans: %i\n',obj.DUMMY_SCANS_TESTING);
if strcmp(viewOrder,'partitionsInOuterLoop')
    fprintf('  nSpokes: %i\n',nSamples);
    fprintf('  partitions: first,central, and last\n\n');
else
    fprintf('  nSpokes: %i\n',obj.SPOKES_TESTING_INNER);
    fprintf('  Partitions: all\n\n');
end
end