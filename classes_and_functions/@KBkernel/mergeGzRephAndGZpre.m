function mergedGZpre = mergeGzRephAndGZpre(obj, GzReph, GZpre)
%This function merges the area of GzReph and the modulated prepahsing
%gradient GZPre. The duration of GZPre (before modulation GxPre) is
%optimized to accept more area (this was done in the function
% createSequenceEvents lines 53-56).
% Inputs:
% - GZPre: modulated gradient from GxPre to be applied in Z direction.
% - GzReph: slice rephasing gradient applied in Z direction.
% Output:
% - mrgdGZPre: gradient which has the same area as the sum of the two inputs

sys = obj.protocol.systemLimits;

if isempty(GzReph)
    mergedGZpre = GZpre;
else
    GzRephArea = GzReph.area;
    GZpreArea = GZpre.area;    
    durationMergedGZpre = GZpre.riseTime + GZpre.flatTime + GZpre.fallTime;
    mergedGZpre = mr.makeTrapezoid('z',sys,'Area',GzRephArea + GZpreArea,'Duration',durationMergedGZpre);
    mergedGZpre.delay = mergedGZpre.delay + GZpre.delay;
end
end
