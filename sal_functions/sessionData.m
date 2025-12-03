function [trialID, block, validTrial, direction, reward, ISS, freeChoice,...
    RT_p, amplitude_p, PV_p, duration_p, ...
    amplitudeOffset, amplitudeOffset50, ISI, TSI,...
    amplitude_c, PV_c, duration_c, errorX1, errorSize1, errorX2, ...
    errorSize2, ierrorX, ierrorSize, errorX1_50, errorX1_50Avg, ...
    ierrorX_50, ierrorX_50Avg, repititive] ...
    = sessionData(session)
% This function takes session as the input argument and extract the
% variables of interest needed for kinematic analysis.
%%
% fundamental variabels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    block = [session.IDs.block];
    
    %direction
    direction = [session.IDs.direction]; 
    direction(direction(:,1) == -1,1) = 0; %1:right
    % idx_right = find(direction(:,1) ==1);
    % idx_left = find(direction(:,1) ==0);
    
    %reward
%     reward = [session.IDs.reward];
    reward = session.TrialList(:,41);
    reward(reward ~= 0,1) = 1;
    idx_reward = find(reward(:,1) ==1);
    idx_control = find(reward(:,1) ==0);
    
    %ISS
    ISS = [session.IDs.trialType];
    idx_inISS = find(ISS(:,1) == 3); %inward intra-saccadic step
    idx_outISS = find(ISS(:,1) == 2); %outward intra-saccadic step
    idx_noISS = find(ISS(:,1) == 1); %No intra-saccadic step
    
    % Specify valid trials based on the presence of ISS and reward/control
    idx_reward_control = sort(vertcat(idx_reward, idx_control), 'ascend');
    idx_validISS = sort(vertcat(idx_inISS, idx_outISS, idx_noISS), 'ascend');
    idx_valid = intersect(idx_reward_control, idx_validISS);
    trialID = [1:length(direction)]';
    validTrial = trialID;
    validTrial(1,1) = 00;
    validTrial(idx_valid) = 1;
    validTrial(validTrial ~= 1) = 0;
    
    sessionValidTrials = session.valid_Trials;
    validTrial(sessionValidTrials ~= 0) = 0;
    % Repititve trials
    repititive = [session.IDs.repititions];
    
    % Additional saacade type and presece
    % Additional saccades are defined as those stayput trials that contain
    % a corrective saccade
    % addSac = [session.IDs.additionalSaccades_Bool];
    % addSacType = [session.IDs.additionalSaccades_type];
        
    % freechoice
    freeChoice = zeros(size(ISS));
    freeChoice(ISS == 5) = 1; 
    
%% Kinematics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % primary saccade
    RT_p = [session.kinematics.reactionTime]';
    amplitude_p = [session.kinematics.amplitude_pri]';
    PV_p = [session.kinematics.peakVelocity_pri]';
    duration_p = [session.kinematics.duration_pri]';
    amplitudeOffset = [session.kinematics.amplitudeoffset]';
    amplitudeOffset50 = [session.kinematics.amplitudeoffset50]';
    
    % corrective saccade
    ISI = [session.kinematics.intersaccadeinterval]'; %inter-saccadic interval
    TSI = [session.kinematics.interval_2ndTarget_saccade]'; %target-saccade interval (2nd target and corrective saccade)
    amplitude_c = [session.kinematics.amplitude_cor]';
    PV_c = [session.kinematics.peakVelocity_cor]';
    duration_c = [session.kinematics.duration_cor]';
    
%% errors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    errorX1 = [session.visualError.error_X1]';
    errorSize1 = [session.visualError.error_size1]';
    errorX2 = [session.visualError.error_X2]';
    errorSize2 = [session.visualError.error_size2]';
    ierrorX = [session.visualError.ierrorX]';
    ierrorSize = [session.visualError.ierror]';
    errorX1_50 = [session.visualError.error_X150]';
    errorX1_50Avg = [session.visualError.error_X1avg]';
    ierrorX_50 = [session.visualError.ierrorX50]';
    ierrorX_50Avg = [session.visualError.ierrorXavg]';
    % clear idx_validISS idx_right idx_reward_control idx_outISS idx_reward ...
    %     idx_noISS idx_left idx_inISS idx_control;