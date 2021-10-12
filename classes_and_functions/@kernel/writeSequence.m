function writeSequence(obj, fileName, scenario)
arguments
    obj (1,1) kernel
    fileName string 
    scenario string {mustBeMember(scenario, {'writing','testing'})} = 'writing'
end
    
FOV = obj.protocol.FOV;
slabSize = obj.protocol.slabSize;

fprintf('## Creating the sequence...\n');

obj.giveInfoAboutMergedEvents;
sequenceObject = createSequenceObject(obj,scenario);

if strcmp(scenario,'testing') 
    giveInfoAboutTestingEvents(obj);
    giveTestReportAndPlots(obj,sequenceObject);
end

sequenceObject.setDefinition('FOV', [FOV FOV slabSize]);
sequenceObject.setDefinition('Name', fileName);
fileName2 = append(fileName,'_',scenario,'.seq');
sequenceObject.write(fileName2);

%save neccesary infor for the reocnstruction and save the protocol.  
saveInfo4Reco(obj,fileName);
saveParameters(obj,fileName);

fprintf('## ...Done\n');
end % end of writeSequence
