classdef SOSprotocol < protocol
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        slabThickness (1,1) double {mustBeNumeric, mustBePositive}=256e-3
        nPartitions (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=256
        phaseDispersionZ (1,1) double {mustBeNumeric, mustBeNonnegative}=2*pi
        angularOrdering string {mustBeMember(angularOrdering,{'uniform','uniformAlternating','goldenAngle'})}='goldenAngle'
        goldenAngleSequence (1,1) {mustBeNumeric, mustBeInteger, mustBePositive}=1
        angleRange string {mustBeMember(angleRange,{'fullCircle','halfCircle'})} ='fullCircle'
        partitionRotation string {mustBeMember(partitionRotation,{'aligned','linear','goldenAngle'})}='goldenAngle'
        viewOrder string {mustBeMember(viewOrder,{'partitionsInInnerLoop','partitionsInOuterLoop'})} ='partitionsInInnerLoop'
    end
    
    properties(Access = private, Constant)
        nPartitions_min = 5;
        nPartitions_max = 1024;
        slabThickness_min = 10e-3;
        slabThickness_max = 500e-3;        
        partitionThickness_min = 0.2e-3;
        partitionThickness_max = 20e-3;        
    end
    
    properties(Dependent,Hidden)
        partitionThickness        
        slabGradientAmplitude
        deltaKz
        slabSize
    end
    
    methods
        
        function partitionThickness = get.partitionThickness(obj)
            partitionThickness = obj.slabThickness / obj.nPartitions;
        end
        
        function slabSize = get.slabSize(obj)
            slabSize = obj.slabThickness;
        end
        
        function slabGradientAmplitude = get.slabGradientAmplitude(obj)
            slabGradientAmplitude = obj.transmitterBandwidth / obj.slabThickness; 
        end
        
        function deltaKz = get.deltaKz(obj)
            deltaKz = 1/obj.slabThickness;
        end
        
        % method signatures
        validateResolutionZ(obj) 
        
        validateTEandTR(obj) 
        
        validateProtocol(obj)
        
    end % end of methods
    
end %end of the class

