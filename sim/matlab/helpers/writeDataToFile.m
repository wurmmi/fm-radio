%-------------------------------------------------------------------------
% File        : writeDataToFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes data to file.
%-------------------------------------------------------------------------

function status = writeDataToFile(data, filename, fp_width, fp_width_frac)
%writeDataToFile - Writes data to file.
%   data     ... data to be written
%   filename ... filename

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end

if isreal(data)
    % Convert to fixed point
    data_fp = cast(data, 'like', fi([], true, fp_width, fp_width_frac));
    
    % Write to file
    fprintf(fileID, "%.32f\n", data_fp);
else
    % Convert to fixed point
    data_fp_i = cast(real(data), 'like', fi([], true, fp_width, fp_width_frac));
    data_fp_q = cast(imag(data), 'like', fi([], true, fp_width, fp_width_frac));
    
    % Write to file
    fprintf(fileID, "%.32f, %.32f\n", data_fp_i, data_fp_q);
end

fclose(fileID);


status = true;
end
