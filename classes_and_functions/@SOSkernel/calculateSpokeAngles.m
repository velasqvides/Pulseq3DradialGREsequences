function spokeAngles = calculateSpokeAngles(obj)
%calculateSpokeAngles calculates the base spoke angles for one partition
%depending on the number of spokes, angular ordering and the angle range.
nSpokes = obj.protocol.nSpokes;
angularOrdering = obj.protocol.angularOrdering;
goldenAngleSequence = obj.protocol.goldenAngleSequence;
angleRange = obj.protocol.angleRange;

index = 0:1:nSpokes - 1;

if strcmp(angularOrdering,'uniformAlternating')
    
    angularSamplingInterval = pi / nSpokes;
    % array containing necessary angles for one partition
    spokeAngles = angularSamplingInterval * index;
    % add pi to every second spoke angle to achieved alternation
    spokeAngles(2:2:end) = spokeAngles(2:2:end) + pi;
    
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
end % end of calculateSpokeAngles
