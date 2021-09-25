function sequenceEvents = createSequenceEvents(inputs, sys)
%createSequenceEvents creates all the events needed in the sequence,
%RF pulse, phase encoding, readout and spoiler gradients. 
% Advances modifications like bridged gradients are also done here.
% The .mr toolbox of Pulseq is used here to create the events.
%
% Inputs
%   - inputs: a struct with input data to create the sequence events. 
%   - sys: a struct with the system limits.
% Output
%   - sequenceEvents: a struct with all the sequence events: RF, Gz, Gx,
%   etc.

% extract the required parameters from the inputs struct and rename them conveniently.
FOV = inputs.FOV;
slabThickness = inputs.slabThickness;
Nx = inputs.Nx;
Nz = inputs.Nz;
flipAngle = inputs.flipAngle;               
bandwidthPerPixel = inputs.bandwidthPerPixel;
readoutOversampling = inputs.readoutOversampling;
phaseDispersionZ = inputs.phaseDispersionZ;
phaseDispersionReadout = inputs.phaseDispersionReadout;
GzSpoilerArea = inputs.GzSpoilerArea;
RfExcitation = inputs.RfExcitation;
RfPulseDuration = inputs.RfPulseDuration;
RfPulseApodization = inputs.RfPulseApodization;
timeBWProduct = inputs.timeBWProduct;

readoutDuration = 10e-6 * ceil(round((1/bandwidthPerPixel),6) / 10e-6);

%% Create alpha-degree RF pulse and slab gradients
[RF, Gz, GzReph] = getRFPulse(RfExcitation, RfPulseDuration, RfPulseApodization, timeBWProduct, ...
                              flipAngle, slabThickness, sys);
  
%% Create readout gradients and ADC events
deltaK = 1 / FOV;
Gx = mr.makeTrapezoid('x','FlatArea',Nx * deltaK,'FlatTime',readoutDuration,'system',sys);
ADC = mr.makeAdc(Nx * readoutOversampling,'Duration',readoutDuration,'Delay',Gx.riseTime,'system',sys);
GxPre = mr.makeTrapezoid('x','Area',-Gx.flatArea/Nx*floor(Nx/2)-(Gx.area-Gx.flatArea)/2,'system',sys);

%% calculate partition encoding gradients
GzPartition = getGzPartitions(slabThickness, Nz, sys);
  
%% spoiler gradients
GxSpoiler = getGxSpoiler(FOV, Nx, phaseDispersionReadout, Gx, sys);

GzSpoiler = getGzSpoiler(slabThickness, Nz, phaseDispersionZ, GzSpoilerArea, GzPartition, sys);

%% Advanced modification to sequence objetcs
% check if joining Gx and GxSpoiler brings time savings, if yes, "bridge"
% them. 
GxPlusSpoiler = joinGxAndGxSpoiler(Gx, GxSpoiler, phaseDispersionReadout, sys);

% Combine gradient slab rephasing with partition encoding gradient to save
% time
GzRephPlusGzPartition = combineGzRephAndGzPartition(GzReph, Nz, slabThickness,sys);

% We will use three main blocks per TR :
% block 1: RF, Gz,
% block 2: GzRephPlusGzPartition, GxPre
% blcok 3: GxPlusSpoiler (or Gx, GxSpoiler), ADC, Gz

 
%% group the data into a structure
sequenceEvents.RF = RF;
sequenceEvents.Gz = Gz;
sequenceEvents.GzReph = GzReph;
sequenceEvents.GzPartition = GzPartition;
sequenceEvents.GxPre = GxPre ;
sequenceEvents.Gx = Gx;
sequenceEvents.ADC = ADC;
sequenceEvents.GxSpoiler = GxSpoiler;
sequenceEvents.GzSpoiler = GzSpoiler;
sequenceEvents.GxPlusSpoiler = GxPlusSpoiler;
sequenceEvents.GzRephPlusGzPartition = GzRephPlusGzPartition;

end


%% local functions

function [RF, Gz, GzReph] = getRFPulse(RFExcitation, RFPulseDuration, RFPulseApodization, ...
                                       timeBWProduct, flipAngle, slabThickness, sys)
%getRFPulse calculates the RF pulse based on the input parameter
%'RFExcitation'. 
% The nonSelective case sets Gz and GzReph to an empty struct.

switch RFExcitation
    case 'selectiveSinc'
        [RF, Gz, GzReph] = mr.makeSincPulse(flipAngle*pi/180,'Duration',RFPulseDuration,...
                           'SliceThickness',slabThickness,'apodization',RFPulseApodization,...
                           'timeBwProduct',timeBWProduct,'system',sys); 

    case 'nonSelective'
        RF = mr.makeBlockPulse(flipAngle*pi/180,sys,'Duration',RFPulseDuration);    
        Gz = []; GzReph = [];       
end

end

function GzPartition = getGzPartitions(slabThickness, Nz, sys)
%getGzPartitions calculates partition encoding gradients for all the
% partitions according to the number of partitions Nz.

deltaK = 1/slabThickness;
GzPartitionAreas = ((0:Nz-1) - Nz/2) * deltaK; % areas go from bottom to top
% get a dummy gradient with the maximum area of all GzPartitions
dummyGradient = mr.makeTrapezoid('z',sys,'Area',max(abs(GzPartitionAreas)));
% Use the duration of the dummy gradient for all the GzPartitions to keep
% the TE and TR constant. 
fixedGradientDuration = mr.calcDuration(dummyGradient); 

% make partition encoding gradients
    for iz = 1:Nz
        GzPartition(iz) = mr.makeTrapezoid('z',sys,'Area',GzPartitionAreas(iz),'Duration',fixedGradientDuration);
    end

end

function GxSpoiler = getGxSpoiler(FOV, Nx, phaseDispersionReadout, Gx, sys) 
%getGxSpoiler calculates the GxSpoiler gradient based on the input parameter
%'phaseDispersionReadout'.
% When phaseDispersionReadout is equal to zero, it sets GxSpoiler to an
% empty struct. 

if phaseDispersionReadout > pi
    % calculate the required area to achieved the desired phase dispersion
    AreaSpoilingX = phaseDispersionReadout / (2 * pi * FOV / Nx); 
    % half of the Readout gradient already add some phase dispersion
    AreaNedeed = AreaSpoilingX - Gx.area / 2; 
    % create the spoler gradient in readout with the requiered area
    GxSpoiler = mr.makeTrapezoid('x','Area',AreaNedeed,'system',sys);
else
    GxSpoiler = [];    
end 

end

function GzSpoiler = getGzSpoiler(slabThickness, Nz, phaseDispersionZ, GzSpoilerArea, GzPartition, sys) 
%getGxSpoiler calculates the GzSpoiler gradient based on the input parameter
%'phaseDispersionZ'.
% 1. When phaseDispersionReadout is equal to zero, it just refocuse the partition 
% encoding gradient in Z direction to avoid banding artifacts.
% 2. When phaseDispersionReadout is not zero, the area of GzSpoiler can
% be constant or adaptive depending of the parameter GzSpoilerArea. In both 
% cases, the polarity of GzSpoiler will follow the polarity of GzPartition.
% For the adaptive case the total phase dispersion of GzPartition and GzSpoiler will be
% +-2*pi. For the constant case, the total phase dispersion will be always >= 2*pi.  

partitionThickness = slabThickness/Nz; 
% GzSpoiler
if phaseDispersionZ > 0
    % in case the GzSpoiler area has to change, use the same duration to keep same TR   
    AreaSpoilingZ = phaseDispersionZ / (2 * pi * partitionThickness);
    dummyGradient = mr.makeTrapezoid('z',sys,'Area',abs(AreaSpoilingZ));
    fixedDurationGradient = mr.calcDuration(dummyGradient); % same duration every step
    
    switch GzSpoilerArea
        
        case 'constant'
            % calculate the required area to achieved the desired phase dispersion
            for iZ=1:Nz

                if GzPartition(iZ).area < 0

                    GzSpoiler(iZ) = mr.makeTrapezoid('z','Area',-AreaSpoilingZ,'Duration',fixedDurationGradient','system',sys);
                else
                    GzSpoiler(iZ) = mr.makeTrapezoid('z','Area',AreaSpoilingZ,'Duration',fixedDurationGradient,'system',sys);
                end
                
            end 
        
        case 'adaptive'                        
            for iZ=1:Nz 
                % GzPartition already add some phase dispersion to the spins
                dispersionDueToGzPartition = 2 * pi * partitionThickness * abs(GzPartition(iZ).area);
                % Then we calculate the phase dispersion needed to get phaseDispersionZ in total
                dispersionNeededZ = phaseDispersionZ - dispersionDueToGzPartition;
                AreaSpoilingZ = dispersionNeededZ / (2 * pi * partitionThickness);
                if GzPartition(iZ).area < 0

                    GzSpoiler(iZ) = mr.makeTrapezoid('z','Area',-AreaSpoilingZ,'Duration',fixedDurationGradient,'system',sys);
                else
                    GzSpoiler(iZ) = mr.makeTrapezoid('z','Area',AreaSpoilingZ,'Duration',fixedDurationGradient,'system',sys);
                end
                
            end 
     
    end
else % just refocuse the phase encoding gradient in Z direction 
    for iz = 1:Nz
        GzSpoiler(iz) = mr.makeTrapezoid('z',sys,'Area',-GzPartition(iz).area,'Duration',mr.calcDuration(GzPartition(1)));
    end
    
end

end

function GxPlusSpoiler = joinGxAndGxSpoiler(Gx, GxSpoiler, phaseDispersionReadout, sys)
%joinGxAndGxSpoiler checks if joining Gx and GxSpoiler brings time savings, 
%if yes, then it "bridge" them.%
% The two gradients are merged by a prolongation of the flat part of the
% readout gradient.
% According to some manual tests, this function should merge both gradients  
% even when the required phase dispersion across a voxel is up to 8*pi, giving 
% time savings for lower values (a typical value is just 2*pi).

if phaseDispersionReadout > pi
    % calculate the time required to apply Gx and GxSpoiler separately
    separateTotalTime = ceil((mr.calcDuration(Gx) + mr.calcDuration(GxSpoiler))...
                        / sys.gradRasterTime) * sys.gradRasterTime;
    % calculate the time required to extend the flat time of Gx to have an
    % extra area equal to the area of GxSpoiler                
    extraTimeBridging = ceil((GxSpoiler.area / Gx.amplitude)...
                        / sys.gradRasterTime) * sys.gradRasterTime;
    % calculate the time required to apply Gx 'Bridged' with GxSpoiler                
    BridgeTotalTime = mr.calcDuration(Gx) + extraTimeBridging;

    if BridgeTotalTime <= separateTotalTime
        % create a new Gradient with same amplitude as Gx but with extra  
        % flat time to account for the area of the spoiler gradient  
        GxPlusSpoiler = mr.makeTrapezoid('x','amplitude',Gx.amplitude,...
                       'FlatTime',Gx.flatTime + extraTimeBridging,'system',sys);
    else
        GxPlusSpoiler = [];               
    end
else
    GxPlusSpoiler = [];
end        

end

function GzRephPlusGzPartition = combineGzRephAndGzPartition(GzReph, Nz, slabThickness, sys)
%combineGzRephAndGzPartition combines the area of the slab-rephasing lobe 
%with the partition-encoding lobes to save some microseconds.

deltaK =1 / slabThickness;
if isempty(GzReph)
    GzRephArea = 0;
else
    GzRephArea = GzReph.area;
end  

GzPartitionAreas = ((0:Nz-1) - Nz/2) * deltaK; % areas go from bottom to top
% get a dummy gradient with the maximum area of all GzPartitions
dummyGradient = mr.makeTrapezoid('z',sys,'Area',max(abs(GzPartitionAreas)) + abs(GzRephArea));
% Use the duration of the dummy gradient for all the GzPartitions to keep
% the TE and TR constant. 
fixedGradientDuration = mr.calcDuration(dummyGradient); 

for iz = 1:Nz
    % here, the area of the slab-rephasing lobe and partition-encoding lobes are added together 
    GzRephPlusGzPartition(iz) = mr.makeTrapezoid('z',sys,'Area',GzPartitionAreas(iz) + GzRephArea,...
    'Duration',fixedGradientDuration);    
end

end


