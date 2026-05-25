function visualError = visualErrorCalculator(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, trialtype, ...
    primary, corrective)
% This function calculates the following visual errors in the position
% domain:
%   1. error_X1, error_Y1, error_size1: end-point error of the PRIMARY
%   saccade calculated as the difference between the offset coordinates and 
%   location of the target after the PRIMARY shift along X-axis and Y-axis.
%   Additionally, the length of the line connecting the saccade offset X-Y
%   coordinates and the target location after the PRIMARY target
%   displacement is calculated (error_size1).
%
%   2. error_X2, error_Y2, error_size2: the same concept as no.1 is used
%   with the difference that SECONDARY saccade offset coordinates and
%   target location after the SECONDARY target shift are used.
%
%   3. ierrorX, ierrorY, ierror: induced end-point error of the PRIMARY
%   saccade calculated as the difference between the offset coordinates and 
%   location of the target after the SECONDARY shift along X-axis and Y-axis.
%   Additionally, the length of the line connecting the saccade offset X-Y
%   coordinates and the target location after the SECONDARY target
%   displacement is calculated (ierror).
%
% Algorithm:
% |---- 1 No NaN for saccades 
%           |---- 2 primary saccade == 1
%                       |---- 3 corrective saccade == 1
%                       |---- 4 corrective saccade == 0
%           |---- 5 primary saccade == 0 && corrective saccade == 1
%|---- 6 NaN for saccades
%                            |1|2|3|4|5|6|
% visualError(i).offsetX50   |-|1|1|1|0|N|
% visualError(i).offsetXavg  |-|1|1|1|0|N|
% visualError(i).error_X1    |-|1|1|1|0|N|
% visualError(i).error_Y1    |-|1|1|1|0|N|
% visualError(i).error_size1 |-|1|1|1|0|N|
% visualError(i).error_X2    |-|0|1|0|1|N|
% visualError(i).error_Y2    |-|0|1|0|1|N|
% visualError(i).error_size2 |-|0|1|0|1|N|
% visualError(i).ierrorX     |-|1|1|0|0|N|
% visualError(i).ierrorY     |-|1|1|0|0|N|
% visualError(i).ierror      |-|1|1|0|0|N|
% visualError(i).error_X1avg |-|1|1|0|0|N|
% visualError(i).error_X150  |-|1|1|0|0|N|
% visualError(i).ierrorX50   |-|1|1|0|0|N|
% visualError(i).ierrorXavg  |-|1|1|0|0|N|
%
% For no. 4: all induced errors are 0, becuase the reason why the
% corrective saccade is 0 is not clear. One possible reason is the
% inoccurrence of a secondary target shift. If this should be the case,
% then calculating an induced error is no longer valid.
%
% Input arguments:
%   1. smooth_EyeX: used to extract the eye position at the primary or
%   secondary saccade offset.
%
%   2. smooth_EyeY: used to extract the eye position at the primary or
%   secondary saccade offset.
%
%   3. detected_saccades_fixations: time-stamps of the offset of the
%   detected saccades.
%
%   4. trialType: type of Intra-saccadic step is used to know whether a
%   secondary target shift occurred or not. If so, the location of the
%   target afterwards is 23 or 17.
%
%
% Returns:
%   . A multidimensional array (visualError) with 9 numerical variables and
%   one string variable. The numerical variables contain different errors
%   that are explained above. The string varaible keeps a summary of the
%   method of calculation of each of the numerical variables.
%
% Hint: ierrorX is the most useful variable as it contains the visual 
% errors between the offset of primary saccade and the target location at 
% the time when the primary saccade was completed. Target location at the
% primary saccade offset is 23 (outward ISS), 17 (inward ISS) or 20
% (stay-put).
%
% Example:
% smooth_EyeX = [session.fundamentals.smooth_EyeX];
% smooth_EyeY = [session.fundamentals.smooth_EyeY];
% detected_saccades_fixations = session.detected_saccades_fixations;
% trialtype = [session.raw_targetX_shift.target_ShiftType]';
% visualError = visualErrorCalculator(smooth_EyeX, smooth_EyeY, ...
%     detected_saccades_fixations, trialtype);

% Algorithm:
% |---- 1 No NaN for saccades 
%           |---- 2 primary saccade == 1
%                       |---- 3 corrective saccade == 1
%                       |---- 4 corrective saccade == 0
%           |---- 5 primary saccade == 0 && corrective saccade == 1
%|---- 6 NaN for saccades

for i = 1:size(detected_saccades_fixations,2) 
    disp(i)
    if ~isnan(detected_saccades_fixations(i).saccades(1,1)) %1
        
        positionX = smooth_EyeX(i,:);
        positionY = smooth_EyeY(i,:);
%         saccades = detected_saccades_fixations(i).saccades;         %saccades
%         onset = detected_saccades_fixations(i).saccade_onset;       %onset(s)
        offset = detected_saccades_fixations(i).saccade_offset;     %offset(s)
        if ~isnan(offset)
            %-----------------------------------------------------------------%
            %% endpoint50 and average endpoint
            % finding the position endpoint at 50 ms after the detected end point
            % using a velocity threshold on the velocity domoain data. And, 
            % compute the average position over a 50-ms bin asymetrically
            % centered around the endpoint50 (from endpoint50 - 10 to
            % endpoint50 + 39).
            endIndex = tbt_lastNonNaN_Index(positionX);
            % usually the very last 30 position data points are very niosy
            % because of the filtering induced edge effect. Therefore, the last
            % 30 points are excluded from endpoint50 calculation. This skipping
            % is implemented by endIndex - 29 (endIndex is the 30th points).
            % To calculate the endpoint50, 50 data points following the
            % offset are needed after the last 30 noisy data points are
            % excluded.
            if primary(i) == 1 %2
                if endIndex - 29 >= offset(1,2) + 50
                    visualError(i).offsetX50 = [abs(positionX(offset(1,2)+50)), ...
                        offset(1,2)+50]; %[position,index]
                    %To take the average position over a 50-ms-long window that
                    %spans over 40 data points following the endpoint50, again, we
                    %need to make sure we have enough point left in the vector
                    %before reaching the last 30 noisy data points.
                    if endIndex - 29 >= visualError(i).offsetX50(1,2) + 39
                        visualError(i).offsetXavg = ...
                            abs(mean(positionX(visualError(i).offsetX50(1,2)-10:...
                            visualError(i).offsetX50(1,2)+39)));
                    elseif endIndex - 29 < visualError(i).offsetX50(1,2) + 39
                        visualError(i).offsetXavg = NaN;
                    end
                elseif endIndex - 29 < offset(1,2) + 50
                    visualError(i).offsetX50 = NaN;
                    visualError(i).offsetXavg = NaN;
                end
            %-----------------------------------------------------------------%
                %% Primary saccade endpoint error
                % error between the primary saccade end-point and the primary
                % target location
                visualError(i).error_X1 = abs(positionX(offset(1,2))) - 20; %predicted - observed -> undershoots have negative values while overshoots are positive
                visualError(i).error_Y1 = positionY(offset(1,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                visualError(i).error_size1 =  euclideanDistance(...            
                                                abs(positionX(offset(1,2))), 20,...
                                                positionY(offset(1,2)), 0);
                %% Primary saccade endpoint50 error
                if ~isnan(visualError(i).offsetX50(1,1))
                            visualError(i).error_X150 = ...
                                abs(visualError(i).offsetX50(1,1)) - 20;
                    if ~isnan(visualError(i).offsetXavg(1,1))
                        visualError(i).error_X1avg = ...
                            abs(visualError(i).offsetXavg) - 20;
                    else
                        visualError(i).error_X1avg = NaN;
                    end
                else
                    visualError(i).error_X150 = NaN;
                    visualError(i).error_X1avg = NaN;
                end
            %% Corrective saccade endpoint error
            %error between the secondary saccade end-point and the secondary
            %target location
                if corrective(i) == 1 %3
                    %type of ISS
                    if trialtype(i) == 2 %actual outward
                        visualError(i).error_X2 = abs(positionX(offset(2,2))) - 23; %predicted - observed -> undershoots have negative values while overshoots are positive
                        visualError(i).error_Y2 = positionY(offset(2,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                        visualError(i).error_size2 =  euclideanDistance(...            
                                                        abs(positionX(offset(2,2))), 23,...
                                                        positionY(offset(2,2)), 0);
                        %induced error (ierror): the difference in position between
                        %primary saccade offset and target after ISS, in this case
                        %outward ISS
                        visualError(i).ierrorX = abs(positionX(offset(1,2))) - 23;
                        visualError(i).ierrorY = positionY(offset(1,2));
                        visualError(i).ierror = euclideanDistance(...            
                                                        abs(positionX(offset(1,2))), 23,...
                                                        positionY(offset(1,2)), 0);
                        if ~isnan(visualError(i).offsetX50(1,1))
                            visualError(i).ierrorX50 = ...
                                abs(visualError(i).offsetX50(1,1)) - 23;
                            if ~isnan(visualError(i).offsetXavg(1,1))
                                visualError(i).ierrorXavg = ...
                                    abs(visualError(i).offsetXavg(1,1)) - 23;
                            else
                                visualError(i).ierrorXavg = NaN;
                            end
                        else
                            visualError(i).ierrorX50 = NaN;
                        end
                    elseif trialtype(i) == 3 %inward
                        visualError(i).error_X2 = abs(positionX(offset(2,2))) - 17; %predicted - observed -> undershoots have negative values while overshoots are positive
                        visualError(i).error_Y2 = positionY(offset(2,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                        visualError(i).error_size2 =  euclideanDistance(...            
                                                        abs(positionX(offset(2,2))), 17,...
                                                        positionY(offset(2,2)), 0);
                        %induced error (ierror): the difference in position between
                        %primary saccade offset and target after ISS, in this case
                        %outward ISS
                        visualError(i).ierrorX = abs(positionX(offset(1,2))) - 17;
                        visualError(i).ierrorY = positionY(offset(1,2));
                        visualError(i).ierror = euclideanDistance(...            
                                                        abs(positionX(offset(1,2))), 17,...
                                                        positionY(offset(1,2)), 0);
                        if ~isnan(visualError(i).offsetX50(1,1))
                            visualError(i).ierrorX50 = ...
                                abs(visualError(i).offsetX50(1,1)) - 17;
                            if ~isnan(visualError(i).offsetXavg(1,1))
                                visualError(i).ierrorXavg = ...
                                    abs(visualError(i).offsetXavg(1,1)) - 17;
                            else
                                visualError(i).ierrorXavg = NaN;
                            end
                        else
                            visualError(i).ierrorX50 = NaN;
                        end
                    % else
                    %     if ~isnan(additionalSaccades_type(i))
                    %         % given than for both types of additional corrective
                    %         % saccades final target postion is the same, there is
                    %         % no need to separately run the analysis for each type.
                    %         visualError(i).error_X2 = abs(positionX(offset(2,2))) - 20; %predicted - observed -> undershoots have negative values while overshoots are positive
                    %         visualError(i).error_Y2 = positionY(offset(2,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                    %         visualError(i).error_size2 =  euclideanDistance(...            
                    %                                         abs(positionX(offset(2,2))), 20,...
                    %                                         positionY(offset(2,2)), 0);
                    %         %induced error (ierror): the difference in position between
                    %         %primary saccade offset and target, in this case
                    %         %additional corrective saccade
                    %         visualError(i).ierrorX = abs(positionX(offset(1,2))) - 20;
                    %         visualError(i).ierrorY = positionY(offset(1,2));
                    %         visualError(i).ierror = euclideanDistance(...            
                    %                                         abs(positionX(offset(1,2))), 20,...
                    %                                         positionY(offset(1,2)), 0);
                    %         if ~isnan(visualError(i).offsetX50(1,1))
                    %             visualError(i).ierrorX50 = ...
                    %                 abs(visualError(i).offsetX50(1,1)) - 20;
                    %             if ~isnan(visualError(i).offsetXavg(1,1))
                    %                 visualError(i).ierrorXavg = ...
                    %                     abs(visualError(i).offsetXavg(1,1)) - 20;
                    %             else
                    %                 visualError(i).ierrorXavg = NaN;
                    %             end
                    %         else
                    %             visualError(i).ierrorX50 = NaN;
                    %         end
                    %     else
                    %         %stay-put trials and NaNs
                    %         visualError(i).error_X2 = NaN;
                    %         visualError(i).error_Y2 = NaN;
                    %         visualError(i).error_size2 = NaN;
                    %         visualError(i).ierrorX = NaN;
                    %         visualError(i).ierrorY = NaN;
                    %         visualError(i).ierror = NaN;
                    %         visualError(i).ierrorXavg = NaN;
                    %         visualError(i).ierrorX50 = NaN;
                    %     end
                    end
                elseif corrective(i) == 0  %4   %trials without a detected secondary saccade
                    %if it is a stay-put trial
    %                 if trialtype(i) == 1
                        visualError(i).error_X2 = NaN;
                        visualError(i).error_Y2 = NaN;
                        visualError(i).error_size2 = NaN;
                        visualError(i).ierrorX = NaN;
                        visualError(i).ierrorY = NaN;
                        visualError(i).ierror = NaN;
                        visualError(i).ierrorX50 = NaN;
                        visualError(i).ierrorXavg = NaN;
    %                 else
    %                     visualError(i).error_X2 = NaN;
    %                     visualError(i).error_Y2 = NaN;
    %                     visualError(i).error_size2 = NaN;
    %                     visualError(i).ierrorX = NaN;
    %                     visualError(i).ierrorY = NaN;
    %                     visualError(i).ierror = NaN;
    %                     visualError(i).ierrorX50 = NaN;
    %                     visualError(i).ierrorXavg = NaN;
    %                 end
                end
            elseif primary(i) == 0 && corrective(i) == 1 %5

                %type of ISS
                    if trialtype(i) == 2 %actual outward
                        visualError(i).error_X2 = abs(positionX(offset(1,2))) - 23; %predicted - observed -> undershoots have negative values while overshoots are positive
                        visualError(i).error_Y2 = positionY(offset(1,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                        visualError(i).error_size2 =  euclideanDistance(...            
                                                        abs(positionX(offset(1,2))), 23,...
                                                        positionY(offset(1,2)), 0);
                    elseif trialtype(i) == 3 %inward
                        visualError(i).error_X2 = abs(positionX(offset(1,2))) - 17; %predicted - observed -> undershoots have negative values while overshoots are positive
                        visualError(i).error_Y2 = positionY(offset(1,2));           % if postionY < 0 => undershoot and if > 0 => overshoot
                        visualError(i).error_size2 =  euclideanDistance(...            
                                                        abs(positionX(offset(1,2))), 17,...
                                                        positionY(offset(1,2)), 0);
                    end
                visualError(i).offsetX50 = NaN;
                visualError(i).offsetXavg = NaN;
                visualError(i).error_X1 = NaN; 
                visualError(i).error_Y1 = NaN;           
                visualError(i).error_size1 = NaN;
                visualError(i).error_X150 = NaN;
                visualError(i).error_X1avg = NaN;
                visualError(i).ierrorX = NaN;
                visualError(i).ierrorY = NaN;
                visualError(i).ierror = NaN;
                visualError(i).ierrorXavg = NaN;
                visualError(i).ierrorX50 = NaN;
            end
        else
            visualError(i).offsetX50 = NaN;
            visualError(i).offsetXavg = NaN;
            visualError(i).error_X1 = NaN;
            visualError(i).error_Y1 = NaN;
            visualError(i).error_size1 = NaN;
            visualError(i).error_X2 = NaN;
            visualError(i).error_Y2 = NaN;
            visualError(i).error_size2 = NaN;
            visualError(i).ierrorX = NaN;
            visualError(i).ierrorY = NaN;
            visualError(i).ierror = NaN;
            visualError(i).error_X1avg = NaN;
            visualError(i).error_X150 = NaN;
            visualError(i).ierrorX50 = NaN;
            visualError(i).ierrorXavg = NaN;
        end
     elseif isnan(detected_saccades_fixations(i).saccades(1,1)) %6
        visualError(i).offsetX50 = NaN;
        visualError(i).offsetXavg = NaN;
        visualError(i).error_X1 = NaN;
        visualError(i).error_Y1 = NaN;
        visualError(i).error_size1 = NaN;
        visualError(i).error_X2 = NaN;
        visualError(i).error_Y2 = NaN;
        visualError(i).error_size2 = NaN;
        visualError(i).ierrorX = NaN;
        visualError(i).ierrorY = NaN;
        visualError(i).ierror = NaN;
        visualError(i).error_X1avg = NaN;
        visualError(i).error_X150 = NaN;
        visualError(i).ierrorX50 = NaN;
        visualError(i).ierrorXavg = NaN;
    end
end
visualError(1).description = "error_X1 = primary_saccade_offset_along_X-axis - target_position_along_X-Axis_after_primary_shift (a.k.a. 20 deg) ";
visualError(2).description = "error_Y1 = primary_saccade_offset_along_Y-axis";
visualError(3).description = "error_size1 = euclidean distance between two sets of Xs and Ys from the primary saccade offset and target location after the primary jump";
visualError(4).description = "error_X2 = secondary_saccade_offset_along_X-axis - target_position_along_X-Axis_after_secondary_shift (a.k.a. 23 or 17 deg) ";
visualError(5).description = "error_Y2 = secondary_saccade_offset_along_Y-axis";
visualError(6).description = "error_size2 = euclidean distance between two sets of Xs and Ys from the secondary saccade offset and target location after the secondary jump";
visualError(7).description = "ierrorX (induced error) = primary_saccade_offset_along_X-axis - target_position_along_X-Axis_after_secondary_shift (a.k.a. 23 or 17 deg) ";
visualError(8).description = "ierrorY (induced error) = primary_saccade_offset_along_Y-axis";
visualError(9).description = "ierror  (induced error) = euclidean distance between two sets of Xs and Ys from the primary saccade offset and target location after the secondary jump";
visualError(10).description = "offsetX50  (50 ms after offset) = horizontal position of the eye 50 ms after saccade offset";
visualError(11).description = "offsetXavg  (average) = mean horizontal position averaged over a 50 ms long window started 10 ms before the endpoint50 and ended 40 ms after it";
visualError(12).description = "error_X150  = horizontal error between the endpoint50 and target after primary displacement (20 deg)";
visualError(13).description = "error_X1avg  (average) = the same as error_X150, only instead of endpoint50, mean endpoints are used";
visualError(14).description = "ierrorX50  = horizontal error between the endpoint50 and target after secondary displacement (23 deg or 17 deg)";
visualError(15).description = "ierrorXavg  (average) = the same as ierrorX50, only instead of endpoint50, mean endpoints are used";