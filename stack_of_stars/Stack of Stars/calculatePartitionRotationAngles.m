function partitionRotationAngles = calculatePartitionRotationAngles(nSpokes,Nz,partitionRotation)
%calculatePartitionRotationAngles calculates the angle offset across
%partitions according to the parameter partitionRotation.
%
% Inputs:
%   -nSpokes: number of spokes for each partition
%   -Nz: number of partitions
%   -partitionRotation: 'aligned', 'linear', or 'goldenAngle'%   
% Outputs:
%   -partitionRotationAngles: vector with the partition rotation angles for
%   all the partitions.

% Zhou, Z.; Han, F.; Yan, L.; Wang, D. J. & Hu, P.
% Golden-ratio rotated stack-of-stars acquisition for improved volumetric MRI
% Magnetic resonance in medicine, Wiley Online Library, 2017, 78, 2290-2298

index = 0:1:Nz - 1;

switch partitionRotation
    
    case 'aligned'
        
        partitionRotationAngles = zeros(1,Nz);
        
    case 'linear'
        
        partitionRotationAngles = ( (pi / nSpokes) * (1 / Nz) ) * index;
        
    case 'goldenAngle'
        
        partitionRotationAngles = ( (pi / nSpokes) * ((sqrt(5) - 1) / 2) ) * index;
        partitionRotationAngles = mod(partitionRotationAngles, pi/nSpokes);
        
end

end
