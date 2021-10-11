function writeSequence(obj, fileName, scenario)
arguments
        obj (1,1) SOSkernel        
        fileName string = '3D_stackOfStars'
        scenario string {mustBeMember(scenario, {'writing','testing'})} = 'writing'
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
sequenceObject.setDefinition('Name', fileName);
fileName = append(fileName,'.seq');
sequenceObject.write(fileName);

%save neccesary infor for the reocnstruction and save the protocol.  
saveInfo4Reco(obj);
saveParameters(obj);

fprintf('## ...Done\n');
end % end of writeSequence
