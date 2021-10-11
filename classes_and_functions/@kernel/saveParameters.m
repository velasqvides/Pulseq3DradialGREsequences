function  saveParameters(obj)
properties = fieldnames(obj.protocol);
for ii = 1:length(properties)
    val = obj.protocol.(properties{ii});
    parameters.(properties{ii}) = val;
end
save('parameters.mat','parameters');
end
