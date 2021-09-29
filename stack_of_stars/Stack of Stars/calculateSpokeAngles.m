function spokeAngles = calculateSpokeAngles(nSpokes, angularOrdering, goldenAngleSequence, angleRange)
%calculateSpokeAngles calculates the base spoke angles for one partition
%depending on the number of spokes, angular ordering and the angle range.
%
% Inputs:
%   -nSpokes: number of spokes for each partition
%   -angularOrdering: a string with the following options: 'uniform',
%   'uniformAlternating','goldenAngle'
%   -goldenAngleSequence: in case that the angularOrdering is goldenAngle,
%   the goldenAngleSequence can be set to 1:goldenAngle, 2:smallGoldenAngle,
%   >2:tinyGoldenAngles
%   -angleRnage: 'fullCirlce': the angle can vary from 0 to 360 degrees,
%   halfCircle: the anlge can vary from 0 to 180 degrees.
% Outputs:
%   -spokesAngles: vector with the base spokes angles for all the spokes in one partition

index = 0:1:nSpokes - 1;

if strcmp(angularOrdering,'uniformAlternating')
    
    angularSamplingInterval = pi / nSpokes;
    spokeAngles = angularSamplingInterval * index; % array containing necessary angles for one partition
    spokeAngles(2:2:end) = spokeAngles(2:2:end) + pi; % add pi to every second spoke angle to achieved alternation
    
else
    
    switch angularOrdering
        case 'uniform'
            angularSamplingInterval = pi / nSpokes;
            
        case 'goldenAngle'
            tau = (sqrt(5) + 1) / 2; % golden ratio
            N = goldenAngleSequence;
            angularSamplingInterval = pi / (tau + N - 1);
    end
    
    spokeAngles = angularSamplingInterval * index; % array containing necessary angles for one partition
    
    switch angleRange
        case 'fullCircle'
            spokeAngles = mod(spokeAngles, 2 * pi); % projection angles in [0, 2*pi)
        case 'halfCircle'
            spokeAngles = mod(spokeAngles, pi); % projection angles in [0, pi)
    end
end

end
