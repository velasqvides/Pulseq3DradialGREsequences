function nRfEvents = calculateNrfEvents(obj)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
nSpokes = obj.protocol.nSpokes;
nDummyScans = obj.protocol.nDummyScans;
nPreScans = obj.N_PRESCANS;

nRfEvents = nDummyScans + nSpokes + nPreScans;
end

