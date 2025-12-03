function list_freeChoice = freeChoiceTrials(session)
% This function extracct the details of freeChoice trials for eahc session:
% 1. Trial ID
% 2. block
% 3. direction
% 4. correct or incorrect (based on reward delivery)

%% basic variables
trialType = session.IDs.trialType;    % code no. 5 indicates free choice trials
block = session.IDs.block;
rew = [session.reward.delivered]'; % code 1 indicates rewarded trials
direction = session.IDs.direction;

%% compute the IDs
list_freeChoice = find(trialType == 5);                 %trialID
list_freeChoice(:,2) = block(list_freeChoice(:,1));     %block no.
list_freeChoice(:,3) = direction(list_freeChoice(:,1)); %directionCorrect (1 = right)
list_freeChoice(:,4) = rew(list_freeChoice(:,1));       %correct =1; incorrect = 0
list_freeChoice(:,5) = repmat(session.PercentCorrectFreeChoice, size(list_freeChoice,1),1);

end
