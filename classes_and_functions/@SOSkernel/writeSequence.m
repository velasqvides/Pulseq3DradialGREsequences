function writeSequence(obj,scenario)
if nargin < 2
    scenario = 'writing';
end
viewOrder = obj.protocol.viewOrder;
FOV = obj.protocol.FOV;
slabThickness = obj.protocol.slabThickness;
nSamples = obj.protocol.nSamples;

obj.giveInfoAboutSequence;
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
end % end of writeSequence
