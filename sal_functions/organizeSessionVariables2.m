function session = organizeSessionVariables2(valid_Trials, ...
    detected_saccades_fixations, fundamentals, ...
    IDs, kinematics,  visualError, raw_targetX_shift, reward, TrialList, PCD)
% The difference between
%     session.corrections = corrections; 
    session.detected_saccades_fixations = detected_saccades_fixations;
    session.fundamentals = fundamentals;
    session.IDs = IDs;
    session.kinematics = kinematics;
    session.raw_targetX_shift = raw_targetX_shift; 
    session.reward = reward;
    session.TrialList = TrialList; 
    session.valid_Trials = valid_Trials;
    session.visualError = visualError;
    session.PercentCorrectFreeChoice = PCD;
    clear valid_Trials corrections detected_saccades_fixations fundamentals ...
        IDs kinematics raw_targetX_shift reward TrialList;