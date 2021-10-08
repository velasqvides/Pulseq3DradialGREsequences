function [allTheta, allPhi] = calculateAnglesForAllSpokes(obj,scenario)
if nargin < 2
    scenario = 'writing';
end

nSpokes = obj.protocol.nSpokes;
nDummyScans = obj.protocol.nDummyScans;
[thetaArray, phiArray] = calculateScanAngles(obj);
[thetaArrayPre, phiArrayPre] = calculatePreScanAngles(obj);

switch scenario
    case 'testing'
        selectedDummies = obj.DUMMY_SCANS_TESTING;
        if nSpokes > obj.SPOKES_TESTING
            selectedSpokes = obj.SPOKES_TESTING;
        else
            selectedSpokes = nSpokes;
        end
    case 'writing'
        selectedDummies = nDummyScans;
        selectedSpokes = nSpokes;
end

if selectedDummies > 0
    if selectedDummies > selectedSpokes % this will seldom happen
    excessDummies = selectedDummies - selectedSpokes;
    allTheta = [thetaArray(1:selectedSpokes) thetaArray(1:excessDummies) thetaArrayPre thetaArray(1:selectedSpokes)];
    allPhi = [phiArray(1:selectedSpokes) phiArray(1:excessDummies) phiArrayPre phiArray(1:selectedSpokes)];
    else
    allTheta = [thetaArray(1:selectedDummies) thetaArrayPre thetaArray(1:selectedSpokes)];
    allPhi = [phiArray(1:selectedDummies) phiArrayPre phiArray(1:selectedSpokes)];
    end
else
    allTheta = [thetaArrayPre thetaArray(1:selectedSpokes)];
    allPhi = [phiArrayPre phiArray(1:selectedSpokes)];
end

end % end of calculateAnglesForAllSpokes
