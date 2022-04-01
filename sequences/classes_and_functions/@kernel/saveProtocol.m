function  saveProtocol(obj)
properties = fieldnames(obj.protocol);
for ii = 1:length(properties)
    val = obj.protocol.(properties{ii});
    protocol.(properties{ii}) = val;
end
fileName = 'protocol.mat';
save(fileName,'protocol');
end
