sequenceObject1 = mr.Sequence();
sequenceObject1.addBlock( mr.rotate('z', 0, AlignedSeqEvents.RF, AlignedSeqEvents.GzCombinedCell{1},GxPre) );
sequenceObject.addBlock( mr.rotate('z', 0, AlignedSeqEvents.GxPlusSpoiler, AlignedSeqEvents.ADC, AlignedSeqEvents.GzSpoilersCell{1}, mr.makeDelay( mr.calcDuration( AlignedSeqEvents.GzSpoilersCell{1} ) ) ) );
sequenceObject1.addBlock( mr.rotate('z', 0, AlignedSeqEvents.RF, AlignedSeqEvents.GzCombinedCell{1},GxPre) );
sequenceObject.addBlock( mr.rotate('z', 0, AlignedSeqEvents.GxPlusSpoiler, AlignedSeqEvents.ADC, AlignedSeqEvents.GzSpoilersCell{1}, mr.makeDelay( mr.calcDuration( AlignedSeqEvents.GzSpoilersCell{1} ) ) ) );
[duration, numBlocks, eventCount]=sequenceObject1.duration();
            [ktraj_adc, ktraj, t_excitation, t_refocusing, t_adc] = sequenceObject1.calculateKspace();
            kabs_adc=sum(ktraj_adc.^2,1).^0.5;
            [kabs_echo, index_echo]=min(kabs_adc);
            t_echo=t_adc(index_echo);
            t_ex_tmp=t_excitation(t_excitation<t_echo);
            TE_min=t_echo-t_ex_tmp(end);
            
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