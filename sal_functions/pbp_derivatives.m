function [derivativeX, derivativeY, derivative_total] = pbp_derivatives(dataX, dataY)
%This function calcaultes the point-by-point first derivative for a set of 
%inputs recorded along x- and y-coordinates. 
%Input arguments are two same-size matrices with time series of positional 
%data seperated based on x- or y-coordinate.
%It retursn up to three matrices: 
%   . first derivative of the x-coordinate data
%   . first derivative of the y-coordinate data
%   . total derivative which is defined as the poin-by-point Euclidean 
%   distance between corresponding pairs of x- or y-coordinates

%The derivative is computed by the subtraction of the value of positional 
%data at time t+1 from that of the time t.
%The Euclidean distance is computed by the following equation:
% deltaPrime_(t) = sqrt((x_(t+1) - x_(t)).^2 + (y_(t+1) - y_(t)).^2)
%where deltaprime_(t) is the total first derivative at the time t, x_(t+1)
%is the positin along x axis at time t+1 and hence so forth.

%The above computations are added to all the elements of a given row except
%for the very last nonNaN element of the row where there is no nonNaN
%elemet left in the row to be subtracted from the current value. In this
%case, the value of the derivative is set at zero.

%In case all of the values of a given row are NaN, the same is returend as
%the drivative.

%     sampling_freq = 1000;
%     X = X_smooth_sgolay;
%     Y = Y_smooth_sgolay;
    row_endIndex = tbt_lastNonNaN_Index(dataX);
    for i = 1: size(dataX,1) %for evey row
%         %if the last element of a given row i is NaN, the find function
%         %finds the index of last non-NaN elemlent and assigns it to row_endIndex
%         if isnan(dataX(i,end))
%             %sepcify the index of the last non-NaN value of a given row
%             row_endIndex = find(isnan(dataX(i,:)),1) - 1;
%         %in case the last element is not NaN, the index of last non-NaN
%         %value is the end index of the row
%         elseif ~isnan(dataX(i,end))
%             row_endIndex = size(dataX,2);
%         end
        for j = 1 : size(dataX,2)
            if j < row_endIndex(i)
                %first derivative or vel is calculated by taking the
                %difference of two consecutive points ((t+1) - t) as long 
                %the index of the current input is smaller than row_endIndex.
                derivativeX(i,j) = dataX(i,j+1) - dataX(i,j); 
                derivativeY(i,j) = dataY(i,j+1) - dataY(i,j);
                %The Euclidean distance between the two consecutive value
                %is used to define total derivative
                derivative_total(i,j) = sqrt((dataX(i,j+1) - dataX(i,j)).^2+(dataY(i,j+1)...
                    - dataY(i,j)).^2);
            elseif j == row_endIndex(i)
                %When the index of the currnet value is the row_endIndex,
                %the value of the derivative is set at zero.
                derivativeX(i,j) = 0;
                derivativeY(i,j) = 0;
                derivative_total(i,j) = 0;
            else
                %the NaN elements of X/Y are set as NaN in derivative too
                derivativeX(i,j) = NaN;
                derivativeY(i,j) = NaN;
                derivative_total(i,j) = NaN;
            end
        end
    end