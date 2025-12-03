function [offset, searchEnds] = offsetThresholdFinder(detected_saccades_fixations, ...
    vel, alpha_coeff1, beta_coeff1, alpha_coeff2, beta_coeff2, ...
    window_span, window_span2, fixed_threshold)

lastNan = tbt_lastNonNaN_Index(vel);
searchEnds = NaN(size(lastNan,1),2);
for i = 1 : size(detected_saccades_fixations,2)
    saccades  = detected_saccades_fixations(i).saccades;
    fixations = sortSaccades_ascendingTime(detected_saccades_fixations(i).fixations);
    vel_t = vel(i,:)';
    if ~isnan(saccades(1,1))
        %calculate the overall threshold based on all the fixation points
        overall_threshold = nanmean(fixations(:,1)) + (3*std(fixations(:,1)));
        for j = 1:size(saccades ,1)
            disp(j);
            %take the current peak height and timestamp
            peak = saccades(j,:);
            %find the first datapoint after the current peak where the
            %points' height falls below the fixed_threshold and correct the
            %timestamp of of the specified datapoint
            if lastNan(i) >= (peak(1,2)+window_span2)
                search_end1 = peak(1,2)+window_span2;
            else
                search_end1 = lastNan(i);
            end
            search_onset = peak(1,2) + ...
                find(vel_t(peak(1,2):search_end1) < fixed_threshold, 1, 'first')...
                -1;
            if lastNan(i) >= (search_onset + window_span2 - 1)
                %the search starts from the search_onset and spans over a
                %window specified by the window_span2. 
                for m = search_onset: search_onset + window_span2 - 1
                    %find the first data point where the height of a given
                    %datapoint is less than the next. The search stops there.
                    if vel_t(m) < vel_t(m+1)
                        window_onset = m;
                        break;
                    end
                end
            else
                if search_onset <= search_end1
                    for m = search_onset: search_end1
                        %find the first data point where the height of a given
                        %datapoint is less than the next. The search stops there.
                        if vel_t(m) < vel_t(m+1)
                            window_onset = m;
                            break;
                        end
                    end
                else
                    offset(i).window1 = NaN;
                    offset(i).threshold1 = NaN;
                    offset(i).window2 = NaN;
                    offset(i).threshold2 = NaN;
                    search_end1 = NaN;
                    search_end2 = NaN;
                end
            end
            
            if lastNan(i) >= (window_onset+window_span-1)
                search_end2 = window_onset + window_span - 1;
                %window_onset that is the timestamp of the point where the
                %first local minima is found is used to specify a window via
                %which the local threshold is calculated.
                local_threshold_window = horzcat(vel_t(...
                    window_onset:window_onset + window_span - 1), ...
                    [window_onset:window_onset + window_span - 1]');
                local_threshold = nanmean(local_threshold_window(:,1)) ...
                    + (3*std(local_threshold_window(:,1)));
            elseif lastNan(i) > window_onset
                search_end2 = lastNan(i);
                local_threshold_window = horzcat(vel_t(...
                    window_onset:search_end2), ...
                    [window_onset:search_end2]');
                local_threshold = nanmean(local_threshold_window(:,1)) ...
                    + (3*std(local_threshold_window(:,1)));
            else
                offset(i).window2 = NaN;
                offset(i).threshold2 = NaN;
            end
            
            if j == 1
                offset(i).threshold1 = (alpha_coeff1*overall_threshold)...
                    +(beta_coeff1*local_threshold);
                offset(i).window1 = local_threshold_window;
                offset(i).threshold2 = NaN;
                offset(i).window2 = NaN;
            elseif j == 2
                offset(i).threshold2 = (alpha_coeff2*overall_threshold)...
                    +(beta_coeff2*local_threshold);
                offset(i).window2 = local_threshold_window;
            end
        end
    else
        offset(i).window1 = NaN;
        offset(i).threshold1 = NaN;
        offset(i).window2 = NaN;
        offset(i).threshold2 = NaN;
        search_end1 = NaN;
        search_end2 = NaN;
    end
    searchEnds(i,:) = [search_end1; search_end2];
end