function [thetaArray, phiArray] = calculateScanAngles(obj)
nSpokes = obj.protocol.nSpokes;
angularOrdering = obj.protocol.angularOrdering;

switch angularOrdering
    case 'uniform'
        % see, Deserno, Markus. "How to generate equidistributed points on
        % the surface of a sphere." If Polymerforshung (Ed.) (2004): 99
        Ncount = 0;
        r = 1; % angles calculated based on an unit sphere
        a = 2 * pi * r^2 / nSpokes; % area_per_spoke of an hemisphere
        d = sqrt(a); % approximate the area_per_spoke as a 'square' of sides d, and get d.
        % get an estimate of polar angles requiered (number of latitudes)
        Mtheta = round((pi/2)/d);
        % get an approximate deltaTheta based on previous step to have uniform coverage
        deltaTheta = (pi/2)/Mtheta;
        % get an approximate deltaphi based on: area_per_spoke = deltatheta * deltaPhi.
        % To have uniform coverage in a spehere we need that delTatheta = delthaPhi
        deltaPhi = a/deltaTheta;
        % preallocate
        thetaArray = zeros(1,Mtheta);
        MphiArray = zeros(1,Mtheta);
        phiArray = [];
        for m = 0:Mtheta - 1
            theta = (pi/2) * (m + 0.5) / Mtheta; % ensure that the angles dont include 0 or 180
            thetaArray(m + 1) = theta; % save all the theta values in an array
            % increment the number of spokes per latitude in proportion to sin(theta)
            Mphi = round((2 * pi / deltaPhi) * sin(theta));
            MphiArray(m + 1) = Mphi;
            phiArrayTmp = zeros(1,Mphi);
            for n = 0:Mphi -1
                phi = 2 * pi * n / Mphi;
                phiArrayTmp(n + 1) = phi;
                Ncount = Ncount +1;
            end
            phiArray = [phiArray phiArrayTmp]; % collect all the phi angles
        end
        % repeat the theta values according to the number of spokes per latitude
        thetaArray = repelem(thetaArray, MphiArray);
        
        % The previous algorithm sometimes is not capable of allocate the
        % exact number of spokes, so in the next 'if' statement we compensate
        % that.
        if Ncount ~= nSpokes
            if nSpokes - Ncount > 0 % add more angles to compensate
                n = nSpokes - Ncount;
                extraPhi = 0;
                while n > 0
                    thetaArray(end + 1) = thetaArray(end); % stay in same latitude
                    phiArray(end + 1) = extraPhi; % start with phi = 0 and then increase a bit.
                    extraPhi = extraPhi + deltaPhi;
                    n = n - 1;
                end
            else % eliminate some angles to compensate
                n = Ncount - nSpokes;
                while n > 0
                    thetaArray = thetaArray(1 : end - 1);
                    phiArray = phiArray(1 : end - 1);
                    n = n - 1;
                end
            end
        end
        
    case 'goldenAngle'
        % see, Chan, Rachel W., et al. "Temporal stability of adaptive 3D
        % radial MRI using multidimensional golden means." (2009): 354-363.
        m = 1:1:nSpokes;
        phi1 = 0.4656; % first 2D golden angle to get seudorandom latitudes
        phi2 = 0.6823; % second 2D golden angle to get seudorandom locations in a circle
        phiArray = 2 * pi * mod(m * phi2, 1);
        thetaArray = acos(mod(m * phi1,1));
        %         thetaArray(end) = 0; % force the last spoke to be in z direction (I forced it arbitrarily)
end

end
