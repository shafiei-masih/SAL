function dimensions_corrected = dimensionCorrector(data)

[n,m]=size(data);
% if the no. of rows is larger than no. of columns, the matrix needs to be
% transposed:
if n > m 
	dimensions_corrected = data';
else
    dimensions_corrected = data;
%     disp('Dimentions of the input argument are in the desired format. :)')
end
