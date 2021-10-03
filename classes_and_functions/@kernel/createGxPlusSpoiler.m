function [GxPlusSpoiler,dispersionPerTR] = createGxPlusSpoiler(obj)
[Gx, GxPre, ~] = createReadoutEvents(obj);
phaseDispersionReadout = obj.protocol.phaseDispersionReadout;
systemLimits = obj.protocol.systemLimits;
spatialResolution = obj.protocol.spatialResolution;
gradRasterTime = obj.protocol.systemLimits.gradRasterTime;

areaGxAfterTE = Gx.area - abs(GxPre.area);
inherentDispersionAfterTE = obj.calculatePhaseDispersion(areaGxAfterTE,obj.protocol.spatialResolution);
if phaseDispersionReadout <= inherentDispersionAfterTE
    GxPlusSpoiler = Gx; % add no extra area
else
    areaSpoilingX = phaseDispersionReadout / (2 * pi * spatialResolution);
    extraAreaNeeded = areaSpoilingX - areaGxAfterTE;
    extraFlatTimeNeeded = gradRasterTime * round((extraAreaNeeded / Gx.amplitude)/ gradRasterTime);
    GxPlusSpoiler = mr.makeTrapezoid('x','amplitude',Gx.amplitude,'FlatTime', ...
        Gx.flatTime + extraFlatTimeNeeded,'system',systemLimits);
end
% since the extra flat time need to comply with the gradRaster time,
% the exact desired phase dispersion cant be acchieved, but it will be close enough.
dispersionPerTR = obj.calculatePhaseDispersion(GxPlusSpoiler.area-abs(GxPre.area), ...
    obj.protocol.spatialResolution);
end % end GxPlusSpoiler
