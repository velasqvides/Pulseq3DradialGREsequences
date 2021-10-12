function [TE_min, TR_min] = extractTEminTRmin(obj)
thisSOSkernel = SOSkernel(obj);
[TE_min, TR_min] = calculateMinTeTr(thisSOSkernel);
end