function validateTEandTR(obj)
thisSOSkernel = SOSkernel(obj);
[TE_min, TR_min] = calculateMinTeTr(thisSOSkernel);
TE_max = obj.TR_max - (TR_min - TE_min);
gradRasterTime = obj.systemLimits.gradRasterTime;
% make sure TE and TR are multiples of the Gradient raster time
obj.TE = gradRasterTime*round(obj.TE/gradRasterTime);
obj.TR = gradRasterTime*round(obj.TR/gradRasterTime);
isTR_maxCorrect =(abs( obj.TR_max/gradRasterTime - round(obj.TR_max/gradRasterTime) ) < 1e-9);
assert(isTR_maxCorrect,['The constant property TR_max in Class Protocol seems to have changed,'...
    ' make sure this new value is multiple of (%.2f ms)\n'],gradRasterTime*1e3);


report = {sprintf('### Checking TE and TR values ...\n')};
report{end+1} = sprintf('Feasible TE and TR values in ms:\n');
report{end+1} = sprintf('%6.3f <= TE <= %6.3f\n',TE_min*1e3,TE_max*1e3);
report{end+1} = sprintf('%6.3f <= TR <= %6.3f, ',TR_min*1e3,obj.TR_max*1e3);
report{end+1} = sprintf('with the constraint: TR >= TE +%6.3f\n',(TR_min*1e3 - TE_min*1e3));

% Check or fix TE first
if obj.TE + 2 * eps < TE_min
    report{end+1} = sprintf(['**Current TE =%6.3f ms is below lower limit %6.3f ms,'...
        ' TE set to:%6.3f ms\n'],obj.TE*1e3, TE_min*1e3, TE_min*1e3);
    obj.TE = TE_min;
elseif obj.TE > TE_max + 2 * eps
    report{end+1} = sprintf(['**Current TE =%6.3f ms is above upper limit %6.3f ms,'...
        ' TE set to:%6.3f ms\n'],obj.TE*1e3, TE_max*1e3, TE_max*1e3);
    obj.TE = TE_max;
    
end
% Then check or fix TR
if obj.TR > obj.TR_max + 2 * eps
    report{end+1} = sprintf(['**Current TR =%6.3f ms is above upper limit %6.3f ms,'...
        ' TR set to:%6.3f ms\n'],obj.TR*1e3, obj.TR_max*1e3, obj.TR_max*1e3);
    obj.TR = obj.TR_max;
elseif obj.TR + 2 * eps < obj.TE + (TR_min - TE_min)
    report{end+1} = sprintf(['**The time difference between any valid TE and TR must'...
        ' be at least:%6.3f ms. TR set to:%6.3f ms\n'],...
        (TR_min - TE_min)*1e3, (obj.TE + (TR_min - TE_min))*1e3);
    obj.TR = obj.TE + (TR_min - TE_min);
end

if size(report,2) == 5
    report{end+1} = sprintf('TE and TR values accepted\n');
end
report{end+1} = sprintf('###...Done.\n\n');
fprintf([report{:}]);
end % end of validateTEandTR