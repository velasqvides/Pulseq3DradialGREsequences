function [TE_min, TR_min] = extractTEminTRmin(obj)
thisKBkernel = KBkernel(obj);
[TE_min, TR_min] = calculateMinTeTr(thisKBkernel);
end