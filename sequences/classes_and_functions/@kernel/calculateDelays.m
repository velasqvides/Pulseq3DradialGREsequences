function [delayTE, delayTR] = calculateDelays(obj)
gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
TE = obj.protocol.TE;
TR = obj.protocol.TR;
[TE_min, TR_min] = calculateMinTeTr(obj);

delayTE = (TE - TE_min);
delayTE = gradRasterTime*round(delayTE/gradRasterTime);
delayTR = (TR - TR_min - delayTE);
delayTR = gradRasterTime*round(delayTR/gradRasterTime);
% next assertions modified from mr.makeDelay of pulseq
assert(isfinite(delayTE) & delayTE>=0,'calculateDelays:invalidDelayTE',...
    'DelayTE (%.2f ms) is invalid',delayTE*1e3);
assert(isfinite(delayTR) & delayTR>=0,'calculateDelays:invalidDelayTR',...
    'DelayTR (%.2f ms) is invalid',delayTR*1e3);
end % end of calculateDelays
