function writeSequence(obj, fileName, scenario)
arguments
        obj (1,1) KBkernel        
        fileName string = '3D_koosh-ball'
        scenario string {mustBeMember(scenario, {'writing','testing'})} = 'writing'
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
sequenceObject.setDefinition('Name', fileName);
fileName = append(fileName,'.seq');
sequenceObject.write(fileName);

%save neccesary infor for the reocnstruction and save the protocol.  
saveInfo4Reco(obj);
saveParameters(obj);

fprintf('## ...Done\n');
end % end of writeSequence
