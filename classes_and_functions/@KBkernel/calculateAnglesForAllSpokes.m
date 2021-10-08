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
    allTheta = [thetaArray(1:selectedDummies) thetaArrayPre thetaArray(1:selectedSpokes)];
    allPhi = [phiArray(1:selectedDummies) phiArrayPre phiArray(1:selectedSpokes)];
else
    allTheta = [thetaArrayPre thetaArray(1:selectedSpokes)];
    allPhi = [phiArrayPre phiArray(1:selectedSpokes)];
end

end % end of calculateAnglesForAllSpokes
