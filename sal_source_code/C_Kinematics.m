%% Saccade Adaptation with cue <<<< Monkey >>>>
%Position: Left (135 deg) (X= -7.07; Y= 7.07)              Position: Right (45 deg) (X= 7.07; Y= 7.07)         
%           |IN (-30%)  | - |OUT (-30%) |                      |IN (-30%)  | - |OUT (-30%) | 
%LOW reward |   6       | 8 |   10      |           LOW reward |   0       | 2 |    4      |    
%HIGH reward|   7       | 9 |   11      |           HIGH reward|   1       | 3 |    5      | 
%
% High reward codes:    1,3,5,7,9,11	<odd>
% Low reward codes:     0,2,4,6,8,10	<even>
%
% Right-side codes:     0,1,2,3,4,5     <=5
% Left-side codes:      6,7,8,9,10,11   >5
%
% Stay-put codes:       2,3,8,9
% Inward ISS codes:     0,1,6,7
% outward ISS codes:    4,5,10,11
%% step1: import and prepare data
% rmpath('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\RL Project\Functions\')


% addpath('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\RL Project\Functions');
% addpath('E:\MEGAsync\MEGAsync\HIH\M Project\RL Project\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Functions');
addpath('G:\Other computers\My Computer (1)\HIH\M Project\RL Projects\RL1\Analysis\Analysis Scripts\Behavioral\Preprocessing\Eye movement detection\Saccade detection\Monkey F\Functions');
% 
% load main file
% 
% [filename,filepath] = uigetfile('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed', ...
%     'enter the main file');
% load(fullfile(filepath, filename), 'EyeX', 'EyeY', 'ExtraChannel4', ...
%     'smooth_EyeX', 'smooth_EyeY', ...
%     'velX', 'velY', 'vel', 'valid_Trials', 'raw_targetX_shift', ...
%     'detected_saccades_fixations', 'acc', ...
%     'TargetX', 'TrialList', 'additionalSaccades_Bool', 'additionalSaccades_type');
% filenamemain = filename;
% filepathmain = filepath;
% 
% % load the file with manually corrected saccade characteristics
% 
% [filename,filepath] = uigetfile(filepathmain, ...
%     'enter the correction file');
% load(fullfile(filepath, filename), 'correction_detected_saccades_fixations');
%% load example session data
%example 2 (with 1 element in the lastTrial.txt)
filepath = 'D:\Monkey Project\Analysis\Data\Fritz\BehavioralPreproc\Beh';
filename = '01122023_1.raw.mat';
load(fullfile(filepath, filename), 'EyeX', 'EyeY', 'ExtraChannel4', ...
    'smooth_EyeX', 'smooth_EyeY', 'smooth_velX', 'smooth_velY', ...
    'velX', 'velY', 'vel', 'valid_Trials', 'raw_targetX_shift', ...
    'detected_saccades_fixations', 'acc', ...
    'TargetX', 'TrialList', 'repititions');
filenamemain = filename;
filepathmain = filepath;

% load example session data 2 (Fritz)
%example 2 (with 1 element in the lastTrial.txt)
% filepath = 'J:\Monkey Project\Analysis\Data\Fritz\Training data\Preproc\Beh\';
% filename = '20112023_1.raw.mat';
% load(fullfile(filepath, filename), 'EyeX', 'EyeY', 'ExtraChannel4', ...
%     'smooth_EyeX', 'smooth_EyeY', ...
%     'velX', 'velY', 'vel', 'valid_Trials', 'raw_targetX_shift', ...
%     'detected_saccades_fixations', 'acc', ...
%     'TargetX', 'TrialList', 'additionalSaccades_Bool', ...
%     'additionalSaccades_type', 'repititions');
% filenamemain = filename;
% filepathmain = filepath;
%% add the corrections to the main file
% list_new = [correction_detected_saccades_fixations.trialno]';
% for listi = 1:size(list_new,1)
%     trialno = list_new(listi);
%     detected_saccades_fixations(trialno).saccades = ...
%         correction_detected_saccades_fixations(listi).saccades;
%     detected_saccades_fixations(trialno).saccade_onset = ...
%         correction_detected_saccades_fixations(listi).saccade_onset;
%     detected_saccades_fixations(trialno).saccade_offset = ...
%         correction_detected_saccades_fixations(listi).saccade_offset;
%     detected_saccades_fixations(trialno).fixations = ...
%         correction_detected_saccades_fixations(listi).fixations;
%     detected_saccades_fixations(trialno).allsaccades = ...
%         correction_detected_saccades_fixations(listi).allsaccades;
% end
%% step2: smooth the raw positional data and calculate velocity and acceleration
% smooth_EyeX = smooth_saccade(EyeX);
% smooth_EyeY = smooth_saccade(EyeY);
%compute the first derivatives of the smoothed data seperately for x- and
%y- coordinates and the total first derivative
% [velX, velY, vel] = pbp_derivatives(smooth_EyeX, smooth_EyeY);
%correct the unit of velocity values by multiplying by 1000 (smapling
%frequeny of scleral search coil eye tracker was set at 1000 Hz)
% velX = velX * 1000;
% velY = velY * 1000;
% vel  = vel  * 1000;
%smooth vel data to calculate a less noisy second derivative
% tic;
% smooth_velX = smooth_saccade(velX);
% smooth_velY = smooth_saccade(velY);
% toc;
%compute the first derivatives of the smoothed data seperately for velX and
%velY and the total first derivative (i.e. accelaration)
% [accX, accY, acc] = pbp_derivatives(smooth_velX, smooth_velY);
%% step3: target shift time
% valid_Trials = validTrialFinder(TrialList);
% raw_targetX_shift = targetShiftDetector(TargetX, valid_Trials);
targetShifts = targetShiftsExtractor(raw_targetX_shift);
[targetShift_primary, targetShift_secondary] = extract_1st_2nd_shiftTimes(targetShifts);
%% Clear up the worksapce
% clear accY accX velX velY;
%% label saccades as primary and secondary
[primary, corrective] = saccadeNumLabeller(raw_targetX_shift, ...
    detected_saccades_fixations, smooth_EyeX, smooth_EyeY, ...
    targetShift_primary, targetShift_secondary);
%% saccade kinematics
kinematics = saccadeKinematicsCalculator2(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, targetShift_primary, ...
    targetShift_secondary, primary, corrective);
%% correct saccade kinematics
% the correction is needed because the trials with repititions need to be
% discarde to keep the number of the trials per condition comparable in the
% pool.
% kinematics = rmRepititions(kinematics, repititions);
%% reward
% window_span = 200;
% reward = rewardDetector(detected_saccades_fixations, ...
%     ExtraChannel4, window_span, TrialList); 
% clear window_span;
rew = TrialList(:,41);
rew(rew > 0) = 1;
rew(rew < 0) = NaN;
reward.delivered = rew;
% rew = [reward(:).delivered]';
% [idx_reward, idx_unreward] = rewardindex(rew);
%%
fundamentals.EyeX = EyeX;
fundamentals.EyeY = EyeY;
fundamentals.smooth_EyeX = smooth_EyeX;
fundamentals.smooth_EyeY = smooth_EyeY;
fundamentals.smooth_velX = smooth_velX;
fundamentals.smooth_velY = smooth_velY;
fundamentals.vel = vel;
fundamentals.acc = acc;
fundamentals.TargetX = TargetX;
fundamentals.ExtraChannel4 = ExtraChannel4;
% clear EyeX EyeY smooth_EyeX smooth_EyeY smooth_velX smooth_velY vel acc ...
%     TargetX ExtraChannel4;
%% Target shift and saccade direction are congruent or not?
% if the direction of both is congruent, i.e., the product of the Eye
% postion at saccade offset (eyeOffsetPos) and target position after
% primary shift (targetPos) is a positive number, then cong(i) = 1.
% Otherwise, i.e., the product of the Eye postion at saccade offset 
% (eyeOffsetPos) and target position after primary shift (targetPos) is a 
% negative number, then cong(i) = 0. For those trials which either 
% eyeOffsetPos or targetPos is NaN, ccong(i) = NaN.
cong = NaN(size(detected_saccades_fixations,2), 1);
for i = 1:size(detected_saccades_fixations,2)
    if ~isnan(detected_saccades_fixations(i).saccade_offset(1)) && ...
            ~isnan(targetShifts(i).time(1))
        offsetTime = detected_saccades_fixations(i).saccade_offset(1,2);     %offset(s)
        eyeOffsetPos = EyeX(i, offsetTime);
        targetPos = TargetX(i, targetShifts(i).time(1));
        if (eyeOffsetPos*targetPos) > 0
            cong(i) = 1;
        elseif (eyeOffsetPos*targetPos) < 0
            cong(i) = 0;
        end
    end
end
            
%% valid_trials: add error code 6 indicating trials with NaN values as the detected_saccade_fixation.saccades
for i = 1:size(detected_saccades_fixations,2)
    if isnan(detected_saccades_fixations(i).saccades(1,1))
        valid_Trials(i,1) = str2double([num2str(valid_Trials(i,1)), ...
            num2str(6)]);
    end
end
incongIdx = find(cong == 0);
if ~isempty(incongIdx)
    for j = 1:size(incongIdx,1)
        idx_temp = incongIdx(j);
        valid_Trials(idx_temp,1) = str2double([num2str(valid_Trials(idx_temp,1)), ...
            num2str(11)]);
    end
end
%% manual polish
% -> run manualPolish_kinematicsDistribution.m
% corrections_trials = [corrections(:).overall];
% for i = 1:size(corrections_trials,1)
%     detected_saccades_fixations(corrections_trials(i,3)).saccade_offset(1,:) = ...
%         corrections_trials(i,1:2);
% end
% %% correction to the corrections
% corrections.peakVelocity_pri = [corrections(:).peakVeloity_pri];
% corrections = rmfield(corrections, 'peakVeloity_pri');
%% valid_trials: add error code 7,8,9,10 indicating trials with out of bound
%amplitude_pri, duration_pri, peakVelocity_pri and reactionTime
% valid_Trials = validTrial_kinematicsDistribution(valid_Trials, ...
%     corrections);
%% IDs
%assigns: direction, ISS type, reward, and block
IDs = IDassigner(reward, targetShifts, raw_targetX_shift, ...
    detected_saccades_fixations, fundamentals, TrialList,...
    primary, ...
    corrective, repititions);
%% Visual error calculation
%in case, session array was created before the calculation of visual error,
%the following few lines need to be run
% smooth_EyeX = [session.fundamentals.smooth_EyeX(:,:)];
% smooth_EyeY = [session.fundamentals.smooth_EyeY(:,:)];
% detected_saccades_fixations = [session.detected_saccades_fixations(:,:)];
trialtype = [IDs.trialType(:,:)];
% additionalSaccades_type = [IDs.additionalSaccades_type(:,:)];
% meaure
% in case it is not working,  just run the function from inside
visualError = visualErrorCalculator(smooth_EyeX, smooth_EyeY, ...
    detected_saccades_fixations, trialtype, ...
    primary, corrective);
%% remove visual error informatin for repititive trials with value 2
% VE = visualError;
% fnames = fieldnames(VE);
% for triali = 1:size(repititions,1)
%     if (repititions(triali) == 2) || (repititions(triali) == 1)
%         for vari = 1:size(fnames,1)-1
%             VE(triali).(fnames{vari}) = NaN;
%         end
%     end
% end
% visualError = VE;
%% Percentage correct for free choice trials
PCD = Percentage_correct_freeChoice(IDs, reward, TrialList);
%% Organize 
session = organizeSessionVariables2(valid_Trials, ...
    detected_saccades_fixations, fundamentals, ...
    IDs, kinematics, visualError, raw_targetX_shift, reward, TrialList, PCD);

% session = organizeSessionVariables(valid_Trials, ...
%     correction_detected_saccades_fixations, ...
%     detected_saccades_fixations, fundamentals, ...
%     IDs, kinematics, visualError, raw_targetX_shift, reward, TrialList, PCD);
% clearvars -except session filepathmain filenamemain;
%% store
% year = filenamemain(end-13:end-10);
% month = filenamemain(end-15:end-14);
% day = filenamemain(end-16:end-16);
% additional = '_1';
% newfilename = [day, month, year, '.final.mat'];
% if contains(filenamemain, '_1')
%     filename_new = [erase(filenamemain, '_1.raw.mat'), '.final.mat'];
% elseif contains(filenamemain, '_2')
%     filename_new = [erase(filenamemain, '_2.raw.mat'), '_2.final.mat'];
% end
filename_new = [erase(filename, '.raw.mat'), '.final.mat'];
% filepath_new = [erase(filepathmain, 'Original\Beh\'), 'Preproc\Beh\'];
save(fullfile(filepath, filename_new), 'session');
%*****************************************************************************************************************************************************
%*****************************************************************************************************************************************************
%*****************************************************************************************************************************************************
%*****************************************************************************************************************************************************
%% pool data across sessoions
% choose the directory to search for the data files
directory_main = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed';
fileInfo = dir([directory_main, '\**\*.final.mat']);
fileInfo(32:end,:) = [];  
% reorder the files according to the collection date
name = fileInfo;
nameOfFields = fieldnames(fileInfo);
name = rmfield(name, nameOfFields(2:end));
name = struct2cell(name)';
name = horzcat(name, num2cell(1:31)');
% name = vertcat(name, name(1:11,:));
% name(1:11, :) = [];
% name = vertcat(name(1:13,:), name(38,:), name(14:end, :));
% name(39, :) = [];
% name = vertcat(name(1:15,:), name(39,:), name(16:end, :));
% name(40, :) = [];
% extract the new order
newOrder = cell2mat(name(:,2));


df = [];
for j = 1:size(fileInfo, 1)
    disp(j);
    i = newOrder(j);
    clearvars -except df i j fileInfo newOrder name;
    load(fullfile(fileInfo(i).folder,fileInfo(i).name))
    session_no = repmat(j, size(session.TrialList,1),1);
    sessionID = repmat(str2num(fileInfo(i).name(1:8)), size(session.TrialList,1),1);
    if contains( fileInfo(i).name, '_2')
        additionalID = repmat(2, size(session.TrialList,1),1);
    else
        additionalID = repmat(1, size(session.TrialList,1),1);
    end
    [trialID, block, validTrial, direction, reward, ISS, freeChoice,...
    addSac, addSacType, RT_p, amplitude_p, PV_p, duration_p, ...
    amplitudeOffset, amplitudeOffset50, ISI, TSI,...
    amplitude_c, PV_c, duration_c, errorX1, errorSize1, errorX2, ...
    errorSize2, ierrorX, ierrorSize, errorX1_50, errorX1_50Avg, ...
    ierrorX_50, ierrorX_50Avg, repititive] ...
    = sessionData(session);
    df_temp = horzcat(session_no, ...
                sessionID, ...
                additionalID, ...
                trialID, ...
                block, ...
                validTrial, ...
                repititive, ...
                direction, ...
                reward, ...
                ISS,...
                freeChoice,...
                addSac, ...
                addSacType, ...
                RT_p, ...
                amplitude_p, ...
                PV_p, ...
                duration_p, ...
                amplitudeOffset, ...
                amplitudeOffset50, ...
                ISI, ...
                TSI, ...
                amplitude_c, ...
                PV_c, ...
                duration_c, ...
                errorX1, ...
                errorSize1, ...
                errorX2, ...
                errorSize2, ...
                ierrorX, ...
                ierrorSize, ...
                errorX1_50, ...
                errorX1_50Avg, ...
                ierrorX_50, ...
                ierrorX_50Avg);
    df = vertcat(df, df_temp);
end
% store
storingPath = uigetdir('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\1.04062020\Preproc\Beh');
storingName = 'df.mat';
save(fullfile(storingPath, storingName), 'df');
% store individual sessions
destination = 'J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data\10032021_14012022\Individual sessions\';
for i = 1:size(fileInfo, 1)
    disp(fileInfo(i).name);
    disp(i);
    copyfile(fullfile(fileInfo(i).folder, fileInfo(i).name), destination)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% store as .CSV file format
[filename, filepath] = uigetfile('J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data');
load(fullfile(filepath, filename));
df = array2table(df);
varNames = {'session_no'; 'sessionID'; 'additionalID'; 'trialID'; 'block'; ...
            'validTrial'; 'repititive'; 'direction'; 'reward'; 'ISS'; 'freeChoice'; ...
            'addSac'; 'addSacType'; 'RT_p'; 'amplitude_p'; 'PV_p'; ...
            'duration_p'; 'amplitudeOffset'; 'amplitudeOffset50'; ...
            'ISI'; 'TSI'; 'amplitude_c'; 'PV_c'; 'duration_c'; ...
            'errorX1'; 'errorSize1'; 'errorX2'; 'errorSize2'; 'ierrorX'; ...
            'ierrorSize'; 'errorX1_50'; 'errorX1_50Avg'; 'ierrorX_50'; ...
            'ierrorX_50Avg'};
df.Properties.VariableNames = varNames;
% write the table into a CSV file
filename_new = 'df.csv';
writetable(df, fullfile(filepath, filename_new), ...
    'WriteVariableNames', true);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% the smaller sample of 13 sessions
% % directory_main = 'J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data\140421_070521\individual sessions\';
% % fileInfo = dir([directory_main, '*.final.mat']);
% % fileInfo = vertcat(fileInfo, fileInfo(1:2,:));
% % fileInfo(1:2,:) = [];
% % newOrder = [1:13];
% 
% % The second pool of the same 13 session which were analyzed using the new
% % script:
% directory_main = 'J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data\140421_070521\individual sessions\NewScript\';
% fileInfo = dir([directory_main, '*.final.mat']);
% fileInfo = vertcat(fileInfo, fileInfo(1:2,:));
% fileInfo(1:2,:) = [];
% newOrder = [1:13];
% 
% df = [];
% for j = 1:size(fileInfo, 1)
%     disp(j);
%     i = newOrder(j);
%     clearvars -except df i j fileInfo newOrder name;
%     load(fullfile(fileInfo(i).folder,fileInfo(i).name))
%     session_no = repmat(j, size(session.TrialList,1),1);
%     sessionID = repmat(str2num(fileInfo(i).name(1:8)), size(session.TrialList,1),1);
%     if contains( fileInfo(i).name, '_2')
%         additionalID = repmat(2, size(session.TrialList,1),1);
%     else
%         additionalID = repmat(1, size(session.TrialList,1),1);
%     end
%     [trialID, block, validTrial, direction, reward, ISS, freeChoice,...
%     addSac, addSacType, RT_p, amplitude_p, PV_p, duration_p, ...
%     ISI, TSI,...
%     amplitude_c, PV_c, duration_c, errorX1, errorSize1, errorX2, ...
%     errorSize2, ierrorX, ierrorSize, errorX1_50, errorX1_50Avg, ...
%     ierrorX_50, ierrorX_50Avg] ...
%     = sessionData2(session);
%     df_temp = horzcat(session_no, ...
%                 sessionID, ...
%                 additionalID, ...
%                 trialID, ...
%                 block, ...
%                 validTrial, ...
%                 direction, ...
%                 reward, ...
%                 ISS,...
%                 freeChoice,...
%                 addSac, ...
%                 addSacType, ...
%                 RT_p, ...
%                 amplitude_p, ...
%                 PV_p, ...
%                 duration_p, ...
%                 ISI, ...
%                 TSI, ...
%                 amplitude_c, ...
%                 PV_c, ...
%                 duration_c, ...
%                 errorX1, ...
%                 errorSize1, ...
%                 errorX2, ...
%                 errorSize2, ...
%                 ierrorX, ...
%                 ierrorSize, ...
%                 errorX1_50, ...
%                 errorX1_50Avg, ...
%                 ierrorX_50, ...
%                 ierrorX_50Avg);
%     df = vertcat(df, df_temp);
% end
% % store
% % storingPath = uigetdir('J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data');
% storingName = 'df_newBatch_long.mat';
% save(fullfile(directory_main, storingName), 'df');
% % store individual sessions
% % destination = 'J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data\10032021_14012022\Individual sessions\';
% % for i = 1:size(fileInfo, 1)
% %     disp(fileInfo(i).name);
% %     disp(i);
% %     copyfile(fullfile(fileInfo(i).folder, fileInfo(i).name), destination)
% % end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % store as .CSV file format
% [filename, filepath] = uigetfile('J:\Monkey Project\Analysis\Data\Emil\Analyzed\Pooled data');
% load(fullfile(filepath, filename));
% df = array2table(df);
% varNames = {'session_no'; 'sessionID'; 'additionalID'; 'trialID'; 'block'; ...
%             'validTrial'; 'direction'; 'reward'; 'ISS'; 'freeChoice'; ...
%             'addSac'; 'addSacType'; 'RT_p'; 'amplitude_p'; 'PV_p'; ...
%             'duration_p'; ...
%             'ISI'; 'TSI'; 'amplitude_c'; 'PV_c'; 'duration_c'; ...
%             'errorX1'; 'errorSize1'; 'errorX2'; 'errorSize2'; 'ierrorX'; ...
%             'ierrorSize'; 'errorX1_50'; 'errorX1_50Avg'; 'ierrorX_50'; ...
%             'ierrorX_50Avg'};
% df.Properties.VariableNames = varNames;
% % write the table into a CSV file
% filename_new = 'df_newBatch_long.csv';
% writetable(df, fullfile(directory_main, filename_new), ...
%     'WriteVariableNames', true);
