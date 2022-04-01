function showSlabProfile(obj)
[RF, ~, ~] = createSlabSelectionEvents(obj);
[~,spectrum,w] = mr.calcRfBandwidth(RF, 0.5);
w = w/obj.protocol.slabGradientAmplitude*1000; %w from Hz to mm
spectrum = abs(spectrum)/max(abs(spectrum)); % normalized spectrum
slabSize = obj.protocol.slabSize*1e3;
figure; plot(w,spectrum,'linewidth',2); xlim([-slabSize-50,slabSize+50]);
xlabel('position /mm'); ylabel('Amplitude');
xline(-slabSize/2,'--r'); xline(slabSize/2,'--r');
title('Slab Profile');
end