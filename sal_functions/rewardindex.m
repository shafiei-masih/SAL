function [reward_idx, unreward_idx] = rewardindex(reward)
    %input
%     reward_delivered = [reward(:).delivered]';
    %calculate &output
    reward_idx = [];
    unreward_idx = [];
%     reward_delivered = reward_delivered;
    for i =1:size(reward,1)
%         disp(i);
        if ~isnan(reward(i))
            if reward(i,1) == 1
                reward_idx = [reward_idx; i];
            elseif reward(i,1) == 0
                unreward_idx = [unreward_idx; i];
            end
        end
    end
    