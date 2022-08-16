function writeSequence(obj, fileName, scenario, debugLevel)
arguments
    obj (1,1) kernel
    fileName string 
    scenario string {mustBeMember(scenario, {'writing','testing'})} = 'writing'
    debugLevel (1,1) {mustBeNumeric, mustBeMember(debugLevel, [1, 2, 3])} = 3
end
    
FOV = obj.protocol.FOV;
slabSize = obj.protocol.slabSize;

fprintf('## Creating the sequence...\n');

obj.giveInfoAboutMergedEvents;
sequenceObject = createSequenceObject(obj,scenario);

if strcmp(scenario,'testing') 
    giveInfoAboutTestingEvents(obj);
    giveTestReportAndPlots(obj,sequenceObject,debugLevel);
end

sequenceObject.setDefinition('FOV', [FOV FOV slabSize]);
sequenceObject.setDefinition('Name', fileName);
currentFolder = cd;
cd ('generated_seq_files');
mkdir(fileName);
cd (fileName);
fileName2 = append(fileName,'_',scenario,'.seq');
sequenceObject.write(fileName2);

%save neccesary infor for the reocnstruction and save the protocol. 
saveProtocol(obj);
saveInfo4Reco(obj);
cd(currentFolder);
fprintf('## ...Done\n');
end % end of writeSequence
