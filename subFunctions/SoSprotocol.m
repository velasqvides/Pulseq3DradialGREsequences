classdef SoSprotocol < protocol
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
    
%     methods
%         
%         function validateProtocol(obj)
%         fprintf("### Checking in-plane resolution ...\n");
%         end
%         
%     end
    
end

