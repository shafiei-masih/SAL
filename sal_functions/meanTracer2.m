function [meanTraces_temp, details_temp] = meanTracer2(session)
%direction
direction = [session.IDs.direction]; 
direction(direction(:,1) == -1,1) = 0; %1:right
% idx_right = find(direction(:,1) ==1);
% idx_left = find(direction(:,1) ==0);

%reward
%     reward = [session.IDs.reward];
reward = session.TrialList(:,41);
reward(reward < 0,1) = NaN;
reward_levels = unique(reward, 'sorted');
reward_levels = reward_levels(~isnan(unique(reward, 'sorted')));
assert(reward_levels(1) < reward_levels(2));
reward(reward == reward_levels(1),1) = 0;
reward(reward == reward_levels(2),1) = 1;
idx_reward = find(reward(:,1) ==1);
idx_control = find(reward(:,1) ==0);

%ISS
ISS = [session.IDs.trialType];
idx_inISS = find(ISS(:,1) == 3); %inward intra-saccadic step
idx_outISS = find(ISS(:,1) == 2); %outward intra-saccadic step
idx_noISS = find(ISS(:,1) == 1); %No intra-saccadic step

% Specify valid trials based on the presence of ISS and reward/control
idx_reward_control = sort(vertcat(idx_reward, idx_control), 'ascend');
idx_validISS = sort(vertcat(idx_inISS, idx_outISS, idx_noISS), 'ascend');
idx_valid = intersect(idx_reward_control, idx_validISS);
trialID = [1:length(direction)]';
validTrial = trialID;
validTrial(1,1) = 00;
validTrial(idx_valid) = 1;
validTrial(validTrial ~= 1) = 0;

sessionValidTrials = session.valid_Trials;
validTrial(sessionValidTrials ~= 0) = 0;

clearvars idx_inISS idx_outISS idx_noISS idx_reward_control  idx_validISS idx_valid;

% Target Jump time
raw_targetX_shift = [session.raw_targetX_shift];
targetShifts = targetShiftsExtractor(raw_targetX_shift);
[targetShift_primary, targetShift_secondary] = extract_1st_2nd_shiftTimes(targetShifts);
tjTime = targetShift_primary;

% onset and offset of primary saccade extractor
[onset, offset] = onNoffsetDetector(session);


% onset =  [session.detected_saccades_fixations.saccade_onset]';       %onset(s)
% offset = [session.detected_saccades_fixations.saccade_offset];     %offset(s)
%% Polish trials based on kinematics
amplitude_p = [session.kinematics.amplitude_pri]';
duration_p = [session.kinematics.duration_pri]';
RT_p = [session.kinematics.reactionTime]';

validTrial(find(amplitude_p < 15),1) = 0;
validTrial(find(amplitude_p > 24.68),1) = 0;

validTrial(find(duration_p <= 40),1) = 0;
validTrial(find(duration_p >= 180),1) = 0;

validTrial(find(RT_p >= 800),1) = 0;

%% trace
vel = [session.fundamentals.vel];
meanRT_p_reward = round(mean(RT_p(validTrial == 1 & reward ==1), 'omitnan'));
meanRT_p_control = round(mean(RT_p(validTrial == 1 & reward ==0), 'omitnan'));
% meanRT_p_reward_L = round(mean(RT_p(validTrial == 1 & reward ==1 & direction == 0), 'omitnan'));
% meanRT_p_control_L = round(mean(RT_p(validTrial == 1 & reward ==0 & direction == 0), 'omitnan'));

% trace = NaN(size(vel,1), meanRT_p_control + 300);
trace = NaN(size(vel,1), 1000);
for triali = 1:size(vel,1)
    if (validTrial(triali) == 1) && (~isnan(onset(triali)))
        onset_temp = onset(triali);
        vel_temp = vel(triali, :);
        if ismember(triali, idx_reward) 
            trace_temp = vel_temp(onset_temp - meanRT_p_reward  - 200 :onset_temp + 150);
%         elseif ismember(triali, idx_reward) && (direction(triali) == 0) 
%             trace_temp = vel_temp(onset_temp - meanRT_p_reward_L  - 200 +1 :onset_temp + 150);
        elseif ismember(triali, idx_control)
            trace_temp = vel_temp(onset_temp - meanRT_p_control - 200 :onset_temp + 150);
%         elseif ismember(triali, idx_control) && (direction(triali) == 0)
%             trace_temp = vel_temp(onset_temp - meanRT_p_control_L - 200 +1 :onset_temp + 150);
        end
        trace(triali, 1:size(trace_temp,2)) = trace_temp;
    end
    
end

% mean traces for reward and control
mean_rew = mean(trace((validTrial == 1 & reward == 1),:), 1, 'omitnan');
% mean_rew_L = mean(trace((validTrial == 1 & reward == 1 & direction == 0),:), 1, 'omitnan');
mean_con = mean(trace((validTrial == 1 & reward == 0),:), 1, 'omitnan');
% mean_con_L = mean(trace((validTrial == 1 & reward == 0 & direction == 0),:), 1, 'omitnan');

meanTraces_temp = vertcat(mean_rew, mean_con);
%% other details

rew = [1; 0];
avgRT = [meanRT_p_reward; meanRT_p_control];
jumpTime = repmat((200), 2,1);
N = vertcat(size(RT_p(validTrial == 1 & reward ==1),1), ...
            size(RT_p(validTrial == 1 & reward ==0),1));


details_temp = horzcat(N, rew, avgRT, jumpTime);
end


    



