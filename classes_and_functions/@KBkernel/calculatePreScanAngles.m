function [thetaArrayPre, phiArrayPre] = calculatePreScanAngles(obj)
%calculatePreScanAngles calculate the angles for the pre scan, which will
% be use to calculate the gradient delays. 
%   The current procedure is as follows;
% The number of pre scans will be divided into three parts for the 3
% different orthogonal planes x-y, z-x, z-y, and then, each set of spokes will be
% further divide into another three parts. For instance, if nPreScans=360,
% then we will have 120 spokes per plane, and then those 120 spokes will be
% divided in three sets of 40 each. 
% The first 40 spokes for each plane will follow the same direction as the current 
% implementation, then the next 40 spokes will be in opposite direction (+180 degrees) and the last
% set of 40 spokes will be ortoghonal to the first ones (+90 degrees).
% The antiparallel spokes will serve to calculate the gradient delays
% using the AC-Adaptive method, and the orthogonal ones are requiered to
% calculate the delays using the RING method.
% We used the first spokes angles from the current implemenatition to 
% induce similar eddy current effects in the pre scan.

% INPUTS:
%       -theta and phi arrays from the current implementation (uniform or 
%        2D golden angles)
%       -nPreScans: scalar with the desired number of pre scans, we
%       recommend nPreScans >= 45 to have at least 15 spokes per plane 
%       (5 taken form the current implementation, 5 antiparallel and 5
%       orthogonal) and the number of pre scan being divisible by 9 to
%       assign the spokes evenly into the three planes.
% OUTPUT:
%       - theta and phi arrays for all the pre scans  
[thetaArray, phiArray] = calculateScanAngles(obj);
assert(obj.N_PRESCANS >= 45 && mod(obj.N_PRESCANS, 9) == 0);

thetaArrayPre = zeros(1, obj.N_PRESCANS);
phiArrayPre = zeros(1, obj.N_PRESCANS);
n = obj.N_PRESCANS / 9;

% plane x-y
thetaArrayPre(1:3*n) = pi / 2; % all spokes in plane x-y have theta=90 deg
phiArrayPre(1:n) = phiArray(1:n); % take first phi's from current implementation
phiArrayPre(n+1:2*n) = phiArray(1:n) + pi; % antiparallel spokes
phiArrayPre(2*n+1:3*n) = phiArray(1:n) + pi / 2; % orthogonal spokes

% plane z-x (in bart it will be x-z)
phiArrayPre(3*n+1:6*n) = 0; % all spokes in plane z-x have phi=0 deg
thetaArrayPre(3*n+1:4*n) = thetaArray(1:n);
thetaArrayPre(4*n+1:5*n) = thetaArray(1:n) + pi;
thetaArrayPre(5*n+1:6*n) = thetaArray(1:n) + pi / 2;

% plane z-y (in bart it will be y-z)
phiArrayPre(6*n+1:9*n) = pi /2; % all spokes in plane z-y have phi=90 deg
thetaArrayPre(6*n+1:7*n)=thetaArray(1:n);
thetaArrayPre(7*n+1:8*n)=thetaArray(1:n) + pi;
thetaArrayPre(8*n+1:9*n)=thetaArray(1:n) + pi /2;

% 2*pi module of the angles
thetaArrayPre = mod(thetaArrayPre,2*pi);
phiArrayPre = mod(phiArrayPre,2*pi);

end
