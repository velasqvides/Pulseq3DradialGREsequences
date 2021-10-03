function [allAngles, allPartitionIndx] = calculateAnglesForAllSpokes(obj,scenario)
if nargin < 2
    scenario = 'writing';
end
viewOrder = obj.protocol.viewOrder;
nSpokes = obj.protocol.nSpokes;
nPartitions = obj.protocol.nPartitions;
nDummyScans = obj.protocol.nDummyScans;
spokeAngles = calculateSpokeAngles(obj);
partRotAngles = calculatePartitionRotationAngles(obj);
switch scenario
    case 'testing'
        selectedDummies = obj.DUMMY_SCANS_TESTING;
        switch viewOrder
            case 'partitionsInOuterLoop'
                selectedSpokes = obj.SPOKES_TESTING_OUTER;
                selectedPartitions = [1, nPartitions/2 + 1, nPartitions];
            case 'partitionsInInnerLoop'
                selectedSpokes = obj.SPOKES_TESTING_INNER;
                selectedPartitions = 1:nPartitions;
        end
    case 'writing'
        selectedDummies = nDummyScans;
        selectedSpokes = nSpokes;
        selectedPartitions = 1:nPartitions;
end
counter = 1;
angles = zeros(1, selectedSpokes * length(selectedPartitions));
partitionIndx = zeros(1, selectedSpokes * length(selectedPartitions));
switch viewOrder
    case 'partitionsInOuterLoop'
        for iZ=selectedPartitions
            for iR=1:selectedSpokes
                angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                partitionIndx(counter) = iZ;
                counter = counter + 1;
            end
        end
        
    case 'partitionsInInnerLoop'
        for iR=1:selectedSpokes
            for iZ=selectedPartitions
                angles(counter) = spokeAngles(iR) + partRotAngles(iZ);
                partitionIndx(counter) = iZ;
                counter = counter + 1;
            end
        end
end

if selectedDummies > 0
    % replicate the first nDummyScans angles for the dummy scans
    allAngles = [angles(1:selectedDummies) angles];
    % replicate the first partitionIndx indexes for the dummy scans
    allPartitionIndx = [partitionIndx(1:selectedDummies) partitionIndx];
else
    allAngles = angles;
    allPartitionIndx = partitionIndx;
end
end % end of calculateAnglesForAllSpokes
