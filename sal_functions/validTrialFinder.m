function valid_Trials = validTrialFinder(TrialList, repititions)
    %This function takes the TrialList as an argument. Based on previously
    %defined values for varibales in the TrialList, this function returns a
    %variable dubbed "valid_Trials" which contains zeros for valid trials
    %(i.e. indices) and non-zero values or codes for invalid ones. These
    %codes can be used to identify the reason(s) why a particluar trial is 
    % not invalid.
    %The reasons associated to the codes are summarized in a listInvalidvalues.txt
    % that is available in ~/Source\ code/ directory.
    
    %exclusion criteria is a struct that contains the error code or id,
    %error explanation or reason, the corresponding column number in the
    %the TrialList and the decisive_value that determines the validity of
    %the trials.
    %**Note that among the first four lines of input in the exclusion
    %critera, the 2nd line (No Eye Trace) is the one where values zero is
    %equivalent to invalid while for the rest value zero means a valid
    %trial.
    exclusion_criteria = struct('id', ...
        {'1','2','3','4','5'},...
        'Reason',...
        {'Primary fixation failure',...
        'No eye trace',...
        'secondary fixation failure',...
        'Too late to cactch the target',...
        'Was Free choice'},...
        'Column_number_inTrialList',...
        {'18', '2', '45', '47', '35'},...
        'decisive_value', ...
        {'0', '0', '0', '0', '0'});
    valid_Trials = zeros(length(TrialList),1);
    %This loops over the lines of the exclusion_criteria. For each line,
    %takes the corresponding column from the TrialList and based on the
    %decisive_value, specifies the invalid trials and assign an error id to 
    % to the trial. On each loop, the error ids are concatenated to the old
    %ids.
    for j=1:length(exclusion_criteria)
        if j ~= 2 %only for NoEyeTrace the undesirable values are the zeros. For all other ones, none-zeros are undesireble.
            idx_temp = find(TrialList(:,...
                str2double(exclusion_criteria(j).Column_number_inTrialList)) ~= ...
                str2double(exclusion_criteria(j).decisive_value)); %find the indices of undesible values
                %Example: find(TrialList(:,35) ~= 0) --> which means find
                %the indices of trials that are nonzero, in this case they
                %are the freechoice trials
        elseif j == 2
            idx_temp = find(TrialList(:,...
                str2double(exclusion_criteria(j).Column_number_inTrialList)) == ...
                str2double(exclusion_criteria(j).decisive_value));
            %The only exception to the above rule is the NOEYETRACE
            %condition where we are interested in finding the indices of
            %zero values i.e. trials with no eye trace
        end
        temp = zeros(length(TrialList),1); %a temp variable with the same size as the valid_Trial variable with zeros 
        temp(idx_temp,:) = str2double(exclusion_criteria(j).id); %the undesirable indices take the code value that indicates the reason why this index is not desirtable
        %Here, each index is investigated separately to see if it is the first time
        %that this index takes a exclusion id or not. If it is not, then
        %new ids are contatenated to the old ones.
        for i = 1:length(TrialList)
            if valid_Trials(i) ~= 0 %this index has already been undesirable for other reasons 
                if temp(i) ~= 0     %This means there is a new reason for undesirability of the current index
                    valid_Trials(i) = str2double([num2str(valid_Trials(i)),num2str(temp(i))]); %old values and current values are concatenated allowing for unraveling the reasons why this index is not desirable later
                end
            else
                valid_Trials(i) = temp(i);
            end
        end
    end
    for m = 1:length(repititions)
        if repititions(m) == 2
            if valid_Trials(m) ~= 0
                valid_Trials(m) = str2double([num2str(valid_Trials(m)), '22']);
            elseif valid_Trials(m) == 0
                valid_Trials(m) = 22;
            end
        end
    end
%     assignin('base', 'valid_Trials', valid_Trials);