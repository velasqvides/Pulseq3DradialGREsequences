function estimateNdummyScans(TR,alpha,T1,error,nDummyScans)
%estimateNdummyScans estimtates the number of dummy scans that are requiered
% "to drive a spin system to the steady state within an acceptable error".
% The formula is taken from the following book:

% Liang, Z. P., & Lauterbur, P. C. (2000). Principles of magnetic resonance imaging: 
% a signal processing perspective. SPIE Optical Engineering Press, p. 299,
% eq. (9.22).
%
% Inputs:
%    - Current TR, flip angle (alpha), T1 of the tissue to be scanned,
%    normalized error between the longitudinal magnetization and the
%    steady-state value, nDummyScans to compared estimated value and current value. 
% Outputs:
%   - Suggestion in the commnad window about the estimated number of dummy
%   scans reqwuiered givent he input values. 
%
% This function onyl brings a suggestion but does not change the value of the
% nDummyScans.

alphaRad = alpha * pi / 180;
% eq. (9.22) of the book.
requieredDummyScans =  log( (error) * (1 - exp(-TR/T1)) / (1 - cos(alphaRad)) ) /...
               log(cos(alphaRad) * exp(-TR/T1));
           
requieredDummyScans = round(requieredDummyScans);
error = error * 100;

if nDummyScans ~= requieredDummyScans
    fprintf('\n**For the current TR and flip angle, the Suggested # of dummy scans to have a signal within\n')
    fprintf('%4.2f%% of the steady-sate value is: %i. Current value: %i.\n\n',error, requieredDummyScans,nDummyScans)
end

end


