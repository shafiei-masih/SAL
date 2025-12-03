function [targetShift_primary, targetShift_secondary] = extract_1st_2nd_shiftTimes(targetShifts)
    for i = 1:size(targetShifts,2)
        if ~isnan(targetShifts(i).time(1,1))
            targetShift_primary(i,1) = targetShifts(i).time(1,1);
            if size(targetShifts(i).time,1) > 1
                targetShift_secondary(i,1) = targetShifts(i).time(2,1);
            else
                targetShift_secondary(i,1) = NaN;
            end
        elseif isnan(targetShifts(i).time(1,1))
            targetShift_primary(i,1) = NaN;
            targetShift_secondary(i,1) = NaN;
        end
    end
            
            