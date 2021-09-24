classdef sequenceKernel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        protocol (1,1) protocol
    end
    
    methods
        function obj = sequenceKernel(v)
            obj.protocol = v;
        end
    end
    
end

