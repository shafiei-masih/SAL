function smoothData = smooth_saccade(X, window_span, order, smoothing_method)
%This function smooth the desired signal given the default parameters that
%were set based on a trial-error approach unless these paramters are set
%otherwise as input arguments to the function.
%To overcome the undesired behavior of the smooth function at the end of
%the signal, the smooth_saccade function returns unsmoothed data points as
%soon as the span of the slifing window is smaller than the remaining
%datapoints at the end of a given list of data points.
%In case that all datapoints are NaN, the same is returned by the function.
    arguments
        X                   {mustBeNumeric};
        window_span         {mustBePositive}    = 20;
        order               {mustBePositive}    = 4;
        smoothing_method    char                = 'sgolay';
    end
    
    row_endIndex = tbt_lastNonNaN_Index(X);
    for i = 1:size(X,1)
        %if the first of a given row is not NaN, the rest of the script is
        %run
        if ~isnan(X(i,1))
%             %if the last element of a given row i is NaN, the find function
%             %finds the index of last non-NaN elemlent and assigns it to row_endIndex
%             if isnan(X(i,end))
%                 %sepcify the index of the last non-NaN value of a given row
%                 row_endIndex = find(isnan(X(i,:)),1) - 1;
%             %in case the last element is not NaN, the index of last non-NaN
%             %value is the end index of the row
%             elseif ~isnan(X(i,end))
%                 row_endIndex = size(X,2);
%             end
            smoothing_end = row_endIndex(i) - window_span + 1; %when one point less than the span length is left
            % the smooth function is applied to those data until the number of datapoints 
            % left is smaller than the span
            smoothData(i,1:smoothing_end) = ...
                smooth(X(i,1:smoothing_end), window_span, smoothing_method, order);
            % the remaining data points are reported without smoothing
            smoothData(i,smoothing_end + 1:size(X,2)) = ...
                X(i,row_endIndex(i) - window_span + 2:end);
        else
            %In case, all data points are NaN, the smoothed data is NaN too
            smoothData(i,:) = NaN;
        end
    end
