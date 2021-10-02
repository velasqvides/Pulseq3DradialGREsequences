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
        transmitterBandwidth_min = 1500;
        transmitterBandwidth_max = 250e3;
        partitionThickness_min = 0.2e-3;
        partitionThickness_max = 20e-3;
        RfPulseDuration_min = 20e-6;
        RfPulseDuration_max = 12e-3;
        timeBwProduct_min = 2;
        timeBwProduct_max = 20;
    end
    
    properties(Dependent,Hidden)
        partitionThickness
        transmitterBandwidth
        slabGradientAmplitude
        deltaKz
    end
    
    methods
        
        function partitionThickness = get.partitionThickness(obj)
            partitionThickness = obj.slabThickness / obj.nPartitions;
        end
        
        function transmitterBandwidth = get.transmitterBandwidth(obj)
           transmitterBandwidth = obj.timeBwProduct / obj.RfPulseDuration; 
        end
        
        function slabGradientAmplitude = get.slabGradientAmplitude(obj)
            slabGradientAmplitude = obj.timeBwProduct / (obj.slabThickness * obj.RfPulseDuration);
        end
        
        function deltaKz = get.deltaKz(obj)
            deltaKz = 1/obj.slabThickness;
        end
        
        function validateResolutionZ(obj)
            report = {sprintf('### Checking partition resolution ...\n')};
            
            % fix slabThickness
            if obj.slabThickness < obj.slabThickness_min
                report{end+1} = sprintf(['**slabThickness = %2.1f mm is below lower limit %2.1f mm,'...
                    ' slabThickness set to: %2.1f mm\n'],...
                    obj.slabThickness*1e3, obj.slabThickness_min*1e3, obj.slabThickness_min*1e3);
                obj.slabThickness = obj.slabThickness_min;
            elseif obj.slabThickness > obj.slabThickness_max
                report{end+1} = sprintf(['**slabThickness = %2.1f mm is above upper limit %2.1f mm,'...
                    ' slabThickness set to: %2.1f mm\n'],...
                    obj.slabThickness*1e3, obj.slabThickness_max*1e3, obj.slabThickness_max*1e3);
                obj.slabThickness = obj.slabThickness_max;
            end
            
            % fix nPartitions
            toPrintPartitions = ' ';
            nPartitions_old = obj.nPartitions;
            if obj.nPartitions < obj.nPartitions_min
                toPrintPartitions = sprintf(['**nPartitions = %i is below lower limit %i,'...
                    ' nPartitions set to: %i\n'],nPartitions_old, obj.nPartitions_min, obj.nPartitions_min);
                obj.nPartitions = obj.nPartitions_min;
            elseif obj.nPartitions > obj.nPartitions_max
                toPrintPartitions = sprintf(['**nPartitions = %i is above upper limit %i',...
                    ' nPartitions set to: %i\n'],nPartitions_old, obj.nPartitions_max, obj.nPartitions_max);
                obj.nPartitions = obj.nPartitions_max;
            end
            % fix nPartitions further to comply with partition thickness limits
            if obj.partitionThickness < obj.partitionThickness_min
                br = floor(obj.slabThickness / obj.partitionThickness_min);
                toPrintPartitions = sprintf(['**nPartitions = %i has to be changed to %i to keep'...
                    ' the partition thickness above the lower limit: %2.1f mm\n'],...
                    nPartitions_old, br, obj.partitionThickness_min*1e3);
                obj.nPartitions = br;
            elseif obj.partitionThickness > obj.partitionThickness_max
                br = ceil(obj.slabThickness / obj.partitionThickness_max);
                toPrintPartitions = sprintf(['**nPartitions = %i has to be changed to %i to keep'...
                    ' the partition thickness below the upper limit: %2.1f mm\n'],...
                    nPartitions_old, br, obj.partitionThickness_max*1e3);
                obj.nPartitions = br;            
            end
            if ~strcmp(' ',toPrintPartitions)
            report{end+1} = toPrintPartitions;
            end
            
            % Check or fix timeBwProduct
            toPrintTbw = ' ';
            if obj.timeBwProduct < obj.timeBwProduct_min
                toPrintTbw = sprintf(['**time-bandwidth product = %i is below lower limit %i,'...
                    ' timeBwProduct set to: %i\n'],...
                    obj.timeBwProduct, obj.timeBwProduct_min, obj.timeBwProduct_min);
                obj.timeBwProduct = obj.timeBwProduct_min;
            elseif obj.timeBwProduct > obj.timeBwProduct_max
                toPrintTbw = sprintf(['**time-bandwidth product = %i is above upper limit %i,'...
                    ' timeBwProduct set to: %i\n'],...
                    obj.timeBwProduct, obj.timeBwProduct_max, obj.timeBwProduct_max);
                obj.timeBwProduct = obj.timeBwProduct_max;
            elseif mod(obj.timeBwProduct,2) ~= 0
                TBW_new = 2 * ceil(obj.timeBwProduct / 2);
                toPrintTbw = sprintf(['**time-bandwidth product = %i is not a multiple of 2,'...
                    ' timeBwProduct set to: %i\n'],obj.timeBwProduct, TBW_new);
                obj.timeBwProduct = TBW_new;
            end
            
            % Check or fix RF pulse duration
            toPrintRf = ' ';
            RfPulseDuration_old = obj.RfPulseDuration;
            if obj.RfPulseDuration < obj.RfPulseDuration_min
                toPrintRf = sprintf(['**RF pulse duration = %3.1f us is below lower limit %3.1f us,'...
                    ' RfPulseDuration set to: %3.1f us\n'],...
                    RfPulseDuration_old*1e6, obj.RfPulseDuration_min*1e6, obj.RfPulseDuration_min*1e6);
                obj.RfPulseDuration = obj.RfPulseDuration_min;
            elseif obj.RfPulseDuration > obj.RfPulseDuration_max
                toPrintRf = sprintf(['**RF pulse duration = %3.1f us is above upper limit %3.1f us,'...
                    ' RfPulseDuration set to: %3.1f us\n'],...
                    RfPulseDuration_old*1e6, obj.RfPulseDuration_max*1e6, obj.RfPulseDuration_max*1e6);
                obj.RfPulseDuration = obj.RfPulseDuration_max;            
            end
            % round the Rf pulse duration to the RF raster time (currently 1e-6 seconds)
            rfRasterTime = obj.systemLimits.rfRasterTime;
            obj.RfPulseDuration = rfRasterTime* round(obj.RfPulseDuration/rfRasterTime);
                        
            % fix the timeBwProduct further for the transmitterBandwidth to be between the limits
            if obj.transmitterBandwidth < obj.transmitterBandwidth_min
                % to be sure timeBwProduct is multiple of 2
                TBW_new = 2 * ceil(obj.transmitterBandwidth_min * obj.RfPulseDuration / 2); 
                text1 = sprintf('**timeBwProduct = %i was changed to %i',obj.timeBwProduct, TBW_new);
                text2 = sprintf('  to keep the transmiter bandwidth above the lower limit: %2.1f KHz\n',...
                    obj.transmitterBandwidth_min*1e-3);
                toPrintTbw = append(text1, text2);
                obj.timeBwProduct = TBW_new;
            elseif obj.transmitterBandwidth > obj.transmitterBandwidth_max
                % to be sure timeBwProduct is multiple of 2
                TBW_new = 2 * floor(obj.transmitterBandwidth_max * obj.RfPulseDuration / 2); 
                text1= sprintf('**timeBwProduct = %i was changed to %i',obj.timeBwProduct, TBW_new);
                text2 = sprintf('  to keep the transmiter bandwidth below the upper limit: %3.0f KHz\n',...
                    obj.transmitterBandwidth_max*1e-3);
                toPrintTbw = append(text1, text2);
                obj.timeBwProduct = TBW_new;            
            end
            if ~strcmp(' ',toPrintTbw)
            report{end+1} = toPrintTbw;
            end
            
            % fix the the duration of the RF pulse further...
            % for the amplitude of Gslab to be below  maxGradientAmplitude
            if obj.slabGradientAmplitude > obj.systemLimits.maxGrad % maxGrad in Hertz
                RFduration_new = floor((obj.timeBwProduct / (obj.slabThickness * obj.systemLimits.maxGrad)),6);
                text1 = sprintf('**RfPulseDuration = %3.1f us was changed to %3.1f us',...
                    RfPulseDuration_old*1e6, RFduration_new*1e6);
                text2 = sprintf('  to keep the maximum gradient amplitude below the limit: %2.0f mT/m\n',...
                    mr.convert(obj.systemLimits.maxGrad,'Hz/m','mT/m'));
                toPrintRf = append(text1,text2);
                obj.RfPulseDuration = RFduration_new;
            end
            if ~strcmp(' ',toPrintRf)
            report{end+1} = toPrintRf;
            end
            
            if size(report,2) == 1
                report{end+1} = sprintf('All partition resolution parameters accepted\n');
            end
            report{end+1} = sprintf('###...Done.\n\n');
            fprintf([report{:}]);
        end
        
        function validateProtocol(obj)
            
            validateResolution(obj)                      
            validateResolutionZ(obj)  
            validateTEandTR(obj)
            estimateNdummyScans(obj)
            obj.isValidated = true;
            fprintf('Tip: type: inputs, to double check the parameter values. \n\n')
            
        end
          
        function validateTEandTR(obj)
            thisSOSkernel = SOSkernel(obj);
            [TE_min, TR_min] = calculateMinTeTr(thisSOSkernel);
            TE_max = obj.TR_max - (TR_min - TE_min);   
            gradRasterTime = obj.systemLimits.gradRasterTime;
            % make sure TE and TR are multiples of the Gradient raster time
            obj.TE = gradRasterTime*round(obj.TE/gradRasterTime);
            obj.TR = gradRasterTime*round(obj.TR/gradRasterTime);
            isTR_maxCorrect =(abs( obj.TR_max/gradRasterTime - round(obj.TR_max/gradRasterTime) ) < 1e-9);
            assert(isTR_maxCorrect,['The constant property TR_max in Class Protocol seems to have changed,'...
                ' make sure this new value is multiple of (%.2f ms)\n'],gradRasterTime*1e3);
            
            
            report = {sprintf('### Checking TE and TR values ...\n')};
            report{end+1} = sprintf('Feasible TE and TR values in ms:\n');
            report{end+1} = sprintf('%6.3f <= TE <= %6.3f\n',TE_min*1e3,TE_max*1e3);
            report{end+1} = sprintf('%6.3f <= TR <= %6.3f, ',TR_min*1e3,obj.TR_max*1e3);
            report{end+1} = sprintf('with the constraint: TR >= TE +%6.3f\n',(TR_min*1e3 - TE_min*1e3));
            
            % Check or fix TE first
            if obj.TE + 2 * eps < TE_min
                report{end+1} = sprintf(['**Current TE =%6.3f ms is below lower limit %6.3f ms,'...
                    ' TE set to:%6.3f ms\n'],obj.TE*1e3, TE_min*1e3, TE_min*1e3);                
                obj.TE = TE_min;
            elseif obj.TE > TE_max + 2 * eps
                report{end+1} = sprintf(['**Current TE =%6.3f ms is above upper limit %6.3f ms,'...
                    ' TE set to:%6.3f ms\n'],obj.TE*1e3, TE_max*1e3, TE_max*1e3);
                obj.TE = TE_max;
            
            end
            % Then check or fix TR
            if obj.TR > obj.TR_max + 2 * eps
                report{end+1} = sprintf(['**Current TR =%6.3f ms is above upper limit %6.3f ms,'...
                    ' TR set to:%6.3f ms\n'],obj.TR*1e3, obj.TR_max*1e3, obj.TR_max*1e3);
                obj.TR = obj.TR_max;
            elseif obj.TR + 2 * eps < obj.TE + (TR_min - TE_min)
                report{end+1} = sprintf(['**The time difference between any valid TE and TR must'...
                    ' be at least:%6.3f ms. TR set to:%6.3f ms\n'],...
                    (TR_min - TE_min)*1e3, (obj.TE + (TR_min - TE_min))*1e3);
                obj.TR = obj.TE + (TR_min - TE_min);            
            end
            
            if size(report,2) == 5
                report{end+1} = sprintf('TE and TR values accepted\n');
            end
            report{end+1} = sprintf('###...Done.\n\n');
            fprintf([report{:}]);
        end % end of validateTEandTR 
    end % end of methods     
end %end of the class
