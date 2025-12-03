function detected_saccades_fixations = findRelevantNumSaccades(...
    detected_saccades_fixations, required_num_saccades, vel_threshold)
%This function takes all detected saccades for each trial in a
%trial-by-trial order and specifies the relevant saccades given the
%required number of saccades based on the trial type (e.g. in case of
%stay-put trials, one saccade is needed and in case of trials with an
%intrasaccadic step, two are needed). 
%
%These specified saccades replace the saccades field in the 
%detected_saccades_fixation struct and those saccades that are not 
%desirable are stored in a new field in the same struct called
%'Extrasaccades'.
%
%NOTE. the following codes in the Extrasaccades field have special
%descrptions as follows:
%   . 0 (zeor): the total number of of detected saccades were the same as
%   the required number of saccades for given trial. No extra saccade
%   available.
%   . -1: not enough saccades were found compared to the required number of
%   saccades.
%
%NOTE the logic of this script is the simple fact that the first one or two
%detected saccades when the peaks are sorted time-wise in a descending
%fashion are the most-likely ones that are desired.
    for i = 1:size(detected_saccades_fixations,2)
%         disp(i);
        temp_detected_saccades = detected_saccades_fixations(i).saccades;
        temp_all_saccades = detected_saccades_fixations(i).allsaccades;
        temp_num_saccades = required_num_saccades(i);
        if ~isnan(temp_detected_saccades(1,1))
            %if the number of detected saccades are larger than the
            %required number of saccades
            if size(temp_detected_saccades,1) > temp_num_saccades
                %sort saccades in a ascending time fashion 
                temp_detected_saccades = sortSaccades_ascendingTime(temp_detected_saccades);
                temp_all_saccades = sortSaccades_ascendingTime(temp_all_saccades);
                %keep the first one or two upper rows in a new variable
                temp_retained_saccades = temp_detected_saccades(1:temp_num_saccades,:);
                if temp_retained_saccades(1) < vel_threshold && ...
                    ~isempty(temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:))
                    tamp_all_aboveThreshold = temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:);
                    tamp_all_aboveThreshold = sortSaccades_ascendingTime(tamp_all_aboveThreshold);
                    temp_retained_saccades = tamp_all_aboveThreshold(1,:);
                else
                    detected_saccades_fixations(i).saccades = NaN;
                    detected_saccades_fixations(i).Extrasaccades = NaN;
                end
                %remove them from the pool
                temp_detected_saccades(1:temp_num_saccades,:) = [];
                %rearrange the matrix in a descending peak height fashion
                temp_detected_saccades = sortSaccades_descendingHeight(temp_detected_saccades);
                %assign it to a new field
                detected_saccades_fixations(i).Extrasaccades = temp_detected_saccades;
            %if the total number of detected saccades is just enough
            elseif size(temp_detected_saccades,1) == temp_num_saccades
                %all the detected saccades must be retained
                temp_retained_saccades = temp_detected_saccades;
                if temp_retained_saccades(1) < vel_threshold && ...
                    ~isempty(temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:))
                    tamp_all_aboveThreshold = temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:);
                    tamp_all_aboveThreshold = sortSaccades_ascendingTime(tamp_all_aboveThreshold);
                    temp_retained_saccades = tamp_all_aboveThreshold(1,:);
                else
                    detected_saccades_fixations(i).saccades = NaN;
                    detected_saccades_fixations(i).Extrasaccades = NaN;
                end
                % value zero is assigned to the field below
                detected_saccades_fixations(i).Extrasaccades = 0;
            %if the total number of saccades are less than the number
            %required. This happens usually for outward or inward
            %intrasaccadic step type of trials where two saccades are
            %needed but only one following the primary shift in time is
            %available
            elseif size(temp_detected_saccades,1) < temp_num_saccades
                %all the detected saccades must be retained
                temp_retained_saccades = temp_detected_saccades;
                if temp_retained_saccades(1) < vel_threshold && ...
                    ~isempty(temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:))
                    tamp_all_aboveThreshold = temp_all_saccades(temp_all_saccades(:,1) >= vel_threshold,:);
                    tamp_all_aboveThreshold = sortSaccades_ascendingTime(tamp_all_aboveThreshold);
                    temp_retained_saccades = tamp_all_aboveThreshold(1,:);
                else
                    detected_saccades_fixations(i).saccades = NaN;
                    detected_saccades_fixations(i).Extrasaccades = NaN;
                end
                % value zero is assigned to the field below
                detected_saccades_fixations(i).Extrasaccades = -1;
            end
            %rearrange the matrix in a descending peak height fashion
            temp_retained_saccades = sortSaccades_descendingHeight(temp_retained_saccades);
            %reassign it to the respected saccades field in the
            %detected_saccades_fixations struct
            detected_saccades_fixations(i).saccades = temp_retained_saccades;    
        %if the saccades' value in NaN in the detected_saccades_fixations
        else
            detected_saccades_fixations(i).saccades = NaN;
            detected_saccades_fixations(i).Extrasaccades = NaN;
        end
    end
        