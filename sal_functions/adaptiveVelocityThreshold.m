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
    disp(i);
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
            disp('no saccade was detected');
        end
        vel_threshold(i).thresholds = [threshold];
    else
        vel_threshold(i).thresholds = NaN;
    end
end