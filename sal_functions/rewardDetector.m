function reward = rewardDetector(detected_saccades_fixations, ...
    ExtraChannel4, window_span, TrialList)
for i = 1:size(ExtraChannel4,1)
%     disp(i);
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        trial = ExtraChannel4(i,:);
        if ~isempty(find(trial(1,:) > 4,1))
            reward_onset = find(trial(1,:) > 4,1);
            reward_offset = reward_onset + ...
                find(trial(1,reward_onset:reward_onset+window_span) < 4,1) -1;
            reward_delivered = 1;
        elseif isempty(find(trial(1,:) > 4,1))
            reward_onset = NaN;
            reward_offset = NaN;
            reward_delivered = 0;
        end
        reward(i).onset = reward_onset;
        reward(i).offset = reward_offset;
        reward(i).delivered = reward_delivered;
    else
        reward(i).onset = NaN;
        reward(i).offset = NaN;
        reward(i).delivered = NaN;
    end
end
if size(reward,2) < size(TrialList,1)
    reward(end +1 ).onset = NaN;
    reward(end).offset = NaN;
    reward(end).delivered = NaN;
end