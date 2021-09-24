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
    
    properties(Constant,Hidden)
        nPartitions_min = 5;
        nPartitions_max = 1024;
        slabThickness_min = 10e-3;
        slabThickness_max = 500e-3;
        bandwidth_min = 1500;
        bandwidth_max = 250e3;
        partitionThickness_min = 0.2e-3;
        partitionThickness_max = 20e-3;
        RfPulseDuration_min = 20e-6;
        RfPulseDuration_max = 12e-3;
        timeBwProduct_min = 2;
        timeBwProduct_max = 20;
    end
    
    properties(Dependent,Hidden)
        partitionThickness
        bandwidth
        slabGradientAmplitude
    end
    
    methods
        
        function partitionThickness = get.partitionThickness(obj)
            partitionThickness = obj.slabThickness / obj.nPartitions;
        end
        
        function bandwidth = get.bandwidth(obj)
           bandwidth = obj.timeBwProduct / obj.RfPulseDuration; 
        end
        
        function slabGradientAmplitude = get.slabGradientAmplitude(obj)
            slabGradientAmplitude = obj.timeBwProduct / (obj.slabThickness * obj.RfPulseDuration);
        end
        
        function validateResolutionZ(obj)
            report = {sprintf('### Checking partition resolution ...\n')};
            
            % fix slabThickness
            if obj.slabThickness < obj.slabThickness_min
                report{end+1} = sprintf('**Current slabThickness = %2.1f mm is below lower limit %2.1f mm. slabThickness set to: %2.1f mm\n',obj.slabThickness*1e3, obj.slabThickness_min*1e3, obj.slabThickness_min*1e3);
                obj.slabThickness = obj.slabThickness_min;
            elseif obj.slabThickness > obj.slabThickness_max
                report{end+1} = sprintf('**Current slabThickness = %2.1f mm is above upper limit %2.1f mm. slabThickness set to: %2.1f mm\n',obj.slabThickness*1e3, obj.slabThickness_max*1e3, obj.slabThickness_max*1e3);
                obj.slabThickness = obj.slabThickness_max;
            end
            
            % fix nPartitions
            toPrintPartitions = ' ';
            if obj.nPartitions < obj.nPartitions_min
                toPrintPartitions = sprintf('**Current nPartitions = %i is below lower limit %i. nPartitions set to: %i\n',obj.nPartitions, obj.nPartitions_min, obj.nPartitions_min);
                obj.nPartitions = obj.nPartitions_min;
            elseif obj.nPartitions > obj.nPartitions_max
                toPrintPartitions = sprintf('**Current nPartitions = %i is above upper limit %i. nPartitions set to: %i\n',obj.nPartitions, obj.nPartitions_max, obj.nPartitions_max);
                obj.nPartitions = obj.nPartitions_max;
            end
            % fix nPartitions further to comply with partition thickness limits
            if obj.partitionThickness < obj.partitionThickness_min
                br = floor(obj.slabThickness / obj.partitionThickness_min);
                toPrintPartitions = sprintf('**Current nPartitions = %i has to be changed to %i to keep the partition thickness above the lower limit: %2.1f mm\n',obj.nPartitions, br, obj.partitionThickness_min*1e3);
                obj.nPartitions = br;
            elseif obj.partitionThickness > obj.partitionThickness_max
                br = ceil(obj.slabThickness / obj.partitionThickness_max);
                toPrintPartitions = sprintf('**Current nPartitions = %i has to be changed to %i to keep the partition thickness below the upper limit: %2.1f mm\n',obj.nPartitions, br, obj.partitionThickness_max*1e3);
                obj.nPartitions = br;            
            end
            if ~isempty(toPrintPartitions)
            report{end+1} = toPrintPartitions;
            end
            
            %% Check or fix timeBwProduct
            toPrintTbw = ' ';
            if obj.timeBwProduct < obj.timeBwProduct_min
                toPrintTbw = sprintf('**Current time-bandwidth product = %i is below lower limit %i. timeBwProduct set to: %i\n',obj.timeBwProduct, obj.timeBwProduct_min, obj.timeBwProduct_min);
                obj.timeBwProduct = obj.timeBwProduct_min;
            elseif obj.timeBwProduct > obj.timeBwProduct_max
                toPrintTbw = sprintf('**Current time-bandwidth product = %i is above upper limit %i. timeBwProduct set to: %i\n',obj.timeBwProduct, obj.timeBwProduct_max, obj.timeBwProduct_max);
                obj.timeBwProduct = obj.timeBwProduct_max;
            elseif mod(obj.timeBwProduct,2) ~= 0
                TBW_new = 2 * ceil(obj.timeBwProduct / 2);
                toPrintTbw = sprintf('**Current time-bandwidth product = %i is not a multiple of 2. timeBwProduct set to: %i\n',obj.timeBwProduct, TBW_new);
                obj.timeBwProduct = TBW_new;
            end
            
            %% Check or fix RF pulse duration
            toPrintRf = ' ';
            if obj.RfPulseDuration < obj.RfPulseDuration_min
                toPrintRf = sprintf('**Current RF pulse duration = %3.1f us is below lower limit %3.1f us. RfPulseDuration set to: %3.1f us\n',obj.RfPulseDuration*1e6, obj.RfPulseDuration_min*1e6, obj.RfPulseDuration_min*1e6);
                obj.RfPulseDuration = obj.RfPulseDuration_min;
            elseif obj.RfPulseDuration > obj.RfPulseDuration_max
                toPrintRf = sprintf('**Current RF pulse duration = %3.1f us is above upper limit %3.1f us. RfPulseDuration set to: %3.1f us\n',obj.RfPulseDuration*1e6, obj.RfPulseDuration_max*1e6, obj.RfPulseDuration_max*1e6);
                obj.RfPulseDuration = obj.RfPulseDuration_max;            
            end
            
            
            
            %% fix the timeBwProduct further for the bandwidth to be between the limits
            if obj.bandwidth < obj.bandwidth_min
                TBW_new = 2 * ceil(obj.bandwidth_min * obj.RfPulseDuration / 2); % to be sure timeBwProduct is multiple of 2
                text1 = sprintf('**Current timeBwProduct = %i has to be changed to %i',obj.timeBwProduct, TBW_new);
                text2 = sprintf('  to keep the transmiter bandwidth above the lower limit: %2.1f KHz\n',obj.bandwidth_min*1e-3);
                toPrintTbw = append(text1, text2);
                obj.timeBwProduct = TBW_new;
            elseif obj.bandwidth > obj.bandwidth_max
                TBW_new = 2 * floor(obj.bandwidth_max * obj.RfPulseDuration / 2); % to be sure timeBwProduct is multiple of 2
                text1= sprintf('**Current timeBwProduct = %i has to be changed to %i',obj.timeBwProduct, TBW_new);
                text2 = sprintf('  to keep the transmiter bandwidth below the upper limit: %3.0f KHz\n',obj.bandwidth_max*1e-3);
                toPrintTbw = append(text1, text2);
                obj.timeBwProduct = TBW_new;            
            end
            if ~isempty(toPrintTbw)
            report{end+1} = toPrintTbw;
            end
            
            %% fix the the duration of the RF pulse further...
            %  for the amplitude of Gslab to be below  maxGradientAmplitude
            if obj.slabGradientAmplitude > obj.systemLimits.maxGrad % maxGrad in Hertz
                RFduration_new = round((obj.timeBwProduct / (obj.slabThickness * obj.systemLimits.maxGrad)),6) + 1e-6;% +1e-6 to be usre we dont exceed the maxGrad limit
                text1 = sprintf('**Current RfPulseDuration = %3.1f us has to be changed to %3.1f us',obj.RfPulseDuration*1e6, RFduration_new*1e6);
                text2 = sprintf('  to keep the maximum gradient amplitude below the limit: %2.0f mT/m\n',mr.convert(obj.systemLimits.maxGrad,'Hz/m','mT/m'));
                toPrintRf = append(text1,text2);
                obj.RfPulseDuration = RFduration_new;
            end
            if ~isempty(toPrintRf)
            report{end+1} = toPrintRf;
            end
            
            report{end+1} = sprintf('...Done.\n\n');
            fprintf([report{:}]);
        end
        
        function validateProtocol(obj)
            
            validateResolution(obj)                      
            validateResolutionZ(obj)
            
            
        end
        
    end
    
end

