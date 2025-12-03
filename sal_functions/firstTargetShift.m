function startingPoint = firstTargetShift(targetX_Shift)
%This function takes the output of the targetShiftDetector function as the
%input and returns a list with the same number of rows with timestamps of
%the first shift of target on the stimulus screen.
%
%   . 0: belong to invalid trials and is set for trials from the
%   targetX_Shift.targetX_ShiftTime_Primary that their value is below 5 or
%   is NaN. The description of the corresponding error codes can be found
%   in the targetShiftDetector function documentation.
%
%   . non-zero values: are the timestamp of the primary target displacement
%   in both regular and freechoice trials.

    data = [targetX_Shift(:).ShiftTime_Primary]';
    %startingPoint, sets the starting point in time where searching for peaks
    %in the velocity data should initialize in a trial-by-trial fashion
    for i = 1: length(data)
        %in freechoice trials, the startingPoint is found in
        %targetX_ShiftTime_Pre
        if data(i) == 5
            startingPoint(i,1) = [targetX_Shift(i).ShiftTime_Pre];
        %in other valid trials, the startingPoin is the corresponding element
        %in data i.e. the targetX_ShiftTime_Primary 
        elseif data(i) > 5
            startingPoint(i,1) = data(i);
        %in case of invalid trials or NaN, the startingPoint is zero
        elseif data(i) < 5
            startingPoint(i,1) = 0;
        elseif isnan(data(i))
            startingPoint(i,1) = 0;
        end
    end