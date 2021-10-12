function saveInfo4Reco(obj,fileName)
info4Reco.FOV = obj.protocol.FOV;
info4Reco.nSamples = obj.protocol.nSamples;
info4Reco.nPartitions = obj.protocol.nPartitions;
info4Reco.readoutOversampling = obj.protocol.readoutOversampling;
info4Reco.nSpokes = obj.protocol.nSpokes;
info4Reco.viewOrder = obj.protocol.viewOrder;
info4Reco.spokeAngles = calculateSpokeAngles(obj);
info4Reco.partitionRotationAngles = calculatePartitionRotationAngles(obj);
fileName = append('info4Reco_',fileName,'.mat');
save(fileName,'info4Reco');
end % end of saveInfo4Reco