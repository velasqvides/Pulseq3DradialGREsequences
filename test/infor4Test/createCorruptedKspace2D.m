function createCorruptedKspace2D(info4Reco)
customAngles = info4Reco.spokeAngles+info4Reco.partitionRotationAngles(1);
readoutSamples = info4Reco.nSamples*info4Reco.readoutOversampling;
nSpokes = info4Reco.nSpokes;
writecfl('customAngles',customAngles');
tCorrupted = bart(...
    sprintf('traj -x%i -y%i -r -c -C customAngles -q0.5:0.8:0.09 -O',...
        readoutSamples,nSpokes)); % traj with some delays
kCorrupted = bart('phantom -s3 -k -t',tCorrupted); 
writecfl(fullfile(pwd,'rawDataDecodedZ'),kCorrupted);
end

