function SaccadeDetector(EyeX, EyeY)
    EyeX = EyeX';
    EyeY = EyeY';
    %% smooth the raw data 
    %set the smoothing function parameters
%     window_span = 20;
%     order = 4;
%     smoothing_method = 'sgolay';
    %set the input data
    smooth_rawDataX = smooth_saccade(EyeX);
    smooth_rawDataY = smooth_saccade(EyeY);
%     X = EyeX;
%     Y = EyeY;
%     for i = 1:size(X,1)
%         if ~isnan(X(i,1))
%             % the smooth function is applied to those data until the number of datapoints 
%             % left is smaller than the span
%             row_endIndex = find(isnan(X(i,:)),1) - 1;
%             smoothing_end = row_endIndex - window_span + 1; %when one point less than the span length is left
%             X_smooth_sgolay(i,1:smoothing_end) = ...
%                 smooth(X(i,1:smoothing_end), window_span, smoothing_method, order);
%             Y_smooth_sgolay(i,1:smoothing_end) = ...
%                 smooth(Y(i,1:smoothing_end), window_span, smoothing_method, order);
% 
%             % the remaining data points are reported without smoothing
%             X_smooth_sgolay(i,smoothing_end + 1:size(X,2)) = ...
%                 X(i,row_endIndex - window_span + 2:end);
%             Y_smooth_sgolay(i,smoothing_end + 1:size(Y,2)) = ...
%                 Y(i,row_endIndex - window_span + 2:end);
%         else
%             %In case, all data points are NaN, the smoothed data is NaN too
%             X_smooth_sgolay(i,:) = NaN;
%             Y_smooth_sgolay(i,:) = NaN;
%         end
%     end
    %% point-by-point calculation of first derivative (velocity) from smoothed data
    %{
    . the derivative is computed by the subtraction of the value of the next time 
    point from the current vlaue.
    . the Euclidean distance of the smoothed data between times two consecutive 
    data points (i.e. t and t+1) defines the angular velocity.
    ** Zero is subtracted from the last value of the row to compute the derivative
    %}
    sampling_freq = 1000;
    X = X_smooth_sgolay;
    Y = Y_smooth_sgolay;
    for i = 1: size(X,1) %for evey row
        %take the index of the last non-NaN of the row
        row_endIndex = find(isnan(X(i,:)),1) - 1;
        for j = 1 : size(X,2)
            if j < row_endIndex
                %first derivative or vel is calculated by taking the
                %difference of two consecutive points ((t+1) - t).
                velX(i,j) = X(i,j+1) - X(i,j); 
                velY(i,j) = Y(i,j+1) - Y(i,j);
                %The Euclidean distance between the two consecutive value
                %is used to define angular velocity or vel
                vel(i,j) = sqrt((X(i,j+1) - X(i,j)).^2+(Y(i,j+1)...
                    - Y(i,j)).^2);
            elseif j == row_endIndex
                %the last element of vel is set at zero
                velX(i,j) = 0;
                velY(i,j) = 0;
                vel(i,j) = 0;
            else
                %the NaN elements of X/Y are set as NaN in vel too
                velX(i,j) = NaN;
                velY(i,j) = NaN;
                vel(i,j) = NaN;
            end
        end
    end
    %the amplitude unit is corrected by multiplying the exsiting values by 
    % the sampling frequency (deg/ms -> deg/s)
    velX = velX * sampling_freq; %deg/s
    velY = velY * sampling_freq; %deg/s
    vel  = vel  * sampling_freq; %deg/s
    assignin('base', 'velX', velX);
    assignin('base', 'velY', velY);
    assignin('base', 'vel', vel);
%% visulaize the data
%velocity data
% figure;
% plot(velX(10,1:3500))
% hold on
% plot(velX_smooth_savgol_temp(1:3500))
% hold off
% %accelertion data
% plot(accX(10,1:3500))
% hold on
% plot(accX_smooth_savgol_temp(1:3500))
% 
% 
trial_no = 367;
plot(EyeX(trial_no,:), 'o')
hold on
plot(smoothedX(trial_no,:))
% plot(X_smooth_sgolay10)