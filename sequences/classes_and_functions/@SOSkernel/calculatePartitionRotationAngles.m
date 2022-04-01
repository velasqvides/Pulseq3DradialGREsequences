function partitionRotationAngles = calculatePartitionRotationAngles(obj)
%calculatePartitionRotationAngles calculates the angle offset across
%partitions according to the parameter partitionRotation.
nSpokes = obj.protocol.nSpokes;
nPartitions = obj.protocol.nPartitions;
partitionRotation = obj.protocol.partitionRotation;
index = 0:1:nPartitions - 1;

switch partitionRotation
    
    case 'aligned'
        
        partitionRotationAngles = zeros(1,nPartitions);
        
    case 'linear'
        
        partitionRotationAngles = ( (pi / nSpokes) * (1 / nPartitions) ) * index;
        
    case 'goldenAngle'
        
        partitionRotationAngles = ( (pi / nSpokes) * ((sqrt(5) - 1) / 2) ) * index;
        partitionRotationAngles = mod(partitionRotationAngles, pi/nSpokes);
        
end
end % end of calculatePartitionRotationAngles
