function giveTestReportAndPlots(obj,sequenceObject)
TR = obj.protocol.TR;
DUMMY_SCANS_TESTING = obj.DUMMY_SCANS_TESTING;
N_PRESCANS = obj.N_PRESCANS;
initialRange = DUMMY_SCANS_TESTING + N_PRESCANS;

sequenceObject.plot('TimeRange',[initialRange initialRange+2]*TR);
% sequenceObject.plot();

% trajectory calculation
[ktraj_adc, ktraj, ~, ~, ~] = sequenceObject.calculateKspace();

figure; 
plot3(ktraj(1,:),ktraj(2,:),ktraj(3,:),'b'); % a 2D plot
axis('equal'); % enforce aspect ratio for the correct trajectory display
hold; plot3(ktraj_adc(1,:),ktraj_adc(2,:),ktraj_adc(3,:),'r.'); % plot the sampling points
title('k-space trajectory')
xlabel('k_x'); ylabel('k_y'); zlabel('k_z');
% 
% % very optional slow step, but useful for testing during development e.g.
% % for the real TE, TR or for staying within slewrate limits
% rep = sequenceObject.testReport;
% fprintf([rep{:}]);
end % end of giveTestingInfo
