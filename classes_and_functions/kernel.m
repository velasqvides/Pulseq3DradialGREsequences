classdef kernel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected)
        protocol (1,1) protocol
    end
    
    methods
        
        function obj = kernel(inputProtocol)
            obj.protocol = inputProtocol;
        end
        
        function [RF, Gz, GzReph] = createSlabSelectionEvents(obj)
            RfExcitation = obj.protocol.RfExcitation;
            flipAngle = obj.protocol.flipAngle;
            RfPulseDuration = obj.protocol.RfPulseDuration;
            slabThickness = obj.protocol.slabThickness;
            RfPulseApodization = obj.protocol.RfPulseApodization;
            timeBwProduct = obj.protocol.timeBwProduct;
            systemLimits = obj.protocol.systemLimits;
            
            switch RfExcitation
                case 'selectiveSinc'
                    [RF, Gz, GzReph] = mr.makeSincPulse(flipAngle*pi/180,'Duration',RfPulseDuration,...
                        'SliceThickness',slabThickness,'apodization',RfPulseApodization,...
                        'timeBwProduct',timeBwProduct,'system',systemLimits);
                    
                case 'nonSelective'
                    RF = mr.makeBlockPulse(flipAngle*pi/180,systemLimits,'Duration',RfPulseDuration);
                    Gz = []; GzReph = [];
            end
            
        end % end of createSlabSelectionEvents
        
        function [Gx, GxPre, ADC] = createReadoutEvents(obj)
            nSamples = obj.protocol.nSamples;
            deltaKx = obj.protocol.deltaKx;
            systemLimits = obj.protocol.systemLimits;
            readoutOversampling = obj.protocol.readoutOversampling;
            dwellTime = obj.protocol.dwellTime;
            readoutGradientAmplitude = obj.protocol.readoutGradientAmplitude;
            readoutGradientFlatTime = obj.protocol.readoutGradientFlatTime;
            
            Gx = mr.makeTrapezoid('x','Amplitude',readoutGradientAmplitude,'FlatTime',...
                readoutGradientFlatTime,'system',systemLimits);
            % here I include some area (the last term) to make the trayectory asymmetric
            % and to measure the center ok k-space.
            GxPreArea = -(nSamples * deltaKx)/nSamples*(floor(nSamples/2)) - ...
                (Gx.riseTime*Gx.amplitude)/2 - 0.5*dwellTime*readoutGradientAmplitude;            
            GxPre = mr.makeTrapezoid('x','Area',GxPreArea,'system',systemLimits);
            ADC = mr.makeAdc(nSamples * readoutOversampling,'Dwell',dwellTime,'system',systemLimits);
        end % end of createReadoutEvents
        
        function [GxPlusSpoiler,dispersionPerTR] = createGxPlusSpoiler(obj)
            [Gx, GxPre, ~] = createReadoutEvents(obj);
            phaseDispersionReadout = obj.protocol.phaseDispersionReadout;
            systemLimits = obj.protocol.systemLimits;
            spatialResolution = obj.protocol.spatialResolution;
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            
            areaGxAfterTE = Gx.area - abs(GxPre.area);
            inherentDispersionAfterTE = obj.calculatePhaseDispersion(areaGxAfterTE,obj.protocol.spatialResolution);
            if phaseDispersionReadout <= inherentDispersionAfterTE
                GxPlusSpoiler = Gx; % add no extra area
            else
                areaSpoilingX = phaseDispersionReadout / (2 * pi * spatialResolution);
                extraAreaNeeded = areaSpoilingX - areaGxAfterTE;                
                extraFlatTimeNeeded = gradRasterTime * round((extraAreaNeeded / Gx.amplitude)/ gradRasterTime);
                GxPlusSpoiler = mr.makeTrapezoid('x','amplitude',Gx.amplitude,'FlatTime', ...
                    Gx.flatTime + extraFlatTimeNeeded,'system',systemLimits);
            end
            % since the extra flat time need to comply with the gradRaster time,
            % the exact desired phase dispersion cant be acchieved, but it will be close enough.
            dispersionPerTR = obj.calculatePhaseDispersion(GxPlusSpoiler.area-abs(GxPre.area), ...
                obj.protocol.spatialResolution);
        end % end GxPlusSpoiler       
          
        function [TE_min, TR_min] = calculateMinTeTr(obj)
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            singleTrKernel = createSingleTrKernel(obj);
                        
            [duration, ~, ~] = singleTrKernel.duration();
            [ktraj_adc, ~, t_excitation, ~, t_adc] = singleTrKernel.calculateKspace();
            kabs_adc = sum(ktraj_adc.^2,1).^0.5;
            [~, index_echo] = min(kabs_adc);
            t_echo = t_adc(index_echo);
            t_ex_tmp = t_excitation(t_excitation<t_echo);
            TE_min = t_echo-t_ex_tmp(end);
                        
            if (length(t_excitation)<2)
                TR_min=duration; % best estimate for now
            else
                t_ex_tmp1=t_excitation(t_excitation>t_echo);
                if isempty(t_ex_tmp1)
                    TR_min=t_ex_tmp(end)-t_ex_tmp(end-1);
                else
                    TR_min=t_ex_tmp1(1)-t_ex_tmp(end);
                end                
            end
            
            TE_min = gradRasterTime*ceil(TE_min/gradRasterTime); 
            TR_min = gradRasterTime*ceil(TR_min/gradRasterTime);
        end % end of calculateMinTeTr(obj)
    
        function [delayTE, delayTR] = calculateDelays(obj)
            gradRasterTime = obj.protocol.systemLimits.gradRasterTime;
            TE = obj.protocol.TE;
            TR = obj.protocol.TR;
            [TE_min, TR_min] = calculateMinTeTr(obj);
            
            delayTE = (TE - TE_min);
            delayTE = gradRasterTime*round(delayTE/gradRasterTime);
            delayTR = (TR - TR_min - delayTE);            
            delayTR = gradRasterTime*round(delayTR/gradRasterTime);
            % next assertions modified from mr.makeDelay of pulseq
            assert(isfinite(delayTE) & delayTE>=0,'calculateDelays:invalidDelayTE',...
                'DelayTE (%.2f ms) is invalid',delayTE*1e3);
            assert(isfinite(delayTR) & delayTR>=0,'calculateDelays:invalidDelayTR',...
                'DelayTR (%.2f ms) is invalid',delayTR*1e3);
        end % end of calculateDelays
    end % end methods
    
    
    methods(Static)
       function phaseDispersion = calculatePhaseDispersion(SpoilerArea, dimensionAlongSpoiler)
           phaseDispersion = 2 * pi * dimensionAlongSpoiler * SpoilerArea;
       end
   end
    
end % end class kernel

