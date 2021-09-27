function sequenceEvents = createSequenceEvents(inputs, sys)

  



  
%% spoiler gradients
GxSpoiler = getGxSpoiler(FOV, Nx, phaseDispersionReadout, Gx, sys);



%% Advanced modification to sequence objetcs
% check if joining Gx and GxSpoiler brings time savings, if yes, "bridge"
% them. 
GxPlusSpoiler = joinGxAndGxSpoiler(Gx, GxSpoiler, phaseDispersionReadout, sys);




end


%% local functions


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






