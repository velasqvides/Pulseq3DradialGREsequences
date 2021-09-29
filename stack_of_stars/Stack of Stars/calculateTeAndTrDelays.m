function [delayTE, delayTR] = calculateTeAndTrDelays(TE, TR, minTE, minTR, sys)
%calculateTeAndTrDelays calculates the TE and TR delays needed to add some
%dead time in the sequence, in order to get the desired TE and TR 
%when they are not set to the minimum values.
% Inputs:
% - scalar values: TE, TR, minTE, minTR
% - sys: a struct with the system limits
% Outputs
% - scalar values delayTE and delayTR

gradRasterTime = sys.gradRasterTime;

delayTE = ceil( (TE - minTE) / gradRasterTime ) * gradRasterTime;
delayTR = ceil( (TR - minTR - delayTE) / gradRasterTime ) * gradRasterTime;

end

