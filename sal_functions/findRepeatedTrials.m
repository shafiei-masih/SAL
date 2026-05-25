% This script find all the mat files and allows you to check out each
% session separately and find the last trial after which the same trial is
% repeated because the monkey didn't attend to the task any longer.
%% list the MAT files
folder_list = dir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\**\*.mat');
% openvar('folder_list')

% remove the undesired ones
folder_list(2) = [];
folder_list(7) = [];
folder_list(32:end) = [];
% folder_list(28:end,:) = [];
%% read files one-by-one and 
% counter = 1;
% i = counter;%4:size(folder_list,1)
for filei = 1:size(folder_list,1)
    clearvars -except filei folder_list counter;
%     destination = [fullfile(folder_list(filei).folder, folder_list(filei).name),...
%         '\Original\Beh'];
%     fileName_temp = dir([destination, '\*.mat']);
    load(fullfile(folder_list(filei).folder, folder_list(filei).name), 'TrialList');
    reward = horzcat(TrialList(:,41),TrialList(:,3));
    clc;
    plot(reward(:,1), 'bo-');
    ylim([-0.5 1])
    disp(folder_list(filei).name);
    disp(folder_list(filei).folder);
    disp(filei);
    txtFilename = 'lastTrialID.txt';
    disp(readmatrix(fullfile(folder_list(filei).folder, txtFilename)));

    % enter the last trial ID  
%     prompt = "What is the last trial ID? ";
%     lastTrial = input(prompt);
%     writematrix(lastTrial, fullfile(destination, 'lastTrialID.txt'));
    % counter = counter + 1;
    pause;
end

