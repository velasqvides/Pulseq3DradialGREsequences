function weights = calculate3DradialDCF(trajectory)
%calculateDCF calculates the density compensation function (DCF) for 3D 
%radial trajectories. 

% For radial 3D trajectories the Ram-Lak filter can be used as an
% analytic DCF:
% DFC = abs(k)^2/nSpokes, if abs(k) ~= 0  and 
%       1/(2*nSpokes)^2,  if abs(k)  = 0.
%
% Block, K. T. 
% Advanced Methods for Radial Data Sampling in Magnetic Resonance Imaging
% Doctoral Dissertation
% Georg-August-Universitat, Gottingen, 2008, p. 34
%
% Inputs: - 3D trajectory in 'BART' format.
%        
% Output: - DCF 
%
% This function uses BART commands to work, hence the BART tool has to be
% initialized before using this function. 

t = trajectory;
nSpokes = str2double(evalc("bart('show -d2',t)"));
nSamples =  str2double(evalc("bart('show -d1',t)"));
weights = zeros(1,nSamples,nSpokes);

for i = 1 : nSpokes
    for j = 1 : nSamples
    
        weights(1,j,i) = t(1,j,i)^2 + t(2,j,i)^2 + t(3,j,i)^2;
    
    end
end
weights = weights/nSpokes;
k = weights == 0;                                                              
weights(k) = (1 / (2 * nSpokes))^2; 

end

