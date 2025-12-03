function detected_saccades_fixations = findSaccadeOnset(detected_saccades_fixations, vel)
%This function finds the onset of saccades as the local minima between the
%last fixation point with a velocity below a global threshold and a given
%saccde.
%The global threshold is calculated trial-by-trial as the mean velocity of 
%all fixations plus three times their standard deviatioin.
%
%Input arguments:
%   . detetcted_saccades_fixations <struct>
%   . vel <double>
%
%Returns:
%   . adds a field to the fields of detected_saccades_fixations called
%   'saccade_onset'
    temp_local_minima = [];
    for i = 1 : size(detected_saccades_fixations,2)
%         disp(i);
        temp_saccades = detected_saccades_fixations(i).saccades;
        temp_fixations = sortSaccades_ascendingTime(detected_saccades_fixations(i).fixations);
        temp_vel = vel(i,:)';
        if ~isnan(temp_saccades(1,1))
            temp_threshold = nanmean(temp_fixations(:,1)) + (3*std(temp_fixations(:,1)));
            temp_local_minima(:,:) = [];
            for j = 1:size(temp_saccades,1)
                disp(j);
                %find the index of the first element in temp_fixation whose
                %timestamp immediately precedes the timestamp of a given
                %saccade(j). 
                temp_window_onset_idx = find(temp_fixations(:,2) < temp_saccades(j,2), 1, 'last');
                %in case the value of the last fixation point before a
                %given saccade is above or equal to the threshold, the last
                %fixation point whose value is below the threshold is
                %chosen
                if temp_fixations(temp_window_onset_idx,1) >= temp_threshold
                    temp_window_onset_idx = find(temp_fixations(1:temp_window_onset_idx,1) < temp_threshold, 1, 'last');
                end
                %extract the true index of the above index
                temp_window_onset = temp_fixations(temp_window_onset_idx,2);
                %find the index of the first element in the vel data of trial(i
                %) between the timestamp of the last fixation point before 
                %saccade(j) and the timestamp of saccade(j) whose value is
                %larger than the threshold
                temp_window_offset_idx = find(temp_vel(temp_window_onset:temp_saccades(j,2),1) > temp_threshold, 1, 'first');
                %find the true index of the above index
                temp_window_offset = temp_window_onset + temp_window_offset_idx - 1;
                %create a matrix with col1 velocity and col2 corresponding
                %indices of the datapoint in the vel data of a given trial that
                %falls between and includes the timestamp of the last fixation
                %point before a given saccade(j) and the timestamp of the first
                %point in velocity data where the vel value is just above the
                %vel_threshold.
                temp_vel_section = horzcat(temp_vel(temp_window_onset:temp_window_offset,1), [temp_window_onset:temp_window_offset]');
                %find the local minima in the temp_vel_section and the
                %corresponding true index and vel value.
                temp_local_minima(j,:) = temp_vel_section(islocalmin(temp_vel_section(:,1)),:);
            end
            detected_saccades_fixations(i).saccade_onset = temp_local_minima;
        else
            detected_saccades_fixations(i).saccade_onset = NaN;
        end
    end