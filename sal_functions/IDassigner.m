function IDs = IDassigner(reward, targetShifts, raw_targetX_shift, ...
    detected_saccades_fixations, fundamentals, TrialList, ...
    primary, corrective, repititions)
    
for i = 1:size(targetShifts,2)
%         disp(i)
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        if ~isnan(targetShifts(i).time(1))
            if fundamentals.TargetX(i,targetShifts(i).time(1)) > 0
                direction_target(i,1) = 1; %right
            elseif fundamentals.TargetX(i,targetShifts(i).time(1)) < 0
                direction_target(i,1) = -1; %left
            end
        else
            direction_target(i,1) = NaN;
        end
    else
         direction_target(i,1) = NaN;
    end
end
for i = 1:length([raw_targetX_shift(:).target_ShiftType]')
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        trialType(i,1) = raw_targetX_shift(i).target_ShiftType;
    else
        trialType(i,1) = NaN;
    end
end        
%% block number
reward_ids = [reward(:).delivered];
% find trials that must have been rewarded
%********************************************************************
%Note that reward_TrialList might be different from reward_ids since
%the former contains the trials that must have been rewarded while the
%latter lists those rewards that were actually delivered at the end of
%a successfull performance
%********************************************************************
reward_TrialList = TrialList(:,41);
%replace the values greater than one (i.e. rewarded) with one
reward_TrialList(reward_TrialList>0) = 1;
%set indices with NaN in the direction_target as NaN in the reward_TrialList
reward_TrialList(isnan(direction_target)) = NaN;
idx_blockEnd = 0;
blocks = [];
%     for i = 1:size(direction_target,1)
counter =1;
while size(direction_target,1) > counter
%             counter = counter + 1;
%             disp(counter);
    idx_blockStart = idx_blockEnd + 1;
    %find the index of the first rewarded trial starting from the first
    %element of the new block
    idx_1stReward = idx_blockStart + ...
        find(reward_TrialList(idx_blockStart:end,1) == 1, 1, 'first') -1;
    %set the rewarded and unrewarded directions
    rewarded_direction = direction_target(idx_1stReward);
    unrewarded_direction = (-1)*rewarded_direction;
    %specify the indices of the rewarded_direction starting from the first
    %element of the new block
    idxs_rewarded_direction = idx_1stReward + ...
        find(direction_target(idx_1stReward:end) == rewarded_direction) - ...
        1;
    %find the first index where the rewarded direction in the new block
    %is not rewarded anymore
    temp_idx_blockEnd = ...
        idxs_rewarded_direction(find(reward_TrialList(idxs_rewarded_direction,1) ...
        ~= 1, 1, 'first'));
    if ~isempty(temp_idx_blockEnd)
        %from the start of the new block until (and excluding) the first time
        %that the rewarded direction was not rewarded, find the last index 
        %where the rewarded direction was rewarded
        idx_lastReward = idx_blockStart + ...
            find(direction_target(idx_blockStart:temp_idx_blockEnd-1,1) == ...
            rewarded_direction, 1, 'last') -1;
        %if the index of the last time that the rewarded direction was
        %rewarded is not equal to the index just preceding the first time that
        %the rewarded_direction was not rewared, the last element of the
        %block must be an unrewarded trial or NaN. In either cases, the
        %index of such element is assigned to idx_blockEnd
        if idx_lastReward ~= temp_idx_blockEnd -1
            %Within the chosen section (from idx_lastReward to
            %temp_idx_blockEnd -1), all the left valid trials are the ones
            %that are made to the direction that was not rewarded in the
            %current block and is going to be rewarded in the following
            %block. Hence, the last one that is not rewared
            %(reward_TrialList == 0) belongs to and is the last
            %element of the current block.
            idx_blockEnd = idx_lastReward + ...
                find(reward_TrialList(idx_lastReward:temp_idx_blockEnd-1,1) == ...
                0, 1, 'last') - 1;
            %In case such a trial does not exist, this means that all
            %the trials made to the unrewarded direction are rewarded
            %and therefore belong to the following block or they are
            %all NaN.
            if isempty(idx_blockEnd)
                %if the first trial made to the unrewarded direction is
                %rewarded, then it belong to the new block.
                temp_idx_1stNewElement = idx_lastReward +1 + ...
                    find(reward_TrialList(idx_lastReward+1:temp_idx_blockEnd-1,1) == ...
                    1, 1, 'first') - 1;
                % ... This would mean that if the above variable is not
                % empty, it is the first element of the new block.
                % Therefore either the index before that determines the last
                % index of the current block or there is the
                % possibility that there are NaN element in between.
                if ~isempty(temp_idx_1stNewElement)
                    % ... Hence if the lastReward index is equal to the
                    % index of the trial right before the first
                    % element of the new block, then the lastReward
                    % index is the last element of the current block.
                    if idx_lastReward == temp_idx_1stNewElement -1
                        idx_blockEnd = idx_lastReward;
                    %Otherwise, there are NaN trials in between. The
                    %last non-one (which is non-zero as well) must be
                    %the last element of the current trial.
                    elseif idx_lastReward ~= temp_idx_1stNewElement -1
                        idx_blockEnd = idx_lastReward + ...
                        find(reward_TrialList(idx_lastReward:temp_idx_1stNewElement-1,1) ~= ...
                        1, 1, 'last') - 1;
                    end
                %if the trial(s) between the index of last time
                %rewarded direction was rewarde and the first time it
                %was not rewarded are neither rewarded nor unrewarded,
                %they must be NaN, hence the last rewarded trial of the
                %current block is actually the last element of the
                %current block.
                elseif isempty(temp_idx_1stNewElement)
                    idx_blockEnd = idx_lastReward;
                end
            end
        %if the index of the last time that the rewarded direction was
        %rewarded is equal to the index just preceding the last time that
        %the rewarded_direction was not rewared
        elseif idx_lastReward == temp_idx_blockEnd -1
            idx_blockEnd = idx_lastReward;
        end
        blocks = vertcat(blocks, horzcat(idx_blockStart, ...
            idx_blockEnd, rewarded_direction));
        counter = blocks(end, 2)+1;
    else
        %from the start of the new block until (and excluding) the first time
        %that the rewarded direction was not rewarded, find the last index 
        %where the rewarded direction was rewarded
        idx_blockEnd = size(direction_target,1);
%                 idx_lastReward = idx_blockStart + ...
%                     find(direction_target(idx_blockStart:temp_idx_blockEnd-1,1) == ...
%                     rewarded_direction, 1, 'last') -1;
%                 %if the index of the last time that the rewarded direction was
%                 %rewarded is not equal to the index just preceding the first time that
%                 %the rewarded_direction was not rewared, the last element of the
%                 %block must be an unrewarded trial or NaN. In either cases, the
%                 %index of such element is assigned to idx_blockEnd
%                 if idx_lastReward ~= temp_idx_blockEnd -1
%                     %Within the chosen section (from idx_lastReward to
%                     %temp_idx_blockEnd -1), all the left valid trials the ones
%                     %that made to the direction that was not rewarded in the
%                     %current block and is going to be rewarded in the following
%                     %block. Hence, the last one that is not rewared
%                     %(reward_TrialList == 0) belongs to and is the last
%                     %element of the current block.
%                     idx_blockEnd = idx_lastReward + ...
%                         find(reward_TrialList(idx_lastReward:temp_idx_blockEnd-1,1) == ...
%                         0, 1, 'last') - 1;
%                     
%                     %In case such a trial does not exist, this means that all
%                     %the trials made to the unrewarded direction are rewarded
%                     %and therefore belong to the following block or they are
%                     %all NaN.
%                     if isempty(idx_blockEnd)
%                         %if the first trial made to the unrewarded direction is
%                         %rewarded, then it belong to the new block.
%                         if nnz(~isnan(reward_TrialList(idx_lastReward+1:temp_idx_blockEnd-1,1))) > 0
%                             temp_idx_1stNewElement = idx_lastReward +1 + ...
%                                 find(reward_TrialList(idx_lastReward+1:temp_idx_blockEnd-1,1) == ...
%                                 1, 1, 'first') - 1;
%                             % ... This would mean that if the above variable is not
%                             % empty, it is the first element of the new block.
%                             % Therefore either the index before that determines the last
%                             % index of the current block or there is the
%                             % possibility that there are NaN element in between.
%                             if ~isempty(temp_idx_1stNewElement)
%                                 % ... Hence if the lastReward index is equal to the
%                                 % index of the trial right before the first
%                                 % element of the new block, then the lastReward
%                                 % index is the last element of the current block.
%                                 if idx_lastReward == temp_idx_1stNewElement -1
%                                     idx_blockEnd = idx_lastReward;
%                                 %Otherwise, there are NaN trials in between. The
%                                 %last non-one (which is non-zero as well) must be
%                                 %the last element of the current trial.
%                                 elseif idx_lastReward ~= temp_idx_1stNewElement -1
%                                     idx_blockEnd = idx_lastReward + ...
%                                     find(reward_TrialList(idx_lastReward:temp_idx_1stNewElement-1,1) ~= ...
%                                     1, 1, 'last') - 1;
%                                 end
%                             %if the trial(s) between the index of last time
%                             %rewarded direction was rewarde and the first time it
%                             %was not rewarded are neither rewarded nor unrewarded,
%                             %they must be NaN, hence the last rewarded trial of the
%                             %current block is actually the last element of the
%                             %current block.
%                             elseif isempty(temp_idx_1stNewElement)
%                                 idx_blockEnd = idx_lastReward;
%                             end
%                         else
%                             idx_blockEnd = size(direction_target,1);
%                         end
%                     %if the index of the last time that the rewarded direction was
%                     %rewarded is equal to the index just preceding the last time that
%                     %the rewarded_direction was not rewared
%                     elseif idx_lastReward == temp_idx_blockEnd -1
%                         idx_blockEnd = idx_lastReward;
%                     end
%                 else
        if isempty(rewarded_direction)
            if size(direction_target,1) - idx_blockEnd == 0
                rewarded_direction = NaN;
            end
        end
        blocks = vertcat(blocks, horzcat(idx_blockStart, ...
            idx_blockEnd, rewarded_direction));
        counter = blocks(end, 2);
        assert(counter == size(direction_target,1));
    end
end
% if reward is not delivered mistakely, the rewarded direction in a given
% block has a 0 for reward_ids. As a consequence, the algorithm recognize
% is as the begining of a new block. To correct for this mistake, the size
% of the block is check as such blcocks usually are shorther than the
% expected size of 63 trials. In addition, if the 
blockSize = horzcat(blocks(:,2) - blocks(:,1), blocks(:,3));
count = 0;
for blocki = 1:size(blocks,1)
    if blockSize(blocki) < 63
        if blocki ~= size(blocks,1)
            if blocks(blocki,3) == blocks(blocki+1,3)
                    blocks(blocki,2) = blocks(blocki+1,2);
                    blocks(blocki+1,:) =[];
            elseif blocki ~= 1
                if blocks(blocki,3) == blocks(blocki-1,3)
                    blocks(blocki-1,2) = blocks(blocki,2);
                    blocks(blocki,:) =[];
                end
            elseif  blocks(blocki,3) ~= blocks(blocki+1,3)
                temp_unrewarded_idx = blocks(blocki+1,1) + ...
                    find(direction_target(blocks(blocki+1,1):...
                    blocks(blocki+1,2))== (-1)*blocks(blocki,3), ...
                    3, 'first') -1;
                if mean(reward_ids(temp_unrewarded_idx,1)) > 0.5
                    blocks(blocki,2) = blocks(blocki+1,2);
                    blocks(blocki+1,:) =[];
                end
            end
        end
    elseif blockSize(blocki) >= 63
        if blocki ~= size(blocks,1)
            if blocks(blocki,3) == blocks(blocki+1,3)
                    blocks(blocki,2) = blocks(blocki+1,2);
                    blocks(blocki+1,:) =[];
            end
        end        
    end
    count = count + 1;
    if count >= size(blocks,1)
        break;
    end
end
            
                    
%Once the number of trials left are less than or equal to the minimum number of
%trials per block, the remainig trials belong to the last block of
%the session
% if (size(direction_target,1) - idx_blockEnd) <= 63
%     idx_blockStart = idx_blockEnd + 1;
%     idx_blockEnd = size(direction_target,1);
%     blocks = vertcat(blocks, horzcat(idx_blockStart, idx_blockEnd));
% end
%assign codes to the blocks
for i = 1:size(blocks,1)
    block_ids(blocks(i,1): blocks(i,2),1) = i;
end
%Add NaN
block_ids(isnan(direction_target(:,1)),1) = NaN;
%% description of IDs values
description = {'direction', '1=right;-1=left';...
               'trialType', '1=stayput;2=outward;3=inward'; ...
               'reward',    '1=rewarded;0=unrewarded'; ...
               'block_start_end', 'first_column=start; second_column=end'}; 
%%
IDs.direction = direction_target;
IDs.trialType = trialType;
IDs.reward = [reward(:).delivered];
IDs.description = description;
IDs.block = block_ids;
IDs.block_start_end = blocks;
% IDs.additionalSaccades_Bool = additionalSaccades_Bool;
% IDs.additionalSaccades_type = additionalSaccades_type;
IDs.primarySac = primary;
IDs.correctiveSac = corrective;
IDs.repititions = repititions;