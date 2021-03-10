%-------------------------------------------------------------------------
% File        : writeDataToFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes data to file.
%-------------------------------------------------------------------------

function status = writeDataToFile(data, filename)
%writeDataToFile - Writes data to file.
%   data     ... data to be written
%   filename ... filename

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end

% Convert to fixed point
data_fp = cast(data, 'like', fi([], true, 16,15));

% Write to file
fprintf(fileID, "%.15f\n", data_fp);

fclose(fileID);


status = true;
end
