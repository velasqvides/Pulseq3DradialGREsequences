function RfPhasesRad = calculateRfPhasesRad(obj)
nDummyScans = obj.protocol.nDummyScans;
nSpokes = obj.protocol.nSpokes;
nPartitions = obj.protocol.nPartitions;
RfSpoilingIncrement = obj.protocol.RfSpoilingIncrement;

nRfEvents = nDummyScans + nPartitions * nSpokes;
index = 0:1:nRfEvents - 1;
% eq. (14.3) Bernstein 2004
RfPhasesDeg = mod(0.5 * RfSpoilingIncrement * (index.^2 + index + 2), 360);
RfPhasesRad = RfPhasesDeg * pi / 180; % convert to radians.
end % end of calculateRfPhasesRad