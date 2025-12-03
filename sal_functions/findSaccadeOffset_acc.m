function detected_saccades_fixations = findSaccadeOffset_acc(detected_saccades_fixations, acc)
    offset = [];
    for i = 1 : size(detected_saccades_fixations,2)
        saccades  = detected_saccades_fixations(i).saccades;
        fixations = sortSaccades_ascendingTime(detected_saccades_fixations(i).fixations);
        vel_temp  = vel(i,:)';
        acc_temp  = acc(i,:)';
        if ~isnan(saccades(1,1))
            acc_fixation = horzcat(acc_temp(fixations(:,2)),fixations(:,2));
            threshold_ovarall = nanmean(acc_fixation(:,1)) + (3*std(acc_fixation(:,1)));
            offset(:,:) = [];
            for j = 1:size(saccades,1)
                localThreshold_window_onset_idx = find(fixations(:,2) < saccades(j,2), 1, 'last');
                temp_threshold_window_onset = fixations(localThreshold_window_onset_idx,2);
                acc_section = horzcat(acc_temp(...
                                    temp_threshold_window_onset:-1:...
                                    temp_threshold_window_onset-window_span +1,1), ...
                                    [temp_threshold_window_onset:-1:...
                                    (temp_threshold_window_onset-window_span +1)]');
                threshold_local = nanmean(acc_section(:,1)) ...
                    + (3*std(acc_section(:,1)));
                threshold = (alpha_coeff*threshold_ovarall)...
                    +(beta_coeff*threshold_local);
            
                idx_accBelowThreshold = find(acc_temp(saccades(j,2)+5:end,1) < threshold, 1, 'first');
                temp = saccades(j,2)+5 + idx_accBelowThreshold -1;
                offset(j,:) = [vel_temp(temp, 1), temp];
            end
            detected_saccades_fixations(i).saccade_offset = offset;
        else
            detected_saccades_fixations(i).saccade_offset = NaN;
        end
    end