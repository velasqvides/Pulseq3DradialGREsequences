% This Script gathers all the necessary information to create a 3D GRE 
% stack of stars sequence. 
clear variables 
% create class SOSprotocol
inputs = SOSprotocol(); 
%% I. data collection
% 1. Resolution
inputs.FOV = 256e-3;            % in meters
inputs.slabThickness = 256e-3;  % in meters
inputs.nSamples = 256;  
inputs.nPartitions = 256;        
inputs.nSpokes = 256;                       
inputs.bandwidthPerPixel = 1628; % in Herz                  
inputs.readoutOversampling = 2;  % 1: no oversampling, 2: 2x oversampling  
% 2. Approach to steady state
inputs.nDummyScans = 469;
% 3. Spoling strategy 
inputs.phaseDispersionReadout = 2 * pi;     % desired phase dispersion along readout;
inputs.phaseDispersionZ = 2 * pi;           % desired phase dispersion along z;  
inputs.RfSpoilingIncrement = 117;           % in degrees
% 4. Angular ordering
inputs.angularOrdering = 'goldenAngle';     % 'uniform', 'uniformAlternating', 'goldeAngle'
inputs.goldenAngleSequence = 1;             % 1: goldeAngle, 2: smallGoldenAngle, >2: tinyGoldenAngles
inputs.angleRange = 'fullCircle';           % 'fullCircle' or 'halfCircle'
inputs.partitionRotation = 'goldenAngle';   % 'aligned', 'linear', 'goldenAngle'
inputs.viewOrder = 'partitionsInInnerLoop'; % 'partitionsInInnerLoop', 'partitionsInOuterLoop'
% 5. RF Excitation
inputs.RfExcitation = 'nonSelective';    % 'nonSelective', 'selectiveSinc'
inputs.RfPulseDuration = 400e-6;          % use 200e-6 for nonSelective, in seconds
inputs.RfPulseApodization = 0.5;          % 0: unapodized, 0.46: Haming, 0.5: Hanning
inputs.timeBwProduct = 2;                 % dimensionless
% 6. Main system limits
inputs.maxGradient = 50;                  % in mT/m
inputs.maxSlewRate = 150;                 % in T/m/s
% 7. Set more system limits, and group them into a structure variable
inputs.systemLimits = mr.opts('MaxGrad', inputs.maxGradient, 'GradUnit', 'mT/m', ...
    'MaxSlew', inputs.maxSlewRate, 'SlewUnit', 'T/m/s', ...
    'rfRingdownTime', 20e-6, 'rfDeadTime', 100e-6, ...
    'adcDeadTime', 20e-6);
% 8. Main operator-selectable parameters
inputs.TE = 1.45e-3;                             % in seconds
inputs.TR = 2.87e-3;                             % in seconds
inputs.flipAngle = 5;                            % in degrees

%% II. Validate the parameters.
% Optionally, get an idea of the necessary number of dummy scans 
inputs.T1 = 1284e-3; % T1 for white matter at 7T
inputs.error = 0.10; % normalized error between longitudinal magnetization value and its steady-state value 
inputs.validateProtocol

%% III. Test the sequence.
return
mySOS = SOSkernel(inputs);
mySOS.writeSequence('testing');


