function giveTestingInfo(obj,sequenceObject)
gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
TR = obj.protocol.TR;
DUMMY_SCANS_TESTING = obj.DUMMY_SCANS_TESTING;
N_PRESCANS = obj.N_PRESCANS;
initialRange = DUMMY_SCANS_TESTING + N_PRESCANS;

sequenceObject.plot('TimeRange',[initialRange initialRange+2]*TR);
% sequenceObject.plot();

% % trajectory calculation
% [ktraj_adc, ktraj, t_excitation, t_refocusing, t_adc] = sequenceObject.calculateKspace();
% 
% % plot k-spaces
% time_axis = (1:(size(ktraj,2))) * gradRasterTime;
% figure; plot(time_axis, ktraj'); % plot the entire k-space trajectory
% hold; plot(t_adc,ktraj_adc(1,:),'.'); % and sampling points on the kx-axis
% figure; plot(ktraj(1,:),ktraj(2,:),'b'); % a 2D plot
% axis('equal'); % enforce aspect ratio for the correct trajectory display
% hold; plot(ktraj_adc(1,:),ktraj_adc(2,:),'r.'); % plot the sampling points
% 
% % very optional slow step, but useful for testing during development e.g.
% % for the real TE, TR or for staying within slewrate limits
% rep = sequenceObject.testReport;
% fprintf([rep{:}]);
end % end of giveTestingInfo
