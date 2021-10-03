function saveInfo4Reco(obj)
info4Reco.FOV = obj.protocol.FOV;
info4Reco.nSamples = obj.protocol.nSamples;
info4Reco.nPartitions = obj.protocol.nPartitions;
info4Reco.readoutOversampling = obj.protocol.readoutOversampling;
info4Reco.nSpokes = obj.protocol.nSpokes;
info4Reco.viewOrder = obj.protocol.viewOrder;
info4Reco.spokeAngles = calculateSpokeAngles(obj);
info4Reco.partitionRotationAngles = calculatePartitionRotationAngles(obj);
save('info4RecoSoS.mat','info4Reco');
end % end of saveInfo4Reco