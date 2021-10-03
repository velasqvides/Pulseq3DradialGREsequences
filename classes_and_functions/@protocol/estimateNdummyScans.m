function estimateNdummyScans(obj)
flipAngleRad = obj.flipAngle * pi / 180;
% Liang, Z. P., & Lauterbur, P. C. (2000). Principles of
% magnetic resonance imaging: a signal processing perspective.
% p. 299, eq. (9.22).
requieredDummyScans =  log( (obj.error)*(1 - exp(-obj.TR/obj.T1)) / (1 - cos(flipAngleRad)) ) /...
    log( cos(flipAngleRad) * exp(-obj.TR/obj.T1) );

requieredDummyScans = round(requieredDummyScans);
errorPercentage = obj.error * 100;

if obj.nDummyScans == requieredDummyScans
    fprintf('**The number of dummy scans seems to be optimal.\n\n')
else
    fprintf(['**For the current TR and flip angle, the Suggested', ...
        ' # of dummy scans to have a signal within\n'])
    fprintf('%4.2f%% of the steady-sate value is: %i. Current value: %i.\n\n', ...
        errorPercentage, requieredDummyScans,obj.nDummyScans)
end
end %end of estimateNdummyScans
        