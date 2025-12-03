function detected_saccades_fixations = findSaccadeOffset(vel, ...
     detected_saccades_fixations, offset, window_span, window_span2, searchEnds)
    for i = 1: size(offset,2)
        if ~isnan(offset(i).window1(1,1)) && ~isnan(searchEnds(i,1)) && ~isnan(searchEnds(i,2))
            search_end1 = searchEnds(i,1);
            search_end2 = searchEnds(i,2);
            vel_t = vel(i,:);
            peak_index1 = detected_saccades_fixations(i).saccades(1,2);
            threshold1 = offset(i).threshold1;
%             search_onset1 = peak_index1 + ...
%                     find(vel_t(peak_index1:peak_index1+window_span2) < threshold1, 1, 'first')...
%                     -1;
            search_onset1 = peak_index1 + ...
                    find(vel_t(peak_index1:search_end2) < threshold1, 1, 'first')...
                    -1;
            %the search starts from the search_onset and spans over a
            %window specified by the window_span2. 
%             for m = search_onset1:search_onset1 + window_span - 1
            for m = search_onset1:search_end1
                %find the first data point where the height of a given
                %datapoint is less than the next. The search stops there.
                if vel_t(m) < vel_t(m+1)
                    offset1 = m;
                    break;
                end
            end
            offset_temp = [vel_t(offset1), offset1];
            if ~isnan(offset(i).window2(1,1))
                peak_index2 = detected_saccades_fixations(i).saccades(2,2);
                threshold2 = offset(i).threshold2;
%                 search_onset2 = peak_index2 + ...
%                         find(vel_t(peak_index2:peak_index2+window_span) < threshold2, 1, 'first')...
%                         -1;
                search_onset2 = peak_index2 + ...
                        find(vel_t(peak_index2:peak_index2+window_span) < threshold2, 1, 'first')...
                        -1;
                for m = search_onset2:search_onset2 + window_span - 1
                    %find the first data point where the height of a given
                    %datapoint is less than the next. The search stops there.
                    if vel_t(m) < vel_t(m+1)
                        offset2 = m;
                        break;
                    end
                end
                offset_temp = vertcat(offset_temp, [vel_t(offset2), offset2]);
            end
            detected_saccades_fixations(i).saccade_offset = offset_temp;
            clear offset_temp;
        else
            detected_saccades_fixations(i).saccade_offset = NaN;
        end
    end
        