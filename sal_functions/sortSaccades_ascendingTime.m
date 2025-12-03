function listSaccades_height_timestamp = sortSaccades_ascendingTime(listSaccades_height_timestamp)
%this function takes a matrix: col1 -> peakheight and col2 -> peak timestamp,
%rows are trials that are sorted based on peak height in a descending
%fashion. It returns a matrix with the same size and structure that is
%sorted based on the timestamp in a ascendign fashion.
%
% NOTE. NaN values are returend the same.
    if ~isnan(listSaccades_height_timestamp(1,1))
        [temp, index_temp] = sort(listSaccades_height_timestamp(:,2), 'ascend');
        listSaccades_height_timestamp = listSaccades_height_timestamp(index_temp,:);
    else 
        listSaccades_height_timestamp = NaN;
    end