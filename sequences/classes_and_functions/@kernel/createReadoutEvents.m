function [Gx, GxPre, ADC] = createReadoutEvents(obj)
nSamples = obj.protocol.nSamples;
deltaKx = obj.protocol.deltaKx;
sys = obj.protocol.systemLimits;
readoutOversampling = obj.protocol.readoutOversampling;
dwellTime = obj.protocol.dwellTime;
readoutGradientAmplitude = obj.protocol.readoutGradientAmplitude;
readoutGradientFlatTime = obj.protocol.readoutGradientFlatTime;

Gx = mr.makeTrapezoid('x',sys,'Amplitude',readoutGradientAmplitude,'FlatTime',...
    readoutGradientFlatTime);
% here I include some area (the last term) to make the trayectory asymmetric
% and to measure the center ok k-space.
GxPreArea = -(nSamples * deltaKx)/nSamples*(floor(nSamples/2)) - ...
    (Gx.riseTime*Gx.amplitude)/2 - 0.5*dwellTime*readoutGradientAmplitude;
GxPre = mr.makeTrapezoid('x',sys,'Area',GxPreArea);
ADC = mr.makeAdc(nSamples * readoutOversampling,sys,'Dwell',dwellTime);
end % end of createReadoutEvents
