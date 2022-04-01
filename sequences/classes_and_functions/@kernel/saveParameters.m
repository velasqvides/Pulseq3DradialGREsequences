function  saveParameters(obj,fileName)
properties = fieldnames(obj.protocol);
for ii = 1:length(properties)
    val = obj.protocol.(properties{ii});
    parameters.(properties{ii}) = val;
end
fileName = append('parameters_',fileName,'.mat');
save(fileName,'parameters');
end
