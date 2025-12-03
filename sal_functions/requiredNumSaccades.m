function required_num_saccades = requiredNumSaccades(targetX_Shift)
    for i = 1:size(targetX_Shift ,2)
        temp_targetShift = targetX_Shift(i).target_ShiftType;
        if ~isnan(temp_targetShift)
            if temp_targetShift == 2 || temp_targetShift == 3
                required_num_saccades(i,1) = 2;
            elseif temp_targetShift == 1 || temp_targetShift == 5
                required_num_saccades(i,1) = 1;
            end
        else
            required_num_saccades(i,1) = NaN;
        end
    end