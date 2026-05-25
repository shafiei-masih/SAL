% This script summarizes the consecutive steps that should be orderly taken
% to import a data frame and detect event-related saccades from raw
% positional x- and y-coordinate data. This scripts also takes care of the
% computations of the following saccade metrics and kinematics:
%   . onset and offset of saccades
%   . Peak velocity of saccades
%% step1: import and prepare data
% rmpath('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\RL Project\Functions')
addpath('G:\Other computers\My Computer (1)\HIH\M Project\RL Projects\RL1\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey F\Functions');
% E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey K\Functions
% [filename,filepath] = uigetfile('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed');
% load(fullfile(filepath, filename), 'EyeX', 'EyeY', 'TrialList', 'TargetX', 'ExtraChannel4');

%load single example files

% %example 1 (with 3 elements in the lastTrial.txt)
% filepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\08.27062020\Original\Beh\';
% filename = 'KRML_1DR_3LV_2020-06-27-09-11-25-749.mat';
% load(fullfile(filepath, filename), ...
%     'EyeX', 'EyeY', 'TrialList', 'TargetX', 'ExtraChannel4');
% 
% %example 2 (with 1 element in the lastTrial.txt)
% filepath = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\06.12062020\Original\Beh';
% filename = 'KRML_1DR_3LV_2020-06-12-15-17-58-615.mat';
% load(fullfile(filepath, filename), ...
%     'EyeX', 'EyeY', 'TrialList', 'TargetX', 'ExtraChannel4');

%example 3 (Fritz) (with 1 element in the lastTrial.txt)
filepath = 'D:\Monkey Project\Analysis\Data\Fritz\Behavioral';
% filename = 'FRZ_train_2023-11-20-11-34-19-580.mat';
filename = 'FRZ_2023-12-01-14-57-17-194.mat';
load(fullfile(filepath, filename), ...
    'EyeX', 'EyeY', 'TrialList', 'TargetX', 'ExtraChannel4');

%% Transpose the x- and y-positional data
EyeX = dimensionCorrector(EyeX);
EyeY = dimensionCorrector(EyeY);
TargetX = dimensionCorrector(TargetX);
ExtraChannel4 = dimensionCorrector(ExtraChannel4);
%% step 1.1: find the last trial
% in some experiment the monkey stopped working while the experiment was
% running hence the are a number of trials repeated at the end of the
% session that their repitition is only because the monkey was not
% attentive. 

% open('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey K\Functions\findRepeatedTrials.m')

% The output of the script above is a txt file called "lastTrial" placed in
% each original MAT file folder (~/Original/Beh/) with the index (indices)
% of the last trial(s).

% Those trials with multiple indices are the sessions that the monkey
% didn't work for some time and started working again after a number of
% invalid trials. The first value indicates the last valid trial of the
% first batch. The 2nd value the beginning of the 2nd batch and the 3rd
% value the end of the 2nd batch and hence so forth (example 
% J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\08.27062020\Original\~
% ~\Beh\lastTrialID.txt).

%% step 1.2: read the lastTrial.txt and find the repitions

% some time the same trial is repeated because of two reasons:1. boredom or
% inattentiveness, 2. reward. The monkey has left the rewarded trials
% incomplete sometimes so that the same trial is repeated and he get to
% receive reward again and again, I call this sequences "R-seq" (stands for
% Repetitive sequence).

%In a given R-seq with the r trials, I keep the trial 1 and investigate the
%influence of error in trial 1-1 (the trial just before) on the amplitude
%of the trial 1. Also, I keep the error of the trial r and examine its
%impact on the trial r+1 (the trial right afterwards). All those trials
%falling in between these two extremes are not included in the analysis of
%kinematics nor trial-by-trial adaptation.

%load the lastTrial
% txtFilename = 'lastTrialID.txt';
% lastT = (readmatrix(fullfile(filepath, txtFilename)))';

%mark the trials the are part of the R-seq with zeros
% notRSeq = ones(size(TrialList,1),1); %not a part of the repetitive sequence (=1)
% for m = 1: size(lastT,1)
%     if size(lastT,1) == 1
%         if lastT(1) < size(TrialList,1)
%             notRSeq(lastT(1)+1:end) = 0;
%         elseif lastT(1) == size(TrialList,1)
%             continue;
%         end
%     elseif size(lastT,1) > 1
%         notRSeq(lastT(1)+1:lastT(2)) = 0;
%         notRSeq(lastT(3)+1:end) = 0;
%     end
% end

% repititions = markRepititions(TrialList, lastT);
repititions = NaN(size(TrialList,1),1);
%% step2: smooth the raw positional data and calculate velocity
tic;
smooth_EyeX = smooth_saccade(EyeX);
smooth_EyeY = smooth_saccade(EyeY);
%compute the first derivatives of the smoothed data separately for x- and
%y- coordinates and the total first derivative
[velX, velY, vel] = pbp_derivatives(smooth_EyeX, smooth_EyeY);
%correct the unit of velocity values by multiplying by 1000 (smapling
%frequeny of scleral search coil eye tracker was set at 1000 Hz)
velX = velX * 1000;
velY = velY * 1000;
vel  = vel  * 1000;
toc;
%% step3: target shift time
valid_Trials = validTrialFinder(TrialList, repititions);

% date extraction

% files collected after 11-Sep-2020 have different design in the target
% shift for which a different 'targetShiftDetector' function is used.

year = filename(end-26:end-23);
month = filename(end-21:end-20);
day = filename(end-18:end-17);
fileDate_unformatted = [num2str(day), '/', num2str(month), '/', ...
    num2str(year)];
fileDate = datetime(datestr(datenum(fileDate_unformatted, 'dd/mm/yyyy')));
thresholdDate = datetime('11-Sep-2020');

if fileDate <= thresholdDate
    raw_targetX_shift = targetShiftDetector(TargetX, valid_Trials);
else
    raw_targetX_shift = targetShiftDetector2(TargetX, valid_Trials);
end
%% step4: find saccades and fixations
%a preliminary preceding step is to specify a trial-by-trial starting point
%to start detecting saccades from. Given our behavioral paradigm design,
%the relevant staring point is the timestamp of the primary target shift on
%the screen
InitialPointOfSearch = firstTargetShift(raw_targetX_shift);
%choose the default threshold between 100-300 deg/sec (Nystr�m & Holmqvist, 2010) 
defaultVelocityThreshold = 100;
minInterPeakIntervalThreshold = 100;
[detected_saccades_fixations, saccade_detection_vel_threshold] = ...
    saccadeFixationDetector(vel, InitialPointOfSearch, ...
    defaultVelocityThreshold, minInterPeakIntervalThreshold);
%% step 4.2: polish the saccade data
backup_detected_saccades_fixations = detected_saccades_fixations;
%remove saccades that their timestamp is too close to the primary target
%shift (< 70 ms)
minDistanceFromTargetShift = 70;
detected_saccades_fixations = removeEarlySaccades(detected_saccades_fixations, ...
    InitialPointOfSearch, minDistanceFromTargetShift);
%determine the number of saccades that are needed based on trial's
%secondary intrasaccadic step type and retain corresponding number of
%saccades for each trial
required_num_saccades = requiredNumSaccades(raw_targetX_shift);
vel_threshold = 200; % minimum velocity threshold for the primary saccade (deg/s)
detected_saccades_fixations = findRelevantNumSaccades(detected_saccades_fixations,...
    required_num_saccades, vel_threshold);
%% step 4.5: comput descriptive statistics and compare them with previous reports
% Nystr�m & Holmqvist, 2010, p. 7: For the reading data used to evaluate
% the algorithm, average values for fixation velocity were 5.44 +- 4.55�/sec 
%( Mean_n +- std_n), giving peak velocity thresholds around 33�/sec (but 
%the individual variation was large across participants). In scene 
%perception data, fixation velocity values were 5.40 +- 3.97�/sec.
%% step 5: find the onset of saccades
% set the threshold (based on mean and std of fixation points for a given 
%trial) and find the local minima between the last fixation point below the
%threshold and the threhsold
detected_saccades_fixations = findSaccadeOnset(detected_saccades_fixations, vel);
%% step 6: find the saccade offset
alpha_coeff1 = 0.5;
beta_coeff1 = 0.5;
alpha_coeff2 = 0.7;
beta_coeff2 = 0.3;
window_span = 40;
window_span2 = 100;
fixed_threshold = 100;
%finds the offset threshold for the first and second saccades
[offset, searchEnds] = offsetThresholdFinder(detected_saccades_fixations, ...
    vel, alpha_coeff1, beta_coeff1, alpha_coeff2, beta_coeff2, ...
    window_span, window_span2, fixed_threshold);
%find the offset
detected_saccades_fixations = findSaccadeOffset(vel, ...
     detected_saccades_fixations, offset, window_span, window_span2, searchEnds);
%% stepX: smooth the velocity data and calculate the acceleration
smooth_velX = smooth_saccade(velX);
smooth_velY = smooth_saccade(velY);
%compute the first derivatives of the smoothed data separately for velX and
%velY and the total first derivative (i.e. accelaration)
[accX, accY, acc] = pbp_derivatives(smooth_velX, smooth_velY);
%% find additional saccades
% they are defined as those corrective saccades taken place during stay-put
% trials due to the additional retinal error left after the primary
% saccades offset.
% folow the instructions given the script below
% The scripts add additional saccades, their onset and offset the
% corresponding columns i the detetcted_saccades_fixations variable.
% Plus, two new variales: additionalSaccades_Bool (0: no additional
% saccade; 1: additional saccade) and additionalSaccades_type (2: outward
% saccade; 3: inward).
%
% To plot the detected additional saccades use the script file named 
% "additionalSaccades_plot.m"
%
% scriptPath = 'E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\RL Project\Functions';
% scriptName = 'additionalSaccades.m';
% % open(fullfile(scriptPath, scriptName));
% run(fullfile(scriptPath, scriptName));
%% store
% clear window_span2 window_span minInterPeakIntervalThreshold ...
%     minDistanceFromTargetShift fixed_threshold defaultVelocityThreshold ...
%     beta_coeff2 beta_coeff1 alpha_coeff2 alpha_coeff1;
filepath_new = [erase(filepath, 'Original\Beh'), 'Preproc\Beh\'];
% filepath_new = "J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\1.04062020\Preproc\Beh";
year = filename(end-26:end-23);
month = filename(end-21:end-20);
day = filename(end-18:end-17);
additional = '_1';
newfilename = [day, month, year, additional, '.raw.mat'];
if ~exist(filepath_new)
    mkdir(filepath_new)
    mkdir([erase(filepath, 'Original\Beh\'), 'Preproc\Rec\'])
% copyfile('J:\Monkey Project\Analysis\Data\Emil\Analyzed\corrections.xlsx', ...
%     filepath_new);
end
save(fullfile(filepath_new, newfilename), ...
    'EyeX', 'EyeY', 'ExtraChannel4', 'smooth_EyeX', 'smooth_EyeY', ...
    'smooth_velX', 'smooth_velY', ...
    'velX', 'velY', 'vel', 'valid_Trials', 'raw_targetX_shift', ...
    'filename', 'filepath', 'detected_saccades_fixations', 'acc', ...
    'TargetX', 'TrialList', 'repititions');
%% Review the analysis and manually correct trials
% open('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey K\Functions\plot_saccades.m')
