% This Script gathers all the necessary information to create a 3D stack of
% stars sequence.
% Most of the inputs are validated in a first stage to check basic 
% consitency, then deeper validation is performed to see if the intended  
% resolution and contrast can be achieved. Messages are given in the 
% command window in case that some parameter is modified. 
%  
clear variables
%% I. data collection
% 1. Resolution
inputs = SoSprotocol(); 
inputs.FOV = 2560e-3;            % in meters
inputs.slabThickness = 256e-3;  % in meters
inputs.nSamples = 2560;  
inputs.nPartitions = 256;        
inputs.nSpokes = 1025;                       
inputs.bandwidthPerPixel = 16678; % in Herz                  
inputs.readoutOversampling = 2;  % 1: no oversampling, 2: 2x oversampling  
% 2. Approach to steady state
inputs.nDummyScans = 336;
% 3. Spoling strategy 
inputs.phaseDispersionReadout = 0;     % desired phase dispersion along readout;
inputs.phaseDispersionZ = 0;           % desired phase dispersion along z;  
inputs.RfSpoilingIncrement = 117;           % in degrees
% 4. Angular ordering
inputs.angularOrdering = 'goldenAngle';     % 'uniform', 'uniformAlternating', 'goldeAngle'
inputs.goldenAngleSequence = 1;             % 1: goldeAngle, 2: smallGoldenAngle, >2: tinyGoldenAngles
inputs.angleRange = 'fullCircle';           % 'fullCircle' or 'halfCircle'
inputs.partitionRotation = 'goldenAngle';   % 'aligned', 'linear', 'goldenAngle'
inputs.viewOrder = 'partitionsInInnerLoop'; % 'partitionsInInnerLoop', 'partitionsInOuterLoop'
% 5. RF Excitation
inputs.RfExcitation = 'selectiveSinc';    % 'nonSelective', 'selectiveSinc'
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
    'adcDeadTime', 0);
% 8. Main operator-selectable parameters
inputs.TE = 2.21e-3;                             % in seconds
inputs.TR = 4.36e-3;                             % in seconds
inputs.flipAngle = 5;                     % in degrees

%% II. Check and save the input data.
inputs.validateResolution
T1 = 1284e-3; % T1 for white matter at 7T
error = 0.10; % normalized error between longitudinal magnetization value and its steady-state value 
inputs.estimateNdummyScans(T1,error)
clear T1 error;



