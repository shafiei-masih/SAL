%% prepare data for R
%% Load data 
% [filename_final,filepath_final] = uigetfile(...
% 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\*\*.final.mat', ...
% 'enter the behavioral *.final.mat file');
% load(fullfile(filepath_final, filename_final));
%%
file = dir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\**\*.final.mat');
% The following few lines dedicated to remove unwanted files from the list
% of files needs to be adjusted per running
file(32:end) = [];

%store
listfilename = 'listoffinaldatafiles_temp.mat';
listfilepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
save(fullfile(listfilepath, listfilename), 'file');

% load it
listfilename = 'listoffinaldatafiles_temp.mat';
listfilepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
load(fullfile(listfilepath, listfilename))
clearvars listfilename listfilepath;
%% load example session data
%example 2 (with 1 element in the lastTrial.txt)
filepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\25.04122020\Preproc\Beh';
filename = '04122020_1.final.mat';
t = load(fullfile(filepath, filename), 'session');
% filenamemain = filename;
% filepathmain = filepath;
%% Kinematics with NaN
% block
block = [session.IDs.block];
%direction
direction = [session.IDs.direction];
direction(direction(:,1) == -1,1) = 0;
idx_right = find(direction(:,1) ==1);
idx_left = find(direction(:,1) ==0);
%reward
reward = [session.IDs.reward];
idx_reward = find(reward(:,1) ==1);
idx_control = find(reward(:,1) ==0);
%ISS
ISS = [session.IDs.trialType];
idx_inISS = find(ISS(:,1) == 3); %inward intra-saccadic step
idx_outISS = find(ISS(:,1) == 2); %outward intra-saccadic step
idx_noISS = find(ISS(:,1) == 1); %No intra-saccadic step
%kinematics of primary saccade
RT_p = [session.kinematics.reactionTime]';
amplitude_p = [session.kinematics.amplitude_pri]';
PV_p = [session.kinematics.peakVelocity_pri]';
duration_p = [session.kinematics.duration_pri]';
%kinematics of corrective saccade
ISI = [session.kinematics.intersaccadeinterval]'; %inter-saccadic interval
TSI = [session.kinematics.interval_2ndTarget_saccade]'; %target-saccade interval (2nd target and corrective saccade)
amplitude_c = [session.kinematics.amplitude_cor]';
PV_c = [session.kinematics.peakVelocity_cor]';
duration_c = [session.kinematics.duration_cor]';
% Specify valid trials based on the presence of ISS and reward/control
idx_reward_control = sort(vertcat(idx_reward, idx_control), 'ascend');
idx_validISS = sort(vertcat(idx_inISS, idx_outISS, idx_noISS), 'ascend');
idx_valid = intersect(idx_reward_control, idx_validISS);
trialID = [1:length(direction)]';
validTrial = trialID;
validTrial(1,1) = 00;
validTrial(idx_valid) = 1;
validTrial(validTrial ~= 1) = 0;
clear idx_validISS idx_right idx_reward_control idx_outISS idx_reward ...
    idx_noISS idx_left idx_inISS idx_control;
%create the table using the idx_valid to subset the data
r = horzcat(trialID, ...
            block, ...
            validTrial, ...
            direction, ...
            reward, ...
            ISS,...
            RT_p, ...
            PV_p, ...
            duration_p, ...
            amplitude_p, ...
            ISI, ...
            TSI, ...
            PV_c, ...
            duration_c, ...
            amplitude_c);
table_r = array2table(r);
varNames = {'trialId'; 'block'; 'validTrial'; 'direction'; 'reward'; 'ISS'; ...
    'RT_p'; 'PV_p'; 'duration_p'; 'amplitude_p'; ...
    'ISI'; 'TSI'; 'PV_c'; 'duration_c'; 'amplitude_c'};
table_r.Properties.VariableNames = varNames;
%write the table into a CSV file
% directory = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\1.04062020\Preproc\Beh\';
% filename = 'table_kinematics.csv';
filename_new = ['df_', filename_final(1:8), '.csv'];
writetable(table_r, fullfile(filepath_final, filename_new), ...
    'WriteVariableNames', true);
%% visual error
% VE_X_p = [session.visualError.error_X1]';
% VE_Y_p = [session.visualError.error_Y1]';
% VE_size_p = [session.visualError.error_size1]';
% VE_X_c = [session.visualError.error_X2]';
% VE_Y_c = [session.visualError.error_Y2]';
% VE_size_c = [session.visualError.error_size2]';
% iVE_X = [session.visualError.ierrorX]';
% iVE_Y = [session.visualError.ierrorY]';
% iVE_size = [session.visualError.ierror]';
% % block
% block = [session.IDs.block];
% %direction
% direction = [session.IDs.direction];
% direction(direction(:,1) == -1,1) = 0;
% idx_right = find(direction(:,1) ==1);
% idx_left = find(direction(:,1) ==0);
% %reward
% reward = [session.IDs.reward];
% idx_reward = find(reward(:,1) ==1);
% idx_control = find(reward(:,1) ==0);
% %ISS
% ISS = [session.IDs.trialType];
% idx_inISS = find(ISS(:,1) == 3); %inward intra-saccadic step
% idx_outISS = find(ISS(:,1) == 2); %outward intra-saccadic step
% idx_noISS = find(ISS(:,1) == 1); %No intra-saccadic step
% % Specify valid trials based on the presence of ISS and reward/control
% idx_reward_control = sort(vertcat(idx_reward, idx_control), 'ascend');
% idx_validISS = sort(vertcat(idx_inISS, idx_outISS, idx_noISS), 'ascend');
% idx_valid = intersect(idx_reward_control, idx_validISS);
% trialID = [1:length(direction)]';
% validTrial = trialID;
% validTrial(1,1) = 00;
% validTrial(idx_valid) = 1;
% validTrial(validTrial ~= 1) = 0;
% clear idx_validISS idx_right idx_reward_control idx_outISS idx_reward ...
%     idx_noISS idx_left idx_inISS idx_control;
% %create the table using the idx_valid to subset the data
% r = horzcat(trialID, ...
%             block, ...
%             validTrial, ...
%             direction, ...
%             reward, ...
%             ISS,...
%             VE_X_p, VE_Y_p, VE_size_p, ...
%             VE_X_c, VE_Y_c, VE_size_c, ...
%             iVE_X, iVE_Y, iVE_size);
% table_r = array2table(r);
% varNames = {'trialId'; 'block'; 'validTrial'; 'direction'; 'reward'; 'ISS'; ...
%             'VE_X_p'; 'VE_Y_p'; 'VE_size_p'; ...
%             'VE_X_c'; 'VE_Y_c'; 'VE_size_c'; ...
%             'iVE_X';  'iVE_Y'; 'iVE_size'};
% table_r.Properties.VariableNames = varNames;
% %write the table into a CSV file
% directory = 'E:\MEGAsync\MEGAsync\HIH\M Project\Reinforcement learning\Analysis\Analysis Scripts\Behavioral\Reinforcement learning Project\Statistical analysis\R\data files\';
% filename = 'table_VE.csv';
% writetable(table_r, fullfile(directory, filename), ...
%     'WriteVariableNames', true);