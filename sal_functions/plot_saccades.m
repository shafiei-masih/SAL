% This script is used to inspect the detected saccades one by one and judge
% their validity, choose the one that are mistakenly detected or adjust
% their detected onset or offset.
%% Load the data
%specify the file that ends in ".raw.mat"
[filename2,filepath2] = uigetfile('J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed');
% filepath2 = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\1.04062020\Preproc\Beh'; filename2 = '04062020_1.raw.mat';
%load the relevant variables
load(fullfile(filepath2, filename2), 'filename', 'filepath', ...
    'detected_saccades_fixations', 'vel', 'acc', 'TargetX', 'smooth_EyeX', ...
    'raw_targetX_shift');
%% Section 1: List of all saccades
%make a list of all the detected saccades
list_saccades = [];
for i =1:size(detected_saccades_fixations,2)
    if ~isnan(detected_saccades_fixations(i).saccades(1,1))
        list_saccades = [list_saccades; i];
    else 
        continue;
    end
end
%% Section 1.1: list trial types
for i = 1:length([raw_targetX_shift(:).target_ShiftType]')
        if ~isnan(detected_saccades_fixations(i).saccades(1,1))
            trialType(i,1) = raw_targetX_shift(i).target_ShiftType;
        else
            trialType(i,1) = NaN;
        end
end
trialType_cat = categorical(trialType, [1 2 3 5], ...
    {'stayput', 'outward ISS', 'inward ISS', 'freechoice'});
trialType_cat(isundefined(trialType_cat)) = 'missing';
    %% Section 2: Plot all saccades
%plot all the saccades one-by-one and check if the saccades and their
%features  like onset, offset or PV are detected correctly.
figure;
for j = 1: size(list_saccades,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
    disp(j);
    clf;
    trial_no = list_saccades(j);%i;
    jumpTime = raw_targetX_shift(trial_no).ShiftTime_Primary;
    %
    disp(['Trial no.: ', num2str(trial_no), '%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    hold on; 
    plot(TargetX(trial_no,:)*20, 'Color', "#c26202",'LineWidth',2);
    plot(vel(trial_no,:), 'Marker', "o", 'MarkerEdgeColor', "#b1b4b5", 'LineWidth',0.5)
    plot(vel(trial_no,:), 'b-')
    plot(acc(trial_no,:), 'c-')
    plot(smooth_EyeX(trial_no,:)*20, 'Marker', "o", 'MarkerEdgeColor', "#aeebfc", 'LineWidth',0.5);
    ax = get(gca);
    XLimEnd = ax.XLim(2);
    if ~isnan(detected_saccades_fixations(trial_no).saccade_offset)
        plot(detected_saccades_fixations(trial_no).saccade_offset(1,2),...
            detected_saccades_fixations(trial_no).saccade_offset(1,1), ...
            'Marker', "o", 'MarkerEdgeColor', "#a13bf5", 'LineWidth',2.5)
        XLimEnd = detected_saccades_fixations(trial_no).saccade_offset(1,2)+ ...
            round((ax.XLim(2) - detected_saccades_fixations(trial_no).saccade_offset(1,2))/5); 
    end
    if size(detected_saccades_fixations(trial_no).saccade_offset,1) > 1
        plot(detected_saccades_fixations(trial_no).saccade_offset(2,2),...
        detected_saccades_fixations(trial_no).saccade_offset(2,1), ...
        'Marker', "o", 'MarkerEdgeColor', "#a13bf5",'LineWidth',2.5)
        XLimEnd = detected_saccades_fixations(trial_no).saccade_offset(2,2) + ...
            round((ax.XLim(2) - detected_saccades_fixations(trial_no).saccade_offset(2,2))/5);
    end
    plot(detected_saccades_fixations(trial_no).fixations(:,2),detected_saccades_fixations(trial_no).fixations(:,1), ...
        'go', 'MarkerEdgeColor', "#198c45", 'LineWidth',0.5)
    plot(detected_saccades_fixations(trial_no).saccades(:,2),detected_saccades_fixations(trial_no).saccades(:,1), 'ro','LineWidth',2.5)
    plot(detected_saccades_fixations(trial_no).saccade_onset(:,2),detected_saccades_fixations(trial_no).saccade_onset(:,1), 'mo','LineWidth',2.5)
    title({['Trial number: ', num2str(trial_no)],...
        ['Trial type = ', char(trialType_cat(trial_no))]}); 
    legend('velocity samples', 'velocity line', 'fixation', 'saccade', 'Location', 'northwest');
    xlabel('time from the onset of ITI (msec)');
    ylabel('velocity (deg/sec)');
    disp(['mean: ', num2str(nanmean(detected_saccades_fixations(trial_no).fixations(:,1)))]);
    disp(['std: ', num2str(nanstd(detected_saccades_fixations(trial_no).fixations(:,1)))]);
    disp(['mean + 3sd: ', num2str(nanstd(detected_saccades_fixations(trial_no).fixations(:,1))*3+...
        nanmean(detected_saccades_fixations(trial_no).fixations(:,1)))]);
%     ax = get(gca);
    xlim([jumpTime-150 XLimEnd])
    %
    clear ax
    pause;
end
%%
trial_no = 1026
%% Section 3: list erroneous trials
%make a list of those trial that should be check twice
list_new = [271; 327; 334; 346; 440; 525; 618; 621; 673; 695; 715; 748; 756];
% list_new2 = list_saccades(list_saccades >414);
% list_new = [list_new; list_new2];


% Check out to see if there are corrective sacades w/o detected offsets
list_offset =[];
for i = 1:size(detected_saccades_fixations,2)
        if ~isnan(detected_saccades_fixations(i).saccades(1,1))
            saccades = detected_saccades_fixations(i).saccades;         %saccades
%             onset = detected_saccades_fixations(i).saccade_onset;       %onset(s)
            Offset = detected_saccades_fixations(i).saccade_offset;     %Offset(s)
            disp(i);
            %input
            if size(saccades, 1) > 1
                if size(Offset, 1) == 1
                    list_offset = [list_offset; i];
                end
            end
        end
end

% add them to the list
% list_new = [list_new; list_offset];
correction_list = detected_saccades_fixations(list_new');
for listi = 1: size(list_new,1)
    correction_list(listi).trialno = list_new(listi);
end
openvar('correction_list')
ids = [correction_list.trialno]';
openvar('ids')
% open the 
% review the saccade in the new list again
%% remove those saccades that are in error
discardPile = [271; 327; 334; 346; 440; 525; 748; 756];
% list_new2 = list_saccades(list_saccades >414);
% discardPile = [discardPile; list_new2];
for listi = 1: size(discardPile,1)
%     disp(listi);
    trial_no = find([correction_list.trialno]' == discardPile(listi));
    correction_list(trial_no).saccades = NaN;
    correction_list(trial_no).saccade_onset = NaN;
    correction_list(trial_no).saccade_offset = NaN;
end
%% find the remaining saccades
% list_remaining = setdiff(list_new, vertcat(discardPile, list_corr));
list_remaining = setdiff(list_new, discardPile);
% list_remaining = [199; 223; 241; 310; 429; 457; 548; 566; 591; 1026; 1051; 1180; 1338];
% list_remaining = [171; 177; 199; 214; 222; 224; 241; 277; 310; 327; ...
%     336; 548; 550; 566; 680; 951; 1026; 1051; 1180];
% list_remaining = [38; 182; 188; 191; 204; 229; 340; 428; 457; 499;...
%     533; 547; 572; 648; 686; 723; 729; 839; 1059];

%% Section 4: plot selected trials
figure;
clear cursor_info;
%uncomment the counter variable below only on the first iteration
% counter = 1;
for i = counter: size(list_remaining,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
%     disp(j);
    counter = counter +1;
    j = find([correction_list.trialno]' == list_remaining(i));
%     j = find([correction_list.trialno]' == list_remaining(listi));
    if ~isnan(correction_list(j).saccades(1,1))
        clf;
        trial_no = list_remaining(i);%i;
    else
        trial_no = list_remaining(j);
        disp('this trial was discarded!');
        break;
    end
    break;
end

disp(['Trial no.: ', num2str(trial_no), '%%%%%%%%%%%%%%%%%%%%%%%%%%']);
plot(vel(trial_no,:), 'ko')
hold on; 
plot(vel(trial_no,:), 'b-')
plot(acc(trial_no,:), 'c-')
plot(correction_list(j).saccade_offset(1,2),...
    correction_list(j).saccade_offset(1,1), 'mo')
if size(correction_list(j).saccade_offset,1) > 1
    plot(correction_list(j).saccade_offset(2,2),...
    correction_list(j).saccade_offset(2,1), 'mo')
end
plot(correction_list(j).fixations(:,2),correction_list(j).fixations(:,1), 'go')
plot(correction_list(j).saccades(:,2),correction_list(j).saccades(:,1), 'ro')
plot(correction_list(j).saccade_onset(:,2),correction_list(j).saccade_onset(:,1), 'mo')
plot(TargetX(trial_no,:)*20);
plot(smooth_EyeX(trial_no,:)*20, 'bo');
title({['Trial number: ', num2str(trial_no)],...
        ['Trial type = ', char(trialType_cat(trial_no))], ...
        ['Index = ', num2str(j)]}); 
legend('velocity samples', 'velocity line', 'fixation', 'saccade');
xlabel('time from the onset of ITI (msec)');
ylabel('velocity (deg/sec)');
disp(['mean: ', num2str(nanmean(correction_list(j).fixations(:,1)))]);
disp(['std: ', num2str(nanstd(correction_list(j).fixations(:,1)))]);
disp(['mean + 3sd: ', num2str(nanstd(correction_list(j).fixations(:,1))*3+...
    nanmean(correction_list(j).fixations(:,1)))]);
%         pause;
%% Remove corrective
list_corr = [618; 673; 695];
counter = 1;
for i = counter: size(list_corr,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
%     disp(j);
    counter = counter +1;
    j = find([correction_list.trialno]' == list_corr(i));
    disp(j);
    %
    correction_list(j).saccades
    correction_list(j).saccades(2,:) = [];
    correction_list(j).saccade_onset(2,:) = [];
    correction_list(j).saccade_offset(2,:) = [];
    %
end
%% Remove primary
counter = 1;
for i = counter: size(list_remaining,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
%     disp(j);
    counter = counter +1;
    j = find([correction_list.trialno]' == list_remaining(i));
    disp(j);
    %
    correction_list(j).saccades
    correction_list(j).saccades(1,:) = [];
    correction_list(j).saccade_onset(1,:) = [];
    correction_list(j).saccade_offset(1,:) = [];
    %
end
%% Correct corrective
% cursor_info = cursor_info;
clear cursor_info;
idx = j;
correction_list(idx).saccades
correction_list(idx).allsaccades
%%
sel_add = 4;
sel_remove = 2;
selected_saccade = correction_list(idx).allsaccades(sel_add,:);
correction_list(idx).saccades(sel_remove,:) = [];
if sel_remove == 1
    correction_list(idx).saccades = vertcat(selected_saccade, ...
        correction_list(idx).saccades);
elseif sel_remove == 2
    correction_list(idx).saccades = vertcat(correction_list(idx).saccades, ...
        selected_saccade);
end
%% onset and offset
onset(1,1) = cursor_info(2).Position(2);
onset(1,2) = cursor_info(2).Position(1);
offset(1,1) = cursor_info(1).Position(2);
offset(1,2) = cursor_info(1).Position(1);
%
correction_list(idx).saccade_onset(sel_remove,:) = [];
correction_list(idx).saccade_offset(sel_remove,:) = [];
if sel_remove == 1
    correction_list(idx).saccade_onset = vertcat(...
        onset, correction_list(idx).saccade_onset);
    correction_list(idx).saccade_offset = vertcat(...
        offset, correction_list(idx).saccade_offset);
elseif sel_remove == 2
    correction_list(idx).saccade_onset = vertcat(...
        correction_list(idx).saccade_onset, onset);
    correction_list(idx).saccade_offset = vertcat(...
        correction_list(idx).saccade_offset, offset);
end
close figure 1
%% add corrective peak
clear cursor_info;
new_saccade = [cursor_info.Position(2), cursor_info.Position(1)];
correction_list(idx).saccades = vertcat(correction_list(idx).saccades, ...
    new_saccade);
close figure 1

%% Change primary offset
% clear cursor_info;
idx = j;
new_offset = [cursor_info.Position(2), cursor_info.Position(1)];
correction_list(idx).saccade_offset(1,:) = [];
correction_list(idx).saccade_offset = vertcat(...
    new_offset, correction_list(idx).saccade_offset);
close figure 1
%%
disp(['Trial no.: ', num2str(trial_no), '%%%%%%%%%%%%%%%%%%%%%%%%%%']);
plot(vel(trial_no,:), 'ko')
hold on; 
plot(vel(trial_no,:), 'b-')
plot(acc(trial_no,:), 'c-')
plot(correction_list(j).saccade_offset(1,2),...
    correction_list(j).saccade_offset(1,1), 'mo')
if size(correction_list(j).saccade_offset,1) > 1
    plot(correction_list(j).saccade_offset(2,2),...
    correction_list(j).saccade_offset(2,1), 'mo')
end
plot(correction_list(j).fixations(:,2),correction_list(j).fixations(:,1), 'go')
plot(correction_list(j).saccades(:,2),correction_list(j).saccades(:,1), 'ro')
plot(correction_list(j).saccade_onset(:,2),correction_list(j).saccade_onset(:,1), 'mo')
plot(TargetX(trial_no,:)*20);
plot(smooth_EyeX(trial_no,:)*20, 'bo');
title({['Trial number: ', num2str(trial_no)],...
        ['Trial type = ', char(trialType_cat(trial_no))], ...
        ['Index = ', num2str(j)]}); 
legend('velocity samples', 'velocity line', 'fixation', 'saccade');
xlabel('time from the onset of ITI (msec)');
ylabel('velocity (deg/sec)');
disp(['mean: ', num2str(nanmean(correction_list(j).fixations(:,1)))]);
disp(['std: ', num2str(nanstd(correction_list(j).fixations(:,1)))]);
disp(['mean + 3sd: ', num2str(nanstd(correction_list(j).fixations(:,1))*3+...
    nanmean(correction_list(j).fixations(:,1)))]);

%% Section 5: replot after correction
% figure;
% for j = 1: size(list_new,1)%num_saccades_ToReview%size(detected_saccades_fixations,2)
%     disp(j);
%     if ~isnan(correction_list(j).saccades(1,1))
%         clf;
%         trial_no = list_new(j);%i;
%         disp(['Trial no.: ', num2str(trial_no), '%%%%%%%%%%%%%%%%%%%%%%%%%%']);
%         plot(vel(trial_no,:), 'ko')
%         hold on; 
%         plot(vel(trial_no,:), 'b-')
%         plot(acc(trial_no,:), 'c-')
%         plot(correction_list(j).saccade_offset(1,2),...
%             correction_list(j).saccade_offset(1,1), 'mo')
%         if size(correction_list(j).saccade_offset,1) > 1
%             plot(correction_list(j).saccade_offset(2,2),...
%             correction_list(j).saccade_offset(2,1), 'mo')
%         end
%         plot(correction_list(j).fixations(:,2),correction_list(j).fixations(:,1), 'go')
%         plot(correction_list(j).saccades(:,2),correction_list(j).saccades(:,1), 'ro')
%         plot(correction_list(j).saccade_onset(:,2),correction_list(j).saccade_onset(:,1), 'mo')
%         plot(TargetX(trial_no,:)*20);
%         plot(smooth_EyeX(trial_no,:)*20, 'bo');
%         title(['Trial number: ', num2str(trial_no)]); 
%         legend('velocity samples', 'velocity line', 'fixation', 'saccade');
%         xlabel('time from the onset of ITI (msec)');
%         ylabel('velocity (deg/sec)');
%         disp(['mean: ', num2str(nanmean(correction_list(j).fixations(:,1)))]);
%         disp(['std: ', num2str(nanstd(correction_list(j).fixations(:,1)))]);
%         disp(['mean + 3sd: ', num2str(nanstd(correction_list(j).fixations(:,1))*3+...
%             nanmean(correction_list(j).fixations(:,1)))]);
%         pause;
%     else
%         disp('this trial was discarded!');
%         continue;
%     end
% end
%% Section 6: store the changes
correction_detected_saccades_fixations = correction_list;
year = filename(end-26:end-23);
month = filename(end-21:end-20);
day = filename(end-18:end-17);
additional = '_1';
filename_new = [day, month, year, additional, '_correction.raw.mat'];
filepath_new = [erase(filepath, 'Original\Beh\'), 'Preproc\Beh\'];
% filepath_new = 'J:\Monkey Project\Analysis\Data\Kruemmel\Analyzed\1.04062020\Preproc\Beh';
save(fullfile(filepath_new, filename_new), ...
    'filename', 'filepath', 'correction_detected_saccades_fixations');
