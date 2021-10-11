function [RF, Gz, GzReph] = createSlabSelectionEvents(obj)
RfExcitation = obj.protocol.RfExcitation;
flipAngle = obj.protocol.flipAngle;
RfPulseDuration = obj.protocol.RfPulseDuration;
RfPulseApodization = obj.protocol.RfPulseApodization;
timeBwProduct = obj.protocol.timeBwProduct;
slabGradientAmplitude = obj.protocol.slabGradientAmplitude;
sys = obj.protocol.systemLimits;
gradRasterTime = sys.gradRasterTime;

switch RfExcitation
    case 'selectiveSinc'
        RF = mr.makeSincPulse(flipAngle*pi/180,sys,'Duration',RfPulseDuration,...
            'apodization',RfPulseApodization,'timeBwProduct',timeBwProduct);
        
        Gz = mr.makeTrapezoid('z', sys, 'Amplitude',slabGradientAmplitude,'FlatTime',...
            RfPulseDuration + gradRasterTime);
        
        GzRephArea = -(slabGradientAmplitude * RfPulseDuration)/2 - ...
            (Gz.fallTime*Gz.amplitude)/2 - gradRasterTime*slabGradientAmplitude;        
        GzReph = mr.makeTrapezoid('z', sys, 'Area', GzRephArea);
        
        if RF.delay > Gz.riseTime
            Gz.delay = ceil((RF.delay - Gz.riseTime)/gradRasterTime)*gradRasterTime; % round-up to gradient raster
        end
        if RF.delay < (Gz.riseTime + Gz.delay)
            RF.delay = Gz.riseTime + Gz.delay; % these are on the grad raster already which is coarser
        end
        
    case 'nonSelective'
        RF = mr.makeBlockPulse(flipAngle*pi/180,sys,'Duration',RfPulseDuration);
        Gz = []; GzReph = [];
end

end % end of createSlabSelectionEvents
