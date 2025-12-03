file = dir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\**\*.raw.mat');
% The following few lines dedicated to remove unwanted files from the list
% of files needs to be adjusted per running
file(7) = [];
file(32:end) = [];

%store
listfilename = 'listofrawdatafiles_temp.mat';
listfilepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
save(fullfile(listfilepath, listfilename), 'file');

% load it
listfilename = 'listofrawdatafiles_temp.mat';
listfilepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
load(fullfile(listfilepath, listfilename))
clearvars listfilename listfilepath;
%% remove the preprocessed trials
% file_rm = dir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\**\*.*.mat');
% file_rm(14) = [];
% file_rm(19) = [];
% 
% destinPath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\Discard';
% 
% for m = 2:size(file_rm,1)
%     movefile(fullfile(file_rm(m).folder, file_rm(m).name), destinPath);
% end

%% looping over the list of MAT files to run the saccade detection algorithm
for filei = 12:size(file,1)
    disp(filei); tic;
    filepath = file(filei).folder;
    filename = file(filei).name;
    load(fullfile(file(filei).folder, file(filei).name),'EyeX', 'EyeY', ...
        'ExtraChannel4', 'smooth_EyeX', 'smooth_EyeY', ...
        'velX', 'velY', 'vel', 'valid_Trials', 'raw_targetX_shift', ...
        'detected_saccades_fixations', 'acc', ...
        'TargetX', 'TrialList', 'additionalSaccades_Bool', ...
        'additionalSaccades_type', 'repititions');
    scriptPath = 'E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey K\Source code';
    scriptName = 'C_Kinematics.m';
    % open(fullfile(scriptPath, scriptName));
    run(fullfile(scriptPath, scriptName));
    disp(['session ', num2str(filei), ' is complete.']);
    toc;
    clearvars -except filei file
end