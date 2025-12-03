function  kinematics = saccadeKinematicsCalculator2(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, targetShift_primary, ...
    targetShift_secondary, primary, corrective)
% the difference between this version of the function and the previous
% version is that in the new version, labeled saccades as primary and
% secondary are used.
%%
for i = 1:size(detected_saccades_fixations,2)
    clear positionX positionY saccades onset offset;
%     disp(i);
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
         %input
        positionX = smooth_EyeX(i,:);
        positionY = smooth_EyeY(i,:);
        saccades = detected_saccades_fixations(i).saccades;         %saccades
        onset = detected_saccades_fixations(i).saccade_onset;       %onset(s)
        offset = detected_saccades_fixations(i).saccade_offset;     %offset(s)
        if isnan(offset)
           offset(1,1) = NaN;
           offset(1,2) = NaN;
        elseif isnan(onset)
           onset(1,1) = NaN;
           onset(1,2) = NaN;
        end
        if primary(i) == 1  
            %measure
            if ~isnan(offset(1,2)) && ~isnan(onset(1,2))
                duration1 = offset(1,2) - onset(1,2);                        %duration of primary saccade
                amplitude1 = euclideanDistance(...
                    positionX(onset(1,2)), positionX(offset(1,2)), ...
                    positionY(onset(1,2)), positionY(offset(1,2)));         %amplitude of the primary saccade
            else
                duration1 = NaN;                        %duration of primary saccade
                amplitude1 = NaN;         %amplitude of the primary saccade
            end
            if ~isnan(offset(1,2))
                amplitudeoffset = abs(positionX(offset(1,2)));
                if length(positionX) - offset(1,2) >= 51
                    amplitudeoffset50 = abs(positionX(offset(1,2) + 50));
                else
                    amplitudeoffset50 = NaN;
                end
            else
                amplitudeoffset =NaN;
                amplitudeoffset50 = NaN;
            end
            if ~isnan(onset(1,2))
                RT = onset(1,2) - targetShift_primary(i);                   %reaction time
                peakVelocity1 = saccades(1,1);
            else
                RT = NaN;
                peakVelocity1 = NaN;
            end
%             RT = onset(1,2) - targetShift_primary(i);                   %reaction time
%             duration1 = offset(1,2) - onset(1,2);                        %duration of primary saccade
%             amplitude1 = euclideanDistance(...
%                 positionX(onset(1,2)), positionX(offset(1,2)), ...
%                 positionY(onset(1,2)), positionY(offset(1,2)));         %amplitude of the primary saccade
%             amplitudeoffset = abs(positionX(offset(1,2)));
%             amplitudeoffset50 = abs(positionX(offset(1,2) + 50));
%             peakVelocity1 = saccades(1,1);
            %output
            kinematics(i).reactionTime = RT;
            kinematics(i).duration_pri = duration1;
            kinematics(i).amplitude_pri = amplitude1;
            kinematics(i).amplitudeoffset = amplitudeoffset;
            kinematics(i).amplitudeoffset50 = amplitudeoffset50;
            kinematics(i).peakVelocity_pri = peakVelocity1;
%                 kinematics(i).intersaccadeinterval = NaN;
%                 kinematics(i).interval_2ndTarget_saccade = NaN;
%                 kinematics(i).duration_cor = NaN;
%                 kinematics(i).amplitude_cor = NaN;
%                 kinematics(i).peakVelocity_cor = NaN;
            if (corrective(i) == 1)
                %measure
                if ~isnan(offset(1,2)) && ~isnan(onset(2,2))
                    ISI = onset(2,2) - offset(1,2);                          %inter-saccade interval
                else
                    ISI = NaN;
                end
                if ~isnan(targetShift_secondary(i)) && ~isnan(onset(2,2))
                    interval_2ndTarget_saccade = onset(2,2) - ...
                    targetShift_secondary(i);                           %interval between 2nd target shift and the onse of corrective saccade
                else
                    interval_2ndTarget_saccade = NaN;
                end
                if (size(offset,1) > 1)
                    if ~isnan(offset(2,2)) && ~isnan(onset(2,2))
                        duration2 = offset(2,2) - onset(2,2);                   %duration of the corrective saccade
                        amplitude2 = euclideanDistance(...
                            positionX(onset(2,2)), positionX(offset(2,2)), ...
                            positionY(onset(2,2)), positionY(offset(2,2)));     %amplitude of the corrective saccade
                    else
                        duration2 = NaN;
                        amplitude2 = NaN;
                    end
                else
                        duration2 = NaN;
                        amplitude2 = NaN;
                end
%                 ISI = onset(2,2) - offset(1,2);                          %inter-saccade interval
%                 interval_2ndTarget_saccade = onset(2,2) - ...
%                     targetShift_secondary(i);                           %interval between 2nd target shift and the onse of corrective saccade
%                 duration2 = offset(2,2) - onset(2,2);                   %duration of the corrective saccade
%                 amplitude2 = euclideanDistance(...
%                     positionX(onset(2,2)), positionX(offset(2,2)), ...
%                     positionY(onset(2,2)), positionY(offset(2,2)));     %amplitude of the corrective saccade
                peakVelocity2 = saccades(2,1);
                %output
                kinematics(i).intersaccadeinterval = ISI;
                kinematics(i).interval_2ndTarget_saccade = interval_2ndTarget_saccade;
                kinematics(i).duration_cor = duration2;
                kinematics(i).amplitude_cor = amplitude2;
                kinematics(i).peakVelocity_cor = peakVelocity2;
            elseif corrective(i) == 0
                kinematics(i).intersaccadeinterval = NaN;
                kinematics(i).interval_2ndTarget_saccade = NaN;
                kinematics(i).duration_cor = NaN;
                kinematics(i).amplitude_cor = NaN;
                kinematics(i).peakVelocity_cor = NaN;
            end
        elseif primary(i) == 0 && corrective(i) == 1
            %measure
            ISI = NaN;                          %inter-saccade interval
            if (size(onset,1) > 1) && (size(offset,1) > 1)
                if ~isnan(targetShift_secondary(i)) && ~isnan(onset(2,2))
                    interval_2ndTarget_saccade = onset(2,2) - ...
                        targetShift_secondary(i);                           %interval between 2nd target shift and the onse of corrective saccade
                else
                    interval_2ndTarget_saccade = NaN;
                end
            
                if ~isnan(offset(2,2)) && ~isnan(onset(2,2))
                    duration2 = offset(2,2) - onset(2,2);                   %duration of the corrective saccade
                    amplitude2 = euclideanDistance(...
                        positionX(onset(2,2)), positionX(offset(2,2)), ...
                        positionY(onset(2,2)), positionY(offset(2,2)));     %amplitude of the corrective saccade
                else
                    duration2 = NaN;
                    amplitude2 = NaN;
                end
            else
                interval_2ndTarget_saccade = NaN;
                duration2 = NaN;
                amplitude2 = NaN;
            end
%             interval_2ndTarget_saccade = onset(1,2) - ...
%                 targetShift_secondary(i);                           %interval between 2nd target shift and the onse of corrective saccade
%             duration2 = offset(1,2) - onset(1,2);                   %duration of the corrective saccade
%             amplitude2 = euclideanDistance(...
%                 positionX(onset(1,2)), positionX(offset(1,2)), ...
%                 positionY(onset(1,2)), positionY(offset(1,2)));     %amplitude of the corrective saccade
            peakVelocity2 = saccades(1,1);
            %output
            kinematics(i).intersaccadeinterval = ISI;
            kinematics(i).interval_2ndTarget_saccade = interval_2ndTarget_saccade;
            kinematics(i).duration_cor = duration2;
            kinematics(i).amplitude_cor = amplitude2;
            kinematics(i).peakVelocity_cor = peakVelocity2;

            kinematics(i).reactionTime = NaN;
            kinematics(i).duration_pri = NaN;
            kinematics(i).amplitude_pri = NaN;
            kinematics(i).amplitudeoffset = NaN;
            kinematics(i).amplitudeoffset50 = NaN;
            kinematics(i).peakVelocity_pri = NaN;
        end
    elseif isnan(detected_saccades_fixations(i).saccades(1,1))
        %output
        kinematics(i).reactionTime = NaN;
        kinematics(i).duration_pri = NaN;
        kinematics(i).amplitude_pri = NaN;
        kinematics(i).amplitudeoffset = NaN;
        kinematics(i).amplitudeoffset50 = NaN;
        kinematics(i).peakVelocity_pri = NaN;
        kinematics(i).intersaccadeinterval = NaN;
        kinematics(i).interval_2ndTarget_saccade = NaN;
        kinematics(i).duration_cor = NaN;
        kinematics(i).amplitude_cor = NaN;
        kinematics(i).peakVelocity_cor = NaN;
    end
end
