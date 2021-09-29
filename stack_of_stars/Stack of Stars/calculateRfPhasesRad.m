function RfPhasesRad = calculateRfPhasesRad(nDummyScans, nSpokes, RfSpoilingIncrement, Nz)
%This function calculates the RF phases for all the RF pulses needed in the
%sequence, which are equal to the number of spokes plus number of dummy scans.
% The Phase-cycling schedule is done as per Bernstein 2004, p.585 - 586
% Precalculating these values here, allow us to maintain the cycling when 
% passing from dummy scans to useful scans. 
% Inputs:
% - nSpokes, nDummyScans: scalars with number of dummy and useful spokes
% - RfSpoilingIncrement: scalar with RF phase incerement to be used in the
%                        phase-cycling schedule.
% -Nz: number of partitions. 
% Outputs:
% - RfPhasesRad: a vector with all the RF phases in radians.

nRfEvents = nDummyScans + Nz * nSpokes; 
index = 0:1:nRfEvents - 1;
RfPhasesDeg = mod(0.5 * RfSpoilingIncrement * (index.^2 + index + 2), 360); % eq. (14.3) Bernstein 2004
RfPhasesRad = RfPhasesDeg * pi / 180; % convert to radians.

end
