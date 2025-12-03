function [detected_saccades_fixations, vel_threshold] = ...
    saccadeFixationDetector(velocitydata, InitialPointOfSearch, ...
    defaultVelocityThreshold, minInterPeakIntervalThreshold)
%note that this scripts is dealing with the saccade detection problem only.
%Other important goals like detecting on- and off-set, peal velocity, etc.
%of saccades can be later scrutinized once the saccades are deteced.
%% detect all the peaks in the vel data between the InitialPointOfSearch and trial end
%first find all the peaks in the velocity data between the starting point (aka
%primary target shift time) and the end regardless of the height or other
%features of the peaks.
lastnonNaNelement = tbt_lastNonNaN_Index(velocitydata);
for i = 1:size(velocitydata,1)
%     disp(i);
    %the findpeaks function is only applied to valid and freechoice trials.
    if (InitialPointOfSearch(i) ~= 0)
        if (lastnonNaNelement(i)-20) - InitialPointOfSearch(i) > 3
            [peaks, locs] = findpeaks(velocitydata(i, InitialPointOfSearch(i):lastnonNaNelement(i)-20), ...
                'SortStr', 'descend');
            locs = InitialPointOfSearch(i) + locs - 1;
            if ~isempty(peaks)
                detected_saccades_fixations(i).allPotentialSaccades =[peaks', locs'];
            else
                detected_saccades_fixations(i).allPotentialSaccades = NaN;
            end
        elseif (lastnonNaNelement(i)-20) - InitialPointOfSearch(i) <= 3 
            detected_saccades_fixations(i).allPotentialSaccades = NaN;
        end
    else
        detected_saccades_fixations(i).allPotentialSaccades = NaN;
    end
end
%% find the trial-by-trial adaptive threshold
vel_threshold = adaptiveVelocityThreshold(detected_saccades_fixations, defaultVelocityThreshold);
%extract the adaptive threshold into a variable called correct_threshold
for i = 1: size(vel_threshold, 2)
%     disp(i);
    if ~isnan(vel_threshold(i).thresholds(1,1))
        corrected_threshold(i,1) = vel_threshold(i).thresholds(end);
    elseif isnan(vel_threshold(i).thresholds(1,1))
        corrected_threshold(i,1) = NaN;
    end
end
%% use the adaptive threshold to find saccades
for i = 1:length(corrected_threshold)
	% if initial point of search is nonzero, i.e. the target shift data for
	% a given trial is available
%     disp(i);
    if ~isnan(corrected_threshold(i))
        threshold = corrected_threshold(i);
        %if there are any peaks that are larger than the threshold
        %there are cases where only the very last data points (~30 data points)
        %in the velocity data show a corresponding saccade, but they do not
        %fully capture the whole saccade up until the end. These saccades
        %showed be discarded as the saccade offset is usually missing.
        if detected_saccades_fixations(i).allPotentialSaccades(1,1) > threshold
            if ((lastnonNaNelement(i)-20 - InitialPointOfSearch(i) +1) -...
                    minInterPeakIntervalThreshold) > 0
                [peaks, locs] = findpeaks(velocitydata(i, InitialPointOfSearch(i):lastnonNaNelement(i)-20), ...
                'MinPeakHeight', threshold, ...
                'MinPeakDistance', minInterPeakIntervalThreshold, ...
                'SortStr', 'descend');
                locs = InitialPointOfSearch(i) + locs - 1;
                detected_saccades_fixations(i).saccades = horzcat(peaks', locs');
            else
                detected_saccades_fixations(i).saccades = NaN;
            end
        elseif detected_saccades_fixations(i).allPotentialSaccades(1,1) <= threshold
            detected_saccades_fixations(i).saccades = NaN;
        end
    else
        detected_saccades_fixations(i).saccades = NaN;
    end
end
% %% use the adaptive thresholds to find fixations
% for i = 1:length(corrected_threshold)
%     if ~isnan(corrected_threshold(i))
%         threshold = corrected_threshold(i);
%         [peaks, locs] = findpeaks(velocitydata(i, InitialPointOfSearch(i):end), ...
%         'MinPeakHeight', threshold, 'SortStr', 'descend','MinPeakDistance', minInterPeakIntervalThreshold);
%         locs = InitialPointOfSearch(i) + locs - 1;
%         detected_saccades_fixations(i).saccades = horzcat(peaks', locs');
%     else
%         detected_saccades_fixations(i).saccades = NaN;
%     end
% end
%% find fixations
%fixations are deduced from the difference between all potential saccades
%and true saccades detected after updating the threshold value. In case
%there is no saccade detected, all the potential saccades are marked as
%fixation.
for i = 1:length(corrected_threshold)
	% if initial point of search is nonzero, i.e. the target shift data for
	% a given trial is available
    if ~isnan(corrected_threshold(i))
        threshold = corrected_threshold(i);
        %if there are any peaks that are larger than the threshold
        %there are cases where only the very last data points (~30 data points)
        %in the velocity data show a corresponding saccade, but they do not
        %fully capture the whole saccade up until the end. These saccades
        %showed be discarded as the saccade offset is usually missing.
        if detected_saccades_fixations(i).allPotentialSaccades(1,1) > threshold
            [peaks, locs] = findpeaks(velocitydata(i, InitialPointOfSearch(i):lastnonNaNelement(i)-20), ...
            'MinPeakHeight', threshold, ...
            'SortStr', 'descend');
            locs = InitialPointOfSearch(i) + locs - 1;
            detected_saccades_fixations(i).allsaccades = horzcat(peaks', locs');
        elseif detected_saccades_fixations(i).allPotentialSaccades(1,1) <= threshold
            detected_saccades_fixations(i).allsaccades = NaN;
        end
    else
        detected_saccades_fixations(i).allsaccades = NaN;
    end
end

for i = 1:size(detected_saccades_fixations, 2)
    %if allPotentialSaccades data are available
    if ~isnan(detected_saccades_fixations(i).allPotentialSaccades(1,1))
        fixation_temp = [detected_saccades_fixations(i).allPotentialSaccades];
        %if allPotentialSaccade data are available but saccade(s) higher
        %than the adaptive threshold was found, these true saccades are
        %removed from the pool. The remaining points are fixations.
        if ~isnan(detected_saccades_fixations(i).saccades)
            num_elementsToRemove = size(detected_saccades_fixations(i).allsaccades, 1);
            fixation_temp(1:num_elementsToRemove,:) = [];
        end
        %if allPotentialSaccade data are available but no saccade higher
        %than the adaptive threshold was found, all potential data point
        %are reported as fixation.
        detected_saccades_fixations(i).fixations = fixation_temp;
    elseif isnan(detected_saccades_fixations(i).allPotentialSaccades)
        detected_saccades_fixations(i).fixations = NaN;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dependent functions
function vel_threshold = adaptiveVelocityThreshold(detected_saccades_fixations, threshold_def)
%This function takes the strcut detected_saccades_fixations as the input argument and
%returns a struct with one field called thresholds.
%
%Each row of the thresholds field belong to one trial. for each nonNaN
%trial, the values are the thresholds that were used in each iteration to
%detect saccades. The end element for each nonNaN trial is the final
%adaptive threshold that could distinguish between potential saccades and
%noise.
%
%**note that NaN values are based on zeros in the firstTargetShift function
%that in turn is based on the targetShiftDetector function. The
%descriptions of the zero values can be found in the targetShiftDetector
%function.
%% find the trial-by-trial adaptive threshold
%choose the default threshold between 100-300 deg/sec (Nyström & Holmqvist, 2010) 
for i = 1: size(detected_saccades_fixations,2)
%     disp(i);
    peaks_locs = [detected_saccades_fixations(i).allPotentialSaccades];
    %once the very first value of the peaks_locs of a given trial is not
    %NaN, the rest of the script is compiled
    if ~isnan(peaks_locs(1,1))
        %the threshold's defaul value is set at default threshold 
        threshold = threshold_def;
        %peaks with their indices belonging to detected saccades are stored
        %in temp_include
        temp_include = [];
        %the indices of the detected saccades'peaks in peaks_locs variable 
        %is stored in i_s
        i_s = [];
        %first find the peaks that are equal or above the default threshold
        for j = 1:size(peaks_locs,1)
            if peaks_locs(j,1) >= threshold(end)
                temp_include = vertcat(temp_include, peaks_locs(j,:));
                i_s = [i_s; j];
            else
                continue;
            end
        end
        %if any peaks >= defaul threshold are found, these peaks and their indices
        %are removed from the pile and a new threshold based on the mean and std of
        %the remaining peaks is calculated. The new threshold is used to find new
        %peaks in the existing pile of peaks. The peaks that are found are stored
        %in the temp_include and then removed from the pile. The remaing peaks are
        %again used to calculate a new threshold to find new peaks. This loop goes
        %on until there is no peak that is above or equal to the new threshold.
        if ~isempty(i_s)
            %as long as there are peaks above the threshold the following scripts
            %will be compiled
            while ~isempty(i_s)
                %the peaks >= threshold and their indices are kicked out of the
                %pool
                peaks_locs(i_s, :) = [];
                %mean and std of the remaining peaks are calculated
                average_peaks = nanmean(peaks_locs(:,1));
                sd_peaks = std(peaks_locs(:,1));
                %updated threshold is the mean plus 6 times the std
                threshold_updated = average_peaks + 6*sd_peaks;
                %the updated threshold is amended to the old thresholds
                threshold = vertcat(threshold, threshold_updated);
                %i_s is emptied allowing for setting new values to it 
                i_s = [];
                %the loop continues for as long as the number of reamining peaks
                %in the pool have values above the new threshold
                for k = 1:length(peaks_locs)
                    %for those peaks >= updated threshold (i.e. the last threshod
                    %that was amended to the thresholds), their values plus their 
                    %indices are stored and the index in the peaks list is added to
                    %the i_s
                    if peaks_locs(k,1) >= threshold(end)
                        temp_include = vertcat(temp_include, peaks_locs(k,:));
                        i_s = [i_s; k];
                    else
                    %for those peaks smaller than the threshold, nothing happens
                        continue;
                    end
                end
            end
        else
            disp(num2str(i));
            disp(['Threshold was not updated. The final velocity threshold is the same as the default, i.e. ' num2str(threshold_def) , ' deg/sec']);
        end
        vel_threshold(i).thresholds = [threshold];
    else
        vel_threshold(i).thresholds = NaN;
    end
end