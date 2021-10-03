function [TE_min, TR_min] = calculateMinTeTr(obj)
gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
singleTrKernel = createSingleTrKernel(obj);

[duration, ~, ~] = singleTrKernel.duration();
[ktraj_adc, ~, t_excitation, ~, t_adc] = singleTrKernel.calculateKspace();
kabs_adc = sum(ktraj_adc.^2,1).^0.5;
[~, index_echo] = min(kabs_adc);
t_echo = t_adc(index_echo);
t_ex_tmp = t_excitation(t_excitation<t_echo);
TE_min = t_echo-t_ex_tmp(end);

if (length(t_excitation)<2)
    TR_min=duration; % best estimate for now
else
    t_ex_tmp1=t_excitation(t_excitation>t_echo);
    if isempty(t_ex_tmp1)
        TR_min=t_ex_tmp(end)-t_ex_tmp(end-1);
    else
        TR_min=t_ex_tmp1(1)-t_ex_tmp(end);
    end
end

TE_min = gradRasterTime*ceil(TE_min/gradRasterTime);
TR_min = gradRasterTime*ceil(TR_min/gradRasterTime);
end % end of calculateMinTeTr(obj)
