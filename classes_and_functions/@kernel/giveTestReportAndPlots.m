function giveTestReportAndPlots(obj,sequenceObject,debugLevel)
TR = obj.protocol.TR;
DUMMY_SCANS_TESTING = obj.DUMMY_SCANS_TESTING;
N_PRESCANS = obj.N_PRESCANS;
initialRange = DUMMY_SCANS_TESTING + N_PRESCANS;

if ismember(debugLevel,[1, 2, 3])
    sequenceObject.plot();
end
if ismember(debugLevel,[2, 3])
    sequenceObject.plot('TimeRange',[initialRange initialRange+2]*TR);
end

% trajectory calculation
[ktraj_adc, ktraj, ~, ~, ~] = sequenceObject.calculateKspace();
if ismember(debugLevel,[1, 2, 3])
    figure;
    plot3(ktraj(1,:),ktraj(2,:),ktraj(3,:),'b'); % a 3D plot
    axis('equal'); % enforce aspect ratio for the correct trajectory display
    hold; plot3(ktraj_adc(1,:),ktraj_adc(2,:),ktraj_adc(3,:),'r.'); % plot the sampling points
    title('k-space trajectory')
    xlabel('k_x /m^-^1'); ylabel('k_y /m^-^1'); zlabel('k_z /m^-^1');
end
if ismember(debugLevel,[2, 3])
    firstADCpoints = obj.protocol.nSamples*obj.protocol.readoutOversampling;
    figure;
    plot(ktraj(1,1:firstADCpoints),ktraj(2,1:firstADCpoints),'b'); % a 2D plot
    axis('equal'); % enforce aspect ratio for the correct trajectory display
    hold; plot(ktraj_adc(1,1:firstADCpoints),ktraj_adc(2,1:firstADCpoints),'r.'); % plot the sampling points
    title('k-space trajectory')
    xlabel('k_x /m^-^1'); ylabel('k_y /m^-^1');
end
if debugLevel == 3
    % very optional slow step, but useful for testing during development e.g.
    % for the real TE, TR or for staying within slewrate limits
    rep = sequenceObject.testReport;
    fprintf([rep{:}]);
end
end % end of giveTestingInfo
