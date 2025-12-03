function targetX_Shift = targetShiftDetector(TargetX, valid_Trials)
%This function specifies the time points of target shifts along the X-axis, 
%primary and secondary, as well as the type of secondary target shift, 
%inward, outward or control. 
%It takes TargetX and valid_Trials as input arguments and returns a struct 
%with the time point values and trial types.
%
% Argument: 
%   . TargetX
%   . valid_Trials
%
% Output: a four-column struct:
%   . column 1: targetX_ShitTime_Pre: target trajectory shifts toward the
%   opposite direction of the primary target shift a few hundred msec
%   before the primary shift. This variable specifies the time of such
%   shifts.
%   ** Note that the taget shift time for *freechoice* trials are also
%   stored in this column.
%
%   . column 2: targetX_ShitTime_Primary: the next shift of target after
%   the pre shift is the actual priamry target shift. Time points of these
%   shifts are captured in the 2nd column.
%
%   . column 3: targetX_ShitTime_Secondary: the time of the next target
%   shift which is the actual secondary target shift. 
%
%   . Values in the columns 1 through 3:
%       . NaN: primary fixation failure or no eye trace.
%       . 1: A free choice trial without any target shift from the center.
%       . 2: A none free choice trial without any target shift from the
%       center.
%       . 3: Absence of any primay target shift. There was a pre target
%       shift though. 
%       . 4: Presence of a primary target shift without an accompanying
%       secondary target shift. This value specifies control trials or
%       *stay-put* trials.
%       . 5: in the 2nd and 3rd columns together with a timepoint value in
%       the first column is the indicator of free choice trials.
%
%   . column 4: Specifies the type of target shift based on the values of
%   the secondary target shift. Value 4 means control trials and value 5 means
%   free choice trials. Greater-than-5 values belong to inward or outeard
%   shift trials.
%
%   . Values in the columns 4:
%       . NaN: absence of target shift due to most probably primary 
%       fixation failure or no eye trace.
%       . 1: stay-put trials.
%       . 2: trials with a secondary *outward* shift of trials.
%       . 3: trials with a secondary *inward* shift of trials.
%       . 5: free choice trials.
    %% Coulmns 1 though 3: Finding the time points of target shifts 
    TargetX = dimensionCorrector(TargetX);
    ShiftTime_Pre = zeros(length(TargetX(:,1)),1);
    ShiftTime_Primary=zeros(length(TargetX(:,1)),1); 
    ShiftTime_Secondary=zeros(length(TargetX(:,1)),1); 
     for m = 1:length(TargetX(:,1))
         if (valid_Trials(m) == 1) || (valid_Trials(m) == 2) %If primary fixation failure or no eyeTrace, Target shift is nonexistant or NaN
             ShiftTime_Pre(m) = NaN;
             ShiftTime_Primary(m)=NaN; %
             ShiftTime_Secondary(m)=NaN; %
         elseif valid_Trials(m) == 5 %freechoice trials
             % set the endpoint of search. This is because of the variability 
             %in the length of TargetX signal across trials, NaN was added to
             %equalize the lengths. The current algorithm specifies the
             %timepoint where the signal value changes regardless of the value
             %it takes after the change which can be NaN.
             if isnan(TargetX(m,end)) %if the last value in a line is NaN means 
                                      %that NaN where added to the row. We want 
                                      %to find the index of the last nonNaN 
                                      %value to set the search boundry.
                 search_end = find(isnan(TargetX(m,:)),1) - 1;
             else
                 search_end = length(TargetX); %If there is no NaN in the row. 
                                               %Then the last value of the row 
                                               %is the search endpoint.
             end
             try
                ShiftTime_Pre(m) = NaN;
                ShiftTime_Primary(m)= find(TargetX(m,1:search_end)~=TargetX(m,1),1);
%                 ShiftTime_Primary(m)=5;     %Freechoice
                ShiftTime_Secondary(m)=5;   %Freechoice
             catch
%                 ShiftTime_Pre(m)=1;         %A free choice trial with no target displacement
                ShiftTime_Primary(m)=1;     %A free choice trial with no target displacement
                ShiftTime_Secondary(m)=1;   %A free choice trial with no target displacement
             end
         else %If the trials is not suffering from primary fixation failure or 
              %no eyeTrace or is not a freeChoice trial set the search endpoint
             if isnan(TargetX(m,end))
                 search_end = find(isnan(TargetX(m,:)),1)-1;
             else
                 search_end = length(TargetX);
             end
             %find the Pre-primary jump. Due to the internal construct of the
             %paradigm, in valid trials, there is an invisible target shift to 
             %the side opposite to the primary visible location where it shifts 
             %on the screen. Here, we find the timepoint of this pre-primary 
             %shift that is only detectable in the TargetX/Y signal.
%              try
%                 ShiftTime_Pre(m)= find(TargetX(m,1:search_end)~=TargetX(m,1),1);
%              catch
%                 ShiftTime_Pre(m)=2;         % A none free choice trial without any target shift from the center
%                 ShiftTime_Primary(m)=2;     % A none free choice trial without any target shift from the center
%                 ShiftTime_Secondary(m)=2;   % A none free choice trial without any target shift from the center
%              end
%              if ShiftTime_Pre(m)~=2 %if the trial is not free choice and there is a Pre shift, there might be a primary too.
                 try
%                     ShiftTime_Primary(m)= ShiftTime_Pre(m) + ...
%                         find(TargetX(m,ShiftTime_Pre(m):search_end)~= ...
%                         TargetX(m,ShiftTime_Pre(m)),1) - 1;
                    ShiftTime_Pre(m) = NaN;
                    ShiftTime_Primary(m)= find(TargetX(m,1:search_end)~=TargetX(m,1),1);
                    %The search starts the timepoint of the Pre-primary shift
                    %to the search end. Hence, the Pre-primary shift timepoint
                    %minus 1 should be added to correct the timepoint reported
                    %by the find function.
                 catch
                    ShiftTime_Primary(m)=3;     % abscence of a primary shift
                    ShiftTime_Secondary(m)=3;   % abscence of a primary shift
                 end
                 if ShiftTime_Primary(m)~=3
                     try
                        ShiftTime_Secondary(m)= ShiftTime_Primary(m) + ...
                            find(TargetX(m,ShiftTime_Primary(m):search_end)~= ...
                            TargetX(m,ShiftTime_Primary(m)),1) - 1;
                        %The search for timepoint of shifts continues. This time starts 
                        %from the primary shift timepoint to find the secondary shift 
                        %timepoint.
                     catch
                        ShiftTime_Secondary(m)=4; %abscence of a secondary shift
                     end
                 end
%              end
         end
     end
     clear m;
    %% Column4: specify the type of target shift(s)
    target_ShiftType = NaN(length(TargetX(:,1)),1);
    for n = 1:length(TargetX(:,1))
        if ShiftTime_Secondary(n) == 5 %if WasFreeChoice (col 35) = 1, it was a free choice trial
            target_ShiftType(n) = 5; %free choice
        elseif ShiftTime_Secondary(n) == 4  % the value 4 indicates control trials
            target_ShiftType(n) = 1; %stay-put
        elseif ShiftTime_Secondary(n) > 5 %the secondary target shift's values larger than 5 belongs to inward or outward shift trials
            if abs(TargetX(n,ShiftTime_Secondary(n))) > abs(TargetX(n,ShiftTime_Primary(n))) % if abs(targetX) after 2nd jump > abs(targetX) after the first jump -> outward shift
                target_ShiftType(n) = 2; %outward
            elseif abs(TargetX(n,ShiftTime_Secondary(n))) < abs(TargetX(n,ShiftTime_Primary(n))) % if abs(targetX) after 2nd jump < abs(targetX) after the first jump -> inward shift
                target_ShiftType(n) = 3; %inward
            end
        end
    end
    %% Output 
    targetX_Shift = struct('ShiftTime_Pre', {0,0}, ...
        'ShiftTime_Primary', {0,0}, ...
        'ShiftTime_Secondary', {0,0}, ...
        'target_ShiftType', {0,0});
    for i= 1:length(TargetX(:,1))
        targetX_Shift(i).ShiftTime_Pre = ShiftTime_Pre(i);
        targetX_Shift(i).ShiftTime_Primary = ShiftTime_Primary(i);
        targetX_Shift(i).ShiftTime_Secondary = ShiftTime_Secondary(i);
        targetX_Shift(i).target_ShiftType = target_ShiftType(i);
    end
%     assignin('base', 'targetX_Shift', targetX_Shift);