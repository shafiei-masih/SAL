file = dir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\**\*.mat');
% The following few lines dedicated to remove unwanted files from the list
% of files needs to be adjusted per running
file(2:3) = [];
file(3) = [];
file(4) = [];
file(5) = [];
file(6) = [];
file(7:8) = [];
% file(8:9) = [];
% file(7) = [];
file(8) = [];
file(9) = [];
file(10) = [];
file(11) = [];
file(12) = [];
file(13) = [];
file(14) = [];
file(15) = [];
file(16) = [];
file(32:end) = [];
% file(5) = [];
% file(6) = [];
% file(7:9) = [];
% file(8) = [];
% file(9) = [];
% file(10:11) = [];
% file(11) = [];
% file(31:33) = [];
listfilename = 'listofTrials_temp.mat';
listfilepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
save(fullfile(listfilepath, listfilename), 'file');
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
for filei = 28:size(file,1)
    disp(filei); tic;
    filepath = file(filei).folder;
    filename = file(filei).name;
    load(fullfile(file(filei).folder, file(filei).name), 'EyeX', 'EyeY', 'TrialList', 'TargetX', 'ExtraChannel4');
    scriptPath = 'E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey K\Source code';
    scriptName = 'main.m';
    % open(fullfile(scriptPath, scriptName));
    run(fullfile(scriptPath, scriptName));
    disp(['session ', num2str(filei), ' is complete.']);
    toc;
    clearvars -except filei file
end