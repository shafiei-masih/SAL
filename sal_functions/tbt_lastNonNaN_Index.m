function row_endIndex = tbt_lastNonNaN_Index(data)
%This function accepts movement kinematics data where each row represents a
%given trial and returns a list of the index of the last nonNaN value of 
%each row.
%
%Input argument: time series of movement kinematics in a 2D matrix where
%                rows are trials and column are the value of a the desired 
%                kinematics at each point in time.
%
%Returns a list of indices of the last nonNaN values of each trial.
%
%Notes: 
%   1. in case the trial does not have any NaN, the last index of
%   the trial, i.e. number of columns of the data matrix, is returned.
%
%   2. in case of all the values in a given row are NaN, NaN is returned.
%
%   3. this function uses the dimensionCorrector function to ensure that
%   the matrix dimensions are in the desirable format.

%     data = dimensionCorrector(data);
    for i = 1:size(data, 1)
        if ~isnan(data(i,1))
            %if the last element of a given row i is NaN, the find function
            %finds the index of last non-NaN elemlent and assigns it to row_endIndex
            if isnan(data(i,end))
                %sepcify the index of the last non-NaN value of a given row
                row_endIndex(i,1) = find(isnan(data(i,:)),1) - 1;
            %in case the last element is not NaN, the index of last non-NaN
            %value is the end index of the row
            elseif ~isnan(data(i,end))
                row_endIndex(i,1) = size(data,2);
            end
        elseif isnan(data(i,1))
            row_endIndex(i,1) = NaN;
        end
    end
