%% find and list data files
addpath('G:\Other computers\My Computer (1)\HIH\M Project\RL Projects\RL1\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey F\Functions')
file = dir([file(1).folder, '\**\*.final.mat']);
list = file;
%% looping over the list of MAT files to run the saccade detection algorithm
% sessionPath = 'J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data\10032021_14012022\Individual sessions';
list_freeChoice = [];
for filei = 1:size(list,1)
    disp(filei); tic;
    sessionPath = list(filei).folder;
    fileID = list(filei).name;
    load(fullfile(sessionPath, fileID), 'session');
    list_freeChoice_temp = freeChoiceTrials(session);
    list_freeChoice_temp = horzcat(repmat(filei, ...
        size(list_freeChoice_temp,1),1), list_freeChoice_temp);
    list_freeChoice = vertcat(list_freeChoice, list_freeChoice_temp);
    
    clearvars -except filei list sessionPath list_freeChoice file
    toc;
end
%% convert to table
table_r = array2table(list_freeChoice);
varNames = {'session_no'; 'trialId'; 'block'; 'direction'; 'choice'; ...
    'percent'};
table_r.Properties.VariableNames = varNames;
%% store
storePath = file(1).folder;
storeName = 'df_freeChoice.csv';
writetable(table_r, fullfile(storePath, storeName), ...
    'WriteVariableNames', true);
