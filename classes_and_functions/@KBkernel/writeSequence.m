function writeSequence(obj,scenario)
if nargin < 2
    scenario = 'writing';
end
FOV = obj.protocol.FOV;

obj.giveInfoAboutSequence;
sequenceObject = createSequenceObject(obj,scenario);

if strcmp(scenario,'testing') 
    fprintf('**Testing the sequence with:\n');
    fprintf('  nDummyScans: %i\n',obj.DUMMY_SCANS_TESTING); 
    fprintf('  nPreScans: %i\n',obj.N_PRESCANS);
    fprintf('  nSpokes: %i\n',obj.SPOKES_TESTING);   
    
    giveTestingInfo(obj,sequenceObject);
end

sequenceObject.setDefinition('FOV', [FOV FOV FOV]);
sequenceObject.setDefinition('Name', '3D_radial_koosh-ball');
sequenceObject.write('3D_radial_koosh-ball.seq');
saveInfo4Reco(obj);

fprintf('## ...Done\n');
end % end of writeSequence
