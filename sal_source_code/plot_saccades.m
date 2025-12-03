%% plot
list_saccades = [];
for i =1:size(detected_saccades_fixations,2)
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        list_saccades = [list_saccades; i];
    else 
        continue;
    end
end
num_saccades_ToReview = round(0.1*length(list_saccades));
idx_list_saccades = randi(length(list_saccades), num_saccades_ToReview,1);
figure;
% list_new = [161;258;292;302;349;577];
list_saccades = limbo_trials;
for j = 1: size(list_saccades,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
    disp(j);
    clf;
    trial_no = list_saccades(j);%i;
%     trial_no = i;
    disp(['Trial no.: ', num2str(trial_no), '%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    plot(fundamentals.vel(trial_no,:), 'ko'); hold on; 
    plot(fundamentals.vel(trial_no,:), 'b-')
    plot(fundamentals.acc(trial_no,:), 'c-')
    plot(detected_saccades_fixations(trial_no).saccade_offset(1,2),...
        detected_saccades_fixations(trial_no).saccade_offset(1,1), 'mo')
    if size(detected_saccades_fixations(trial_no).saccade_offset,1) > 1
        plot(detected_saccades_fixations(trial_no).saccade_offset(2,2),...
        detected_saccades_fixations(trial_no).saccade_offset(2,1), 'mo')
    end
    plot(detected_saccades_fixations(trial_no).fixations(:,2),detected_saccades_fixations(trial_no).fixations(:,1), 'go')
    plot(detected_saccades_fixations(trial_no).saccades(:,2),detected_saccades_fixations(trial_no).saccades(:,1), 'ro')
    plot(detected_saccades_fixations(trial_no).saccade_onset(:,2),detected_saccades_fixations(trial_no).saccade_onset(:,1), 'mo')
    plot(fundamentals.TargetX(trial_no,:)*20);
    plot(fundamentals.EyeX(trial_no,:)*20);
%     title(['Trial number: ', num2str(trial_no), ' - ', 'Trial type: ', ...
%         num2str(targetX_Shift(trial_no).target_ShiftType), ...
%         ' - Threshold1: ', num2str(offset(trial_no).threshold1)]);
    legend('velocity samples', 'velocity line', 'fixation', 'saccade');
    xlabel('time from the onset of ITI (msec)');
    ylabel('velocity (deg/sec)');
    disp(['mean: ', num2str(nanmean(detected_saccades_fixations(trial_no).fixations(:,1)))]);
    disp(['std: ', num2str(nanstd(detected_saccades_fixations(trial_no).fixations(:,1)))]);
    disp(['mean + 3sd: ', num2str(nanstd(detected_saccades_fixations(trial_no).fixations(:,1))*3+...
        nanmean(detected_saccades_fixations(trial_no).fixations(:,1)))]);
    pause;
%     else
%         continue;
%     end
end