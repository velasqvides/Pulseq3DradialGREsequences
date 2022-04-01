function validateResolution(obj)
%VALIDATERESOLUTON validate all the parameter for the in-plane resolution
% if neccesary this funciton also perform the changes in the parameters to
% keep, for instance, the max gradient values within the limits.
report = {sprintf('### Checking in-plane resolution ...\n')};

% ## fix FOV ##
if obj.FOV < obj.FOV_min
    report{end+1} = sprintf('**FOV =%6.3f is below lower limit %6.3f, FOV set to:%6.3f\n', ...
        obj.FOV, obj.FOV_min, obj.FOV_min);
    obj.FOV = obj.FOV_min;
elseif obj.FOV > obj.FOV_max
    report{end+1} = sprintf('**FOV =%6.3f is above upper limit %6.3f, FOV set to:%6.3f\n', ...
        obj.FOV, obj.FOV_max, obj.FOV_max);
    obj.FOV = obj.FOV_max;
end
obj.FOV = round(obj.FOV,3); %round to milimeters

% ## fix nSamples ##
toPrint = ' ';
nSamples_old = obj.nSamples;
if obj.nSamples < obj.nSamples_min
    toPrint = sprintf('**nSamples = %i is below lower limit %i, nSamples set to: %i\n', ...
        nSamples_old, obj.nSamples_min, obj.nSamples_min);
    obj.nSamples = obj.nSamples_min;
elseif obj.nSamples > obj.nSamples_max
    toPrint = sprintf('**nSamples = %i is above upper limit %i, nSamples set to: %i\n', ...
        nSamples_old, obj.nSamples_max, obj.nSamples_max);
    obj.nSamples = obj.nSamples_max;
end
% fix nSamples further to comply with the max spatialResolution
if obj.spatialResolution < obj.spatialResolution_max
    nSamples_new = floor(obj.FOV / obj.spatialResolution_max);
    toPrint = sprintf(['**nSamples = %i has to be changed to %i to keep the', ...
        ' spatial resolution above the limit:%5.4f\n'], ...
        nSamples_old, nSamples_new, obj.spatialResolution_max);
    obj.nSamples = nSamples_new;
end
if ~strcmp(' ',toPrint)
    report{end+1} = toPrint;
end

% ## fix bandwidthPerPixel ##
toPrint = ' ';
BWpixel_old = obj.bandwidthPerPixel;
if obj.bandwidthPerPixel < obj.bandwidthPerPixel_min
    toPrint = sprintf(['**bandwidthPerPixel = %4.0f Hz/pixel is below lower limit %4.0f Hz/pixel,'...
        ' bandwidthPerPixel set to: %i Hz/pixel\n'],...
        BWpixel_old, obj.bandwidthPerPixel_min, obj.bandwidthPerPixel_min);
    obj.bandwidthPerPixel = obj.bandwidthPerPixel_min;
elseif obj.bandwidthPerPixel > obj.bandwidthPerPixel_max
    toPrint = sprintf(['**bandwidthPerPixel = %4.0f Hz/pixel is above upper limit %4.0f Hz/pixel,'...
        'bandwidthPerPixel set to: %i Hz/pixel\n'],...
        BWpixel_old, obj.bandwidthPerPixel_max, obj.bandwidthPerPixel_max);
    obj.bandwidthPerPixel = obj.bandwidthPerPixel_max;
end
% fix bandwidthPerPixel further to comply wit the max gradient amplitude
maxGrad = obj.systemLimits.maxGrad;
if obj.readoutGradientAmplitude > maxGrad % maxGrad in Hertz
    approxDwellTime = 1/(maxGrad*obj.FOV*obj.readoutOversampling);
    % ceil is mandatory here to comply with both, ADCraster and
    % the calculaiton done above.
    dwellTime_new = obj.ADCrasterTime * ceil( approxDwellTime / obj.ADCrasterTime );
    BWpixel_new = 1/(dwellTime_new*obj.nSamples*obj.readoutOversampling);
    text1 = sprintf('**bandwidthPerPixel = %4.2f Hz/pixel was changed to %4.2f Hz/pixel',...
        obj.bandwidthPerPixel, BWpixel_new);
    text2 = sprintf('\n   to keep the maximum gradient amplitude below the limit:%6.3f mT/m\n',...
        mr.convert(maxGrad,'Hz/m','mT/m'));
    toPrint = append(text1,text2);
    obj.bandwidthPerPixel = BWpixel_new;
end
if ~strcmp(' ',toPrint)
    report{end+1} = toPrint;
end
tolerance = 0.05;
if abs(obj.bandwidthPerPixel - obj.realBandwidthPerPixel) > tolerance
    obj.bandwidthPerPixel = obj.realBandwidthPerPixel;
    report{end+1} = sprintf(['**Update: the exact bandwidthPerPixel (due to raster time'...
        ' constraints) will be %4.2f Hz/pixel\n'],obj.realBandwidthPerPixel);
end

if size(report,2) == 1
    report{end+1} = sprintf('All in-plane resolution parameters accepted\n');
end

report{end+1} = sprintf('###...Done.\n\n');
fprintf([report{:}]);

end % end of validate resolution

