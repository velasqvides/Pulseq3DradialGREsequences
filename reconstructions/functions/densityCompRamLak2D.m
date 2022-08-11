function weights = densityCompRamLak2D(traj)
%calculateDCF calculates the density compensation function (DCF) for 2D 
%radial trajectories using a Ram-Lak filter. 

% For radial 2D trajectories the Ram-Lak filter can be used as an
% analytic DCF:
% DFC = abs(k)/nSpokes, if abs(k) ~= 0  and 
%       1/(2*nSpokes),  if abs(k)  = 0.
%
% Block, K. T. 
% Advanced Methods for Radial Data Sampling in Magnetic Resonance Imaging
% Doctoral Dissertation
% Georg-August-Universitat, Gottingen, 2008, p. 34
%
% Inputs: - 2D trajectory in 'BART' format.
%        
% Output: - DCF 
%

nSpokes = size(traj,3);
nSamples = size(traj,2);
weights = zeros(1,nSamples,nSpokes);

for i = 1 : nSpokes
    for j = 1 : nSamples
        weights(1,j,i) = norm([traj(1,j,i), traj(2,j,i)]);
    end
end

weights = weights / nSpokes;
k = weights == 0;                                                              
weights(k) = 1 / (2*nSpokes); 

end
