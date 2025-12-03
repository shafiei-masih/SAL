function [primary, corrective] = saccadeNumLabeller(raw_targetX_shift, ...
    detected_saccades_fixations, smooth_EyeX, smooth_EyeY, ...
    targetShift_primary, targetShift_secondary)
% Categorize the saccades that are pooled together as primary saccade and 
% corrective saccade into primary (Boolean) and secondary (Boolean). 
% Those trials with primary == 0 & corrective == 1 are the ones that due to
% the low quality of the primary saccade, their primary saccades are
% discaeded in the manually polishing step of preprocessing the data.

%% assign IDs
for i = 1:length([raw_targetX_shift(:).target_ShiftType]')
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        trialType(i,1) = raw_targetX_shift(i).target_ShiftType;
    else
        trialType(i,1) = NaN;
    end
end
%% calculate RTs and amplitudes
kinematics = saccadeKinematicsCalculator(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, targetShift_primary, targetShift_secondary);
%%
RT = [kinematics.reactionTime]';
amp_pri = [kinematics.amplitude_pri]';
figure('Visible','Off');
ax = histfit(RT);
maxRT = max(ax(2).XData) *1.05 ; %max + 5% of the max value
ax =  histfit(amp_pri);
minAmp = min(ax(2).XData) *0.95 ; %min - 5% of the min value
% ISS_idx = find(~isnan(trialType) & (trialType ~=1));
ISS_idx = find(trialType==2 | trialType ==3);
primary = nan(size(trialType));
corrective = nan(size(trialType));
for triali = 1:size(trialType,1)
%     triali = ISS_idx(i);
% disp(i)
    if ~isnan(detected_saccades_fixations(triali).saccades(1,1))
        positionX = smooth_EyeX(triali,:);
        positionY = smooth_EyeY(triali,:);
        saccades = detected_saccades_fixations(triali).saccades;         %saccades
        onset = detected_saccades_fixations(triali).saccade_onset;       %onset(s)
        offset = detected_saccades_fixations(triali).saccade_offset;
        RTi = RT(triali);
        ampi = amp_pri(triali);
        if ismember(triali, ISS_idx)
            if size(saccades,1) < 2
                if ampi < minAmp
                    if RTi > maxRT
                        primary(triali) = 0;
                        corrective(triali) = 1;
                    else
                        primary(triali) = 1;
                        corrective(triali) = 0;
                    end
                else
                    primary(triali) = 1;
                    corrective(triali) = 0;
                end
            else
                primary(triali) = 1;
                corrective(triali) = 1;
            end
        else
            if size(saccades,1) < 2
                primary(triali) = 1;
                corrective(triali) = 0;
            else
                primary(triali) = 1;
                corrective(triali) = 1;
            end
        end
    end
end
%% visulaize
% list = find(primary ==0 & corrective == 1);
% for i = 1: size(list, 1)
%     clf;
%     trial_no = list(i);
%     disp(trial_no);
% %     disp(trialType(trial_no));
%     plot(vel(trial_no,:), 'ko')
%     hold on; 
%     plot(vel(trial_no,:), 'b-')
%     plot(TargetX(trial_no,:)*20);
%     plot(detected_saccades_fixations(trial_no).saccades(:,2),detected_saccades_fixations(trial_no).saccades(:,1), 'ro')
%     clear ax
%     pause;
% end