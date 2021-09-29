function [validTE, validTR ] = validateTEandTR(inputs, sys)
%This function will check if the current values for TE and TR are allowed.
% This based on the minimum and maximum TE and TR that are achievable with 
% the desired sequence events. The sequence events are calculated 
% internally here using the function createSequenceEvents.
% TE will be checked/fixed first, then TR will be accommodated according to TE
% Inputs
%   - inputs: a struct with input data containing TE, TR and necessary
%     information to create the sequence objects.
%   - sys: a struct with the system limits.
% Outputs
%   - feasible TE and TR limits
%   - feedback in command window with the correction of TE or TR

fprintf('\n\n### Checking TE and TR now...\n\n')
pause(1);

sequenceEvents = createSequenceEvents(inputs, sys);

RfExcitation = inputs.RfExcitation;
TE = inputs.TE; TR = inputs.TR;
[minTE, minTR] = calculateMinTeTr(sequenceEvents, RfExcitation, sys);

maxTR = 0.1; % arbitrary value, can be changed if desired.
[validTE, validTR ] = checkAndFixTEandTR(TE, TR, minTE, minTR, maxTR);

end


function [validTE, validTR ] = checkAndFixTEandTR(TE, TR, minTE, minTR, maxTR)
%This function check whether the provided values for TE and TR in the script
%are realizable or not.
% First some feedback about the valid range of values for TE and TR is provided
% in the command window, so the user can visualize them.
% First, TE will be checked, if the current values falls outside the range,
% TE will be fixed, e.g, set to lower limit in case TE < lower limit or set
% to upper limit in case TE > upper limit.
% Second, TR will be checked or fixed according to the current value of TE.

% Inputs:
% - scalar values for :TE, TR, minTE, minTR, maxTR
% Outputs:
% - feedback in the command window wit TE and TR limits.
% - Information in command window if any change of TE or TR was produced. 

TEms = TE * 1e3;    TRms = TR * 1e3;
minTEms = minTE * 1e3;  minTRms = minTR * 1e3;  maxTRms = maxTR * 1e3;
maxTE =  maxTR - (minTR - minTE);   maxTEms = maxTE * 1e3;

disp('Feasible TE and TR values in ms:')
formatSpec = '%6.3f <= TE <= %6.3f\n';
fprintf(formatSpec, minTEms , maxTEms );
formatSpec = '%6.3f <= TR <= %6.3f\n';
fprintf(formatSpec, minTRms, maxTRms);
formatSpec = 'with the constraint: TR >= TE +%6.3f\n';
fprintf(formatSpec,(minTRms - minTEms));
pause(1);

% Check or fix TE first
if TE + 2 * eps < minTE
    fprintf('\n**Current TE =%6.3f ms is below lower limit %6.3f ms. TE set to:%6.3f ms\n',TEms, minTEms, minTEms)
    pause(1);
    validTE = minTE;    
elseif TE > maxTE + 2 * eps
    fprintf('\n**Current TE =%6.3f ms is above upper limit %6.3f ms. TE set to:%6.3f ms\n',TEms, maxTEms, maxTEms)
    pause(1);
    validTE = maxTE;  
else
%     fprintf('\n## TE accepted ##')
%     pause(1);
    validTE = TE;
end
% Then check or fix TR
if TR > maxTR + 2 * eps
    fprintf('\n**Current TR =%6.3f ms is above upper limit %6.3f ms. TR set to:%6.3f ms\n',TRms, maxTRms, maxTRms)
    pause(1);
    validTR = maxTR;
elseif TR + 2 * eps < validTE + (minTR - minTE)
    fprintf('\n**The time difference between any valid TE and TR must be at least:%6.3f ms. TR set to:%6.3f ms\n',...
           (minTRms - minTEms), (validTE * 1e3 + (minTRms - minTEms)))
    pause(1);
    validTR = validTE + (minTR -minTE);
else
%     fprintf('\n## TR accepted ##\n')
%     pause(1);
    validTR = TR;
end

end
