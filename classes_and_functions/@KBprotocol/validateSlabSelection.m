function validateSlabSelection(obj)
report = {sprintf('### Checking slab selection parameters ...\n')};

% Check or fix timeBwProduct
toPrintTbw = ' ';
if obj.timeBwProduct < obj.timeBwProduct_min
    toPrintTbw = sprintf(['**time-bandwidth product = %i is below lower limit %i,'...
        ' timeBwProduct set to: %i\n'],...
        obj.timeBwProduct, obj.timeBwProduct_min, obj.timeBwProduct_min);
    obj.timeBwProduct = obj.timeBwProduct_min;
elseif obj.timeBwProduct > obj.timeBwProduct_max
    toPrintTbw = sprintf(['**time-bandwidth product = %i is above upper limit %i,'...
        ' timeBwProduct set to: %i\n'],...
        obj.timeBwProduct, obj.timeBwProduct_max, obj.timeBwProduct_max);
    obj.timeBwProduct = obj.timeBwProduct_max;
elseif mod(obj.timeBwProduct,2) ~= 0
    TBW_new = 2 * ceil(obj.timeBwProduct / 2);
    toPrintTbw = sprintf(['**time-bandwidth product = %i is not a multiple of 2,'...
        ' timeBwProduct set to: %i\n'],obj.timeBwProduct, TBW_new);
    obj.timeBwProduct = TBW_new;
end

% Check or fix RF pulse duration
toPrintRf = ' ';
RfPulseDuration_old = obj.RfPulseDuration;
if obj.RfPulseDuration < obj.RfPulseDuration_min
    toPrintRf = sprintf(['**RF pulse duration = %3.1f us is below lower limit %3.1f us,'...
        ' RfPulseDuration set to: %3.1f us\n'],...
        RfPulseDuration_old*1e6, obj.RfPulseDuration_min*1e6, obj.RfPulseDuration_min*1e6);
    obj.RfPulseDuration = obj.RfPulseDuration_min;
elseif obj.RfPulseDuration > obj.RfPulseDuration_max
    toPrintRf = sprintf(['**RF pulse duration = %3.1f us is above upper limit %3.1f us,'...
        ' RfPulseDuration set to: %3.1f us\n'],...
        RfPulseDuration_old*1e6, obj.RfPulseDuration_max*1e6, obj.RfPulseDuration_max*1e6);
    obj.RfPulseDuration = obj.RfPulseDuration_max;
end
% round the Rf pulse duration to the RF raster time (currently 1e-6 seconds)
rfRasterTime = obj.systemLimits.rfRasterTime;
obj.RfPulseDuration = rfRasterTime* round(obj.RfPulseDuration/rfRasterTime);

% fix the timeBwProduct further for the transmitterBandwidth to be between the limits
if obj.transmitterBandwidth < obj.transmitterBandwidth_min
    % to be sure timeBwProduct is multiple of 2
    TBW_new = 2 * ceil(obj.transmitterBandwidth_min * obj.RfPulseDuration / 2);
    text1 = sprintf('**timeBwProduct = %i was changed to %i',obj.timeBwProduct, TBW_new);
    text2 = sprintf('  to keep the transmiter bandwidth above the lower limit: %2.1f KHz\n',...
        obj.transmitterBandwidth_min*1e-3);
    toPrintTbw = append(text1, text2);
    obj.timeBwProduct = TBW_new;
elseif obj.transmitterBandwidth > obj.transmitterBandwidth_max
    % to be sure timeBwProduct is multiple of 2
    TBW_new = 2 * floor(obj.transmitterBandwidth_max * obj.RfPulseDuration / 2);
    text1= sprintf('**timeBwProduct = %i was changed to %i',obj.timeBwProduct, TBW_new);
    text2 = sprintf('  to keep the transmiter bandwidth below the upper limit: %3.0f KHz\n',...
        obj.transmitterBandwidth_max*1e-3);
    toPrintTbw = append(text1, text2);
    obj.timeBwProduct = TBW_new;
end
if ~strcmp(' ',toPrintTbw)
    report{end+1} = toPrintTbw;
end

% fix the the duration of the RF pulse further...
% for the amplitude of Gslab to be below  maxGradientAmplitude
if obj.slabGradientAmplitude > obj.systemLimits.maxGrad % maxGrad in Hertz
    RFduration_new = floor((obj.timeBwProduct / (obj.slabThickness * obj.systemLimits.maxGrad)),6);
    text1 = sprintf('**RfPulseDuration = %3.1f us was changed to %3.1f us',...
        RfPulseDuration_old*1e6, RFduration_new*1e6);
    text2 = sprintf('  to keep the maximum gradient amplitude below the limit: %2.0f mT/m\n',...
        mr.convert(obj.systemLimits.maxGrad,'Hz/m','mT/m'));
    toPrintRf = append(text1,text2);
    obj.RfPulseDuration = RFduration_new;
end
if ~strcmp(' ',toPrintRf)
    report{end+1} = toPrintRf;
end

if size(report,2) == 1
    report{end+1} = sprintf('All partition resolution parameters accepted\n');
end
report{end+1} = sprintf('###...Done.\n\n');
fprintf([report{:}]);
end % end of validateResolutionZ