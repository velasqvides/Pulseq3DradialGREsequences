function singleTrKernel = createSingleTrKernel(obj)
AlignedSeqEvents = alignSeqEvents(obj);
RF = AlignedSeqEvents.RF;
Gz = AlignedSeqEvents.Gz;
GzReph = AlignedSeqEvents.GzReph;
GxPreModified = AlignedSeqEvents.GxPreModified;
GxPlusSpoiler = AlignedSeqEvents.GxPlusSpoiler;
ADC = AlignedSeqEvents.ADC;
sys = obj.protocol.systemLimits;
RfExcitation = obj.protocol.RfExcitation;
singleTrKernel = mr.Sequence();
% add events for a single TR with no delays
[GXpre, GYpre, GZpre] = rotate3D(GxPreModified, pi/2, 0);
mergedGZpre = mergeGzRephAndGZpre(obj, GzReph, GZpre);
if strcmp(RfExcitation, 'selectiveSinc')
    GzCombined = mr.addGradients({Gz, mergedGZpre}, 'system', sys);
    singleTrKernel.addBlock(RF, GzCombined, GXpre, GYpre);
else
    singleTrKernel.addBlock(RF, mergedGZpre, GXpre, GYpre);
end
[GX, GY, GZ] = rotate3D(GxPlusSpoiler,  pi/2, 0);
singleTrKernel.addBlock(GX, GY, GZ, ADC);
end % end of createSingleTrKernel