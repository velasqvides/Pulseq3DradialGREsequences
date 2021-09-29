function [minTE, minTR] = calculateMinTeTr(sequenceEvents, RfExcitation, sys)
%This function calculates minimum TE and TR that are achievable with the
%provided sequence events.
% Inputs
% - sequenceEvents: a struct with the desired sequence events (RF,Gz,etc)
% - RfExcitation: string with the type of RF excitation used
% - sys: a struct with the system limits.
% Outputs
% - minimum TE and TR values achievable with current sequence events.

% extract the required parameters and rename them conveniently.
RF = sequenceEvents.RF;
Gz = sequenceEvents.Gz;
GxPre = sequenceEvents.GxPre;
Gx = sequenceEvents.Gx;
GxSpoiler = sequenceEvents.GxSpoiler;
GxPlusSpoiler = sequenceEvents.GxPlusSpoiler;
gradRasterTime = sys.gradRasterTime;
rfRingdownTime = sys.rfRingdownTime;
% the following structures will always have elements (structures), so we take the first
% one for calculation since all of them have the same duration.
GzPartition = sequenceEvents.GzPartition(1);
GzRephPlusGzPartition = sequenceEvents.GzRephPlusGzPartition(1);
GzSpoiler = sequenceEvents.GzSpoiler(1);

% pre-calcualte half of Gx for minTE calculation.
halfGx = mr.calcDuration(Gx) / 2;

% In the next if's, only calculations are performed, no modifications to events.
% Calculate the time after GxPre, as we have 3 cases: 
if isempty(GxSpoiler) 
    % GzSpoiler can be applied after the flat area of Gx
    timeAfterGxPre = Gx.riseTime + Gx.flatTime + mr.calcDuration(GzSpoiler);
else 
    if isempty(GxPlusSpoiler) % gx and GxSpoiler are separated
        option1 = mr.calcDuration(Gx) + mr.calcDuration(GxSpoiler);
        option2 = mr.calcDuration(Gx) + mr.calcDuration(GzSpoiler);
        timeAfterGxPre = max(option1, option2);
    else % gx and GxSpoiler are bridged
        option1 =  mr.calcDuration(GxPlusSpoiler);
        option2 = Gx.riseTime + Gx.flatTime + mr.calcDuration(GzSpoiler);
        timeAfterGxPre = max(option1, option2);   
    end
end
  

switch RfExcitation
    case 'nonSelective'
        minTE = ceil( (mr.calcDuration(RF) - mr.calcRfCenter(RF) -...
            RF.delay + mr.calcDuration(GzPartition, GxPre) + halfGx)...
            / gradRasterTime ) * gradRasterTime;
        
        minTR = ceil( (mr.calcDuration(RF) + mr.calcDuration(GzPartition, GxPre) + ...
            timeAfterGxPre)...
            / gradRasterTime ) * gradRasterTime;
        
    case 'selectiveSinc'
        
        minTE = ceil( (Gz.flatTime/2 + max(Gz.fallTime, rfRingdownTime) +...
                mr.calcDuration(GzRephPlusGzPartition, GxPre) + halfGx)...
                / gradRasterTime ) * gradRasterTime;
        
        minTR = ceil( (mr.calcDuration(RF, Gz) +...
                mr.calcDuration(GzRephPlusGzPartition, GxPre) + timeAfterGxPre)...
                / gradRasterTime ) * gradRasterTime;
end

end
