%TITLE: Calculating percentage correct for choices made by the monkey in the 
%free-choice trials in the random error saccadic adaptation paradigm with 
%asymetrical reward schedule
%AUTHOR: SHAFIEI.masih@gamil.com (he/him)
%DATE: 21-Dec-2021
%-------------------------------------------------------------------------%
%This function calculate the percentage correct of the free choice trials.
%This is achieved by looking at the reward signal for free choice trials.
%If the reward signal is generated, i.e. binary code equals 1, the correct
%choice was chosen for a given free choice trial. Otherwise it is zero.
%Input arguments:
% . session: a multi dimentional array
%output:
% . percentage correct. For example, if the output value is 100, it means
%   that 100% of the trials were correct. 
%%
function PCD = Percentage_correct_freeChoice(IDs, reward, TrialList)
    %body -----------------------------------------------------------------
    trialType = IDs.trialType;    % code no. 5 indicates free choice trials
    rew = [reward.delivered]'; % code 1 indicates rewarded trials
    list_freeChoice = find(trialType == 5);
%     tableTrialList = tablize_array(TrialList, "TrialList", 47);
%     assert(isequal(find(tableTrialList{:,35} == 1 & tableTrialList{:,24} == 1), list_freeChoice)) %assert that the free-choice trials read from the session.trialType variable is the same as the ones stored in the trialList matrix
    %Check to see if the free-choice trials were rewarded
    reward_freeChoice = rew(list_freeChoice);
    %output----------------------------------------------------------------
    PCD = (nnz(reward_freeChoice)/length(reward_freeChoice))*100; 