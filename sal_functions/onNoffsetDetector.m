function [onset, offset] = onNoffsetDetector(session)
% this function finds the onset and offset of primary saccades.

onset = NaN(size(session.detected_saccades_fixations,2),1);
offset = NaN(size(session.detected_saccades_fixations,2),1);
for triali = 1:size(session.detected_saccades_fixations,2)
    clear onset_temp onset_temp;
%     disp(i);
    if ~isnan(session.detected_saccades_fixations(triali).saccade_onset(1,1))
         %input
        onset_temp = session.detected_saccades_fixations(triali).saccade_onset(1,2);       %onset(s)
    else
        onset_temp = NaN;
    end
    if ~isnan(session.detected_saccades_fixations(triali).saccade_offset(1,1))
        offset_temp = session.detected_saccades_fixations(triali).saccade_offset(1,2);       %offset(s)
    else
        offset_temp = NaN;
    end
    onset(triali,1) = onset_temp;
    offset(triali,1) = offset_temp;
end
end