%-------------------------------------------------------------------------
% File        : writeDataToFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes data to file.
%-------------------------------------------------------------------------

function status = writeDataToFile(data, filename)
%writeDataToFile - Decimates/Downsamples a signal.
%   data     ... data to be written
%   filename ... filename

fileID = fopen(filename, 'w');
if fileID <= 0
    status = false;
    return;
end

% Convert to fixed point
data_fp = cast(data, 'like', fi([], true, 16,15));

% Write to file
for i=1:length(data_fp)
    fprintf(fileID, "%.15f\n", data_fp(i));
end
fclose(fileID);


status = true;
end
