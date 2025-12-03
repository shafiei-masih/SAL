function filtered = perf_reward(session)
    valid = session.valid_Trials;
    valid(valid ~= 0) = 99;
    valid(valid ~= 99) = 1;
    valid(valid == 99) = 0;
    
    reward_trial = session.TrialList;
    reward_trial = reward_trial(:,3);
    reward_trial(mod(reward_trial, 2) == 0) = 99;
    reward_trial(reward_trial ~= 99) = 1;
    reward_trial(reward_trial == 99) = 0;
    reward_trial(valid == 0) = NaN;
    
    correct = session.reward';
    correct = [correct.delivered]';
    correct(valid == 0) = NaN;
    
    ISS = session.IDs.trialType;
    ISS(valid == 0) = NaN;
    
    filtered = horzcat(valid, reward_trial, correct, ISS);
end
% 
% nnz(reward_trial == 1)
% nnz(correct == 1)