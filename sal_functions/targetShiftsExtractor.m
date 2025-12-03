function targetShifts = targetShiftsExtractor(raw_targetX_shift)
%This function extracts the time of primary and secondary target shifts.
%
%Input arguments:
%   . raw_targetX_shift
%
%Returns:
%   . a struct with one field called 'time' that contains:
%       .. a list of numbers with the first row keeping the primary target
%          shift time and the second the secondary target shift time, if
%          any
%       .. NaN, when no target shift time data avaialble. For possible
%          reasons check out the function targetShiftDetector.
%
%Dependencies:
%   .  firstTargetShift <function>
    primary_targetShift = firstTargetShift(raw_targetX_shift);
    target_shiftType = [raw_targetX_shift(:).target_ShiftType]';            %target shift type 
    secondary_targetShift = [raw_targetX_shift(:).ShiftTime_Secondary]';
    for i = 1:size(raw_targetX_shift,2)
        if (target_shiftType(i) == 2) || (target_shiftType(i) == 3)     %ISS
            targetShifts(i).time(1,1) = primary_targetShift(i);
            targetShifts(i).time(2,1) = secondary_targetShift(i);
        elseif (target_shiftType(i) == 1) || (target_shiftType(i) == 5) %stay-put or freechoice
            targetShifts(i).time = primary_targetShift(i);
        elseif isnan(target_shiftType(i))                               %NaN
            targetShifts(i).time = NaN;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dependent functions    
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