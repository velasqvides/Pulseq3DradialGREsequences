function weights = densityCompVoronoi2D(traj)
%densityCompVoronoi calculates the density compensation function (DCF) for 2D 
%radial trajectories using voronoi diagrams. 
% This routine is modified from:
% J. A. Fessler. Matlab tomography toolbox, 2004. Available
% from http://www.eecs.umich.edu/∼fessler
% Only pieces of code for a voronoi-based density copensation were taken
%
% Inputs: - 2D trajectory in 'BART' format.
%        
% Output: - DCF 
%

nSpokes = size(traj,3);
nSamples = size(traj,2);
trajNewFormat = reformatTraj(traj,nSamples,nSpokes);
wi = ir_mri_density_comp(trajNewFormat);
weights = reshape(wi,[1,nSamples,nSpokes]);
end

function trajNewFormat = reformatTraj(traj,nSamples,nSpokes)
xPos = squeeze(traj(2,:,:));
yPos = squeeze(traj(1,:,:));
xPos = reshape(xPos,[nSamples*nSpokes,1]);
yPos = reshape(yPos,[nSamples*nSpokes,1]);
trajNewFormat = zeros(nSamples*nSpokes,2);
trajNewFormat(:,1) = xPos;
trajNewFormat(:,2) = yPos;
end

function wi = ir_mri_density_comp(trajectory)
%function wi = ir_mri_density_comp(kspace, dtype, varargin)
%| Compute density compensation factors for the conjugate phase
%| method for image reconstruction from Fourier samples.
%|
%| in
%|	kspace	[M 1]	kspace sample locations, e.g., spiral
%|	dtype	char	which density compensation method (see below)
%|			'voronoi', 'jackson', 'pipe', 'qian'
%| options
%|	G	?
%|	fix_edge 0|1|2	for voronoi, (default: 2 - 2nd-order poly extrapolation)
%| out
%|	wi	[M 1]	density compensation factors
%|
%| If voronoi, then "redundant" sampling at DC is corrected.
%| (But not if there are redundant samples at other locations in k-space.)
%|
%| Copyright 2003-7-29, Jeff Fessler, The University of Michigan
%| 2009-12-18, modified by Greg Lee to support pipe and jackson with table
wi = ir_mri_dcf_voronoi0(trajectory);
end
% ir_mri_dcf_voronoi0()
% in radial imaging, k-space origin is sampled multiple times, and
% this non-uniqueness messes up matlab's voronoi routine.
% here we find those "redundant" zeros and remove all but one them
% for the voronoi call.  We then restore them with appropriate DCF.
%
function wi = ir_mri_dcf_voronoi0(trajectory)
M = size(trajectory, 1);
i0 = sum(abs(trajectory), 2) == 0; % which points are at origin?
if sum(i0) > 1 % multiple DC points?
    i0f = find(i0);
    i0f = i0f(1); % keep the first zero point only
    i0(i0f) = false; % trick
    wi = zeros(M, 1);
    wi(~i0) = ir_mri_dcf_voronoi(trajectory(~i0,:));
    i0(i0f) = true; % trick
    wi(i0) = wi(i0f) / sum(i0); % distribute dcf equally
else
    wi = ir_mri_dcf_voronoi(trajectory);
end

% points at the outer edges of k-space have infinite voronoi cell area
% so are assigned wi=0 above.  To improve on 0, here we extrapolate
% based on the points near the edge.
% old way: look for points close to convex hull and use max of other points?
printm('trying to fix %d zeros of %d', sum(wi==0), M)
ii = false(size(wi));
fac = 0.98;
for id=1:ncol(trajectory) % find cartesian edges of k-space
    k = trajectory(:,id);
    ii = ii | (k > fac * max(k)) | (k < fac * min(k));
end
if ncol(trajectory) >= 2
    k = sqrt(trajectory(:,1).^2 + trajectory(:,2).^2);
    ii = ii | (k > fac * max(k)); % cylindrical edge
end
if ncol(trajectory) >= 3
    k = sqrt(trajectory(:,1).^2 + trajectory(:,2).^2 + trajectory(:,3).^2);
    ii = ii | (k > fac * max(k)); % spherical edge
end

pn = jf_protected_names;
wmax = 2 * pn.prctile(wi(~ii), 95); % fix: this is not working well
wi = min(wi, wmax);
wi(wi==0) = max(wi);


end

function wi = ir_mri_dcf_voronoi(trajectory)
M = size(trajectory, 1);

wi = zeros(M,1);
[v, c] = voronoin(double(trajectory));
nbad = 0;
for mm=1:M
	ticker([mfilename ' (voronoi)'], mm, M)
	x = v(c{mm},:);
	if ~any(isinf(x))
		try
			[~, wi(mm)] = convhulln(x); % cell area
		catch
%			printm('bad %d', mm)
			nbad = nbad + 1;
		end
	end
end
if nbad
	printm('bad edge points %d of %d', nbad, M)
end
end



