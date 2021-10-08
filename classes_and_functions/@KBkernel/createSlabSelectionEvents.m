function [RF, Gz, GzReph] = createSlabSelectionEvents(obj)
RfExcitation = obj.protocol.RfExcitation;
flipAngle = obj.protocol.flipAngle;
RfPulseDuration = obj.protocol.RfPulseDuration;
slabThickness = obj.protocol.FOV;
RfPulseApodization = obj.protocol.RfPulseApodization;
timeBwProduct = obj.protocol.timeBwProduct;
systemLimits = obj.protocol.systemLimits;

switch RfExcitation
    case 'selectiveSinc'
        [RF, Gz, GzReph] = mr.makeSincPulse(flipAngle*pi/180,'Duration',RfPulseDuration,...
            'SliceThickness',slabThickness,'apodization',RfPulseApodization,...
            'timeBwProduct',timeBwProduct,'system',systemLimits);
        
    case 'nonSelective'
        RF = mr.makeBlockPulse(flipAngle*pi/180,systemLimits,'Duration',RfPulseDuration);
        Gz = []; GzReph = [];
end

end % end of createSlabSelectionEvents
