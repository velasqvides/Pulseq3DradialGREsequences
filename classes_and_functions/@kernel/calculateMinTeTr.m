function [TE_min, TR_min] = calculateMinTeTr(obj)
gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
singleTrKernel = createSingleTrKernel(obj);

% calculate TE and TR

[duration, ~, ~]=singleTrKernel.duration();

%[ktraj_adc, ktraj, t_excitation, t_refocusing, t_adc] = obj.calculateKspace();
%[ktraj_adc, t_adc, ktraj, t_ktraj, t_excitation, t_refocusing] = obj.calculateKspacePP();
[ktraj_adc, t_adc, ~, ~, t_excitation, ~] = singleTrKernel.calculateKspacePP();

% trajectory calculation will fail for spin-echoes if seq is loaded from a 
% file for the current file format revision (1.2.0) because we do not store 
% the use of the RF pulses. Read function has an option 'detectRFuse' which
% may help...

%        
kabs_adc=sum(ktraj_adc.^2,1).^0.5;
[kabs_echo, index_echo]=min(kabs_adc);
t_echo=t_adc(index_echo); % just a first estimate, see if we can improve it
if kabs_echo>eps
    i2check=[];
    % check if adc kspace trajectory has elements left and right to index_echo
    if index_echo > 1
        i2check=[i2check (index_echo-1)];
    end
    if index_echo < length(kabs_adc)
        i2check=[i2check (index_echo+1)];
    end
    for a=1:numel(i2check)
        v_i_to_0=-ktraj_adc(:,index_echo);
        v_i_to_t=ktraj_adc(:,i2check(a))-ktraj_adc(:,index_echo);
        % project v_i_to_0 to v_o_to_t
        p_vit=v_i_to_0'*v_i_to_t/(vecnorm(v_i_to_t)^2);
        if p_vit>0
            % we have forund a bracket for the echo and the proportionality
            % coefficient is p_vit
            t_echo=t_adc(index_echo)*(1-p_vit) + t_adc(i2check(a))*p_vit;
            break;
        end
    end
end

t_ex_tmp=t_excitation(t_excitation<t_echo);
TE_min=t_echo-t_ex_tmp(end);
% TODO detect multiple TEs

if (length(t_excitation)<2)
    TR_min=duration; % best estimate for now
else
    t_ex_tmp1=t_excitation(t_excitation>t_echo);
    if isempty(t_ex_tmp1)
        TR_min=t_ex_tmp(end)-t_ex_tmp(end-1);
    else
        TR_min=t_ex_tmp1(1)-t_ex_tmp(end);
    end
    % TODO check frequency offset to detect multiple slices
end

TE_min = gradRasterTime*ceil(TE_min/gradRasterTime);
TR_min = gradRasterTime*ceil(TR_min/gradRasterTime);
end % end of calculateMinTeTr(obj)
