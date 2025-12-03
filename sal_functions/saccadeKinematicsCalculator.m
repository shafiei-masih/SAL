function  kinematics = saccadeKinematicsCalculator(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, targetShift_primary, targetShift_secondary)
    for i = 1:size(detected_saccades_fixations,2)
        if ~isnan(detected_saccades_fixations(i).saccades(1,1))
            disp(i);
            %input
            positionX = smooth_EyeX(i,:);
            positionY = smooth_EyeY(i,:);
            saccades = detected_saccades_fixations(i).saccades;         %saccades
            onset = detected_saccades_fixations(i).saccade_onset;       %onset(s)
            Offset = detected_saccades_fixations(i).saccade_offset;     %Offset(s)
            if isnan(Offset)
               Offset(1,1) = NaN;
               Offset(1,2) = NaN;
            elseif isnan(onset)
               onset(1,1) = NaN;
               onset(1,2) = NaN;
            end
            %   . targetShift_primary
            %   . targetShift_secondary
            %measure
            if ~isnan(Offset(1,2)) && ~isnan(onset(1,2))
                duration1 = Offset(1,2) - onset(1,2);                        %duration of primary saccade
                amplitude1 = euclideanDistance(...
                    positionX(onset(1,2)), positionX(Offset(1,2)), ...
                    positionY(onset(1,2)), positionY(Offset(1,2)));         %amplitude of the primary saccade
            else
                duration1 = NaN;                        %duration of primary saccade
                amplitude1 = NaN;         %amplitude of the primary saccade
            end
            if ~isnan(Offset(1,2))
                amplitudeOnset = abs(positionX(Offset(1,2)));
                if length(positionX) - Offset(1,2) >= 51
                    amplitudeOnset50 = abs(positionX(Offset(1,2) + 50));
                else
                    amplitudeOnset50 = NaN;
                end
            else
                amplitudeOnset =NaN;
                amplitudeOnset50 = NaN;
            end
            if ~isnan(onset(1,2))
                RT = onset(1,2) - targetShift_primary(i);                   %reaction time
                peakVelocity1 = saccades(1,1);
            else
                RT = NaN;
                peakVelocity1 = NaN;
            end
            %output
            kinematics(i).reactionTime = RT;
            kinematics(i).duration_pri = duration1;
            kinematics(i).amplitude_pri = amplitude1;
            kinematics(i).amplitudeOnset = amplitudeOnset;
            kinematics(i).amplitudeOnset50 = amplitudeOnset50;
            kinematics(i).peakVelocity_pri = peakVelocity1;
            kinematics(i).intersaccadeinterval = NaN;
            kinematics(i).interval_2ndTarget_saccade = NaN;
            kinematics(i).duration_cor = NaN;
            kinematics(i).amplitude_cor = NaN;
            kinematics(i).peakVelocity_cor = NaN;
            if (size(saccades, 1) > 1) 
                %measure
                if ~isnan(Offset(1,2)) && ~isnan(onset(2,2))
                    ISI = onset(2,2) - Offset(1,2);                          %inter-saccade interval
                else
                    ISI = NaN;
                end
                if ~isnan(targetShift_secondary(i)) && ~isnan(onset(2,2))
                    interval_2ndTarget_saccade = onset(2,2) - ...
                    targetShift_secondary(i);                           %interval between 2nd target shift and the onse of corrective saccade
                else
                    interval_2ndTarget_saccade = NaN;
                end
                if (size(Offset,1) > 1)
                    if ~isnan(Offset(2,2)) && ~isnan(onset(2,2))
                        duration2 = Offset(2,2) - onset(2,2);                   %duration of the corrective saccade
                        amplitude2 = euclideanDistance(...
                            positionX(onset(2,2)), positionX(Offset(2,2)), ...
                            positionY(onset(2,2)), positionY(Offset(2,2)));     %amplitude of the corrective saccade
                    else
                        duration2 = NaN;
                        amplitude2 = NaN;
                    end
                else
                        duration2 = NaN;
                        amplitude2 = NaN;
                end
                peakVelocity2 = saccades(2,1);
                %output
                kinematics(i).intersaccadeinterval = ISI;
                kinematics(i).interval_2ndTarget_saccade = interval_2ndTarget_saccade;
                kinematics(i).duration_cor = duration2;
                kinematics(i).amplitude_cor = amplitude2;
                kinematics(i).peakVelocity_cor = peakVelocity2;
            end
        elseif isnan(detected_saccades_fixations(i).saccades(1,1))
            %output
            kinematics(i).reactionTime = NaN;
            kinematics(i).duration_pri = NaN;
            kinematics(i).amplitude_pri = NaN;
            kinematics(i).amplitudeOnset = NaN;
            kinematics(i).amplitudeOnset50 = NaN;
            kinematics(i).peakVelocity_pri = NaN;
            kinematics(i).intersaccadeinterval = NaN;
            kinematics(i).interval_2ndTarget_saccade = NaN;
            kinematics(i).duration_cor = NaN;
            kinematics(i).amplitude_cor = NaN;
            kinematics(i).peakVelocity_cor = NaN;
        end
    end
