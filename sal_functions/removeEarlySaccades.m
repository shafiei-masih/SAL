function detected_saccades = removeEarlySaccades(detected_saccades, ...
    targetShiftTime, minDistanceFromTargetShift)
%This function removes the saccades that are too close to the target shift
%time as it is impossible that they are triggered by the visual target
%given that at least 70 ms time is needed for a visual information to reach
%superior colliculus.
%
%Input arguments:
%   . detected_saccades_fixation <struct>
%   . targetShiftTime: a list of the timestamps of the primary target shift
%                      including freechoice trials
%   . minimum interval between target shift time and a potential saccade
%
%It returns an updeted version of the detected_saccades_fixations in which
%saccades field is updated and undesired saccades are eliminated
%trial-by-trial.
    for i = 1:size(detected_saccades,2)
%         disp(i);
        temp_trial = [detected_saccades(i).saccades];
        if ~isnan(temp_trial(1,1))
            temp_trial = sortSaccades_ascendingTime(temp_trial);
            %if the timestamp of the first detected peak is closer to the
            %targetshifttime than minDistanceFromTargetShift
            if temp_trial(1,2) < (targetShiftTime(i) + minDistanceFromTargetShift - 1)
                %the peak is removed from the pool
                temp_trial(1,:) = [];
                %The remaining peaks are sorted in a descending height
                %fashion
                if ~isempty( temp_trial)
                    temp_trial = sortSaccades_descendingHeight(temp_trial);
                    %they replace the saccades fields of
                    %detected_saccades_fixation for the corresponding trial
                    detected_saccades(i).saccades = temp_trial;
                else
                    detected_saccades(i).saccades = NaN;
                end
            end
        else 
            continue;
        end
    end