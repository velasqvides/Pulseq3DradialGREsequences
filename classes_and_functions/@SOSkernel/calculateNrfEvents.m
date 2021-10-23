function nRfEvents = calculateNrfEvents(obj)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
nDummyScans = obj.protocol.nDummyScans;
nSpokes = obj.protocol.nSpokes;
nPartitions = obj.protocol.nPartitions;

nRfEvents = nDummyScans + nPartitions * nSpokes;
end

