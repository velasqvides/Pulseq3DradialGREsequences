% This Script gathers all the necessary information to create a 3D GRE 
% koosh-ball sequence. 
clear variables 
inputs = KBprotocol(); % create a SOSprotocol object
%% I. data collection
% 1. Resolution
inputs.FOV = 200e-3;                   % in meters
inputs.nSamples = 256;         
inputs.nSpokes = 58982;                       
inputs.bandwidthPerPixel = 1200;       % in Herz                  
inputs.readoutOversampling = 2;        % 1: no oversampling, 2: 2x oversampling  
% 2. Approach to steady state
inputs.nDummyScans = 100;
% 3. Spoling strategy 
inputs.phaseDispersionReadout = 2*pi;  % desired phase dispersion along readout; 
inputs.RfSpoilingIncrement = 117;      % in degrees
% 4. Angular ordering
inputs.angularOrdering = 'goldenAngle';% 'uniform', 'goldeAngle'
% 5. RF Excitation
inputs.RfExcitation = 'selectiveSinc'; % 'nonSelective', 'selectiveSinc'
inputs.RfPulseDuration = 2.56e-3;       % in seconds
inputs.RfPulseApodization = 0.5;       % 0: unapodized, 0.46: Haming, 0.5: Hanning
inputs.timeBwProduct = 8;              % dimensionless
% 6. Main system limits
inputs.maxGradient = 60;               % in mT/m
inputs.maxSlewRate = 150;              % in T/m/s
% 7. Set more system limits 
inputs.systemLimits = mr.opts('MaxGrad', inputs.maxGradient, 'GradUnit', 'mT/m', ...
    'MaxSlew', inputs.maxSlewRate, 'SlewUnit', 'T/m/s', ...
    'rfRingdownTime', 20e-6, 'rfDeadTime', 100e-6, ...
    'adcDeadTime', 20e-6);
% 8. Main operator-selectable parameters
inputs.TE = 2.710e-3;                   % in seconds
inputs.TR = 5.020e-3;                   % in seconds
inputs.flipAngle = 20;                  % in degrees

%% II. Validate the parameters.
% Optionally, get an idea of the necessary number of dummy scans 
inputs.T1 = 1284e-3; % T1 for white matter at 7T
inputs.error = 0.10; % normalized error between longitudinal magnetization value and its steady-state value 
inputs.validateProtocol

%% III. Test the sequence.
return
myKB = KBkernel(inputs); % create a KBkernel object
% myKB.writeSequence(name,scenario,debugLevel)
myKB.writeSequence('3D_koosh-ball','testing',1); % 'writing' to write the final sequence
