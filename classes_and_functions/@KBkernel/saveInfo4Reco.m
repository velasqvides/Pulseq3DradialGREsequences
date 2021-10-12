function saveInfo4Reco(obj,fileName)

info4Reco.FOV = obj.protocol.FOV;
info4Reco.nSamples = obj.protocol.nSamples;
info4Reco.readoutOversampling = obj.protocol.readoutOversampling;
info4Reco.nSpokes = obj.protocol.nSpokes;
info4Reco.angularOrdering = obj.protocol.angularOrdering;
info4Reco.nPreScans = obj.N_PRESCANS;
[info4Reco.thetaArray, info4Reco.phiArray ] = calculateScanAngles(obj);
[info4Reco.thetaArrayPre, info4Reco.phiArrayPre] = calculatePreScanAngles(obj);
fileName = append('info4Reco_',fileName,'.mat');
save(fileName,'info4Reco');
end % end of saveInfo4Reco