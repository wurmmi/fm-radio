%-------------------------------------------------------------------------
% File        : loadFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Loads audio data (recorded from IP, or created by Matlab).
%-------------------------------------------------------------------------

function y = loadFile(filename, filetype)
% y = loadFile(filename, filetype)
%   filename ... filename to be read
%   filetype ... [IP, Matlab]

% Open file
fid = fopen(filename,'rb');
if fid == -1
    assert(false, sprintf("Could not find file '%s'!", filename));
end

if filetype == "IP"
  y_int32 = fread(fid,'int32=>int32');
  
  % Split 32 bit into 2x16 bit (left and right channel)
    y_int16 = typecast(y_int32,'int16');
    
    % Convert to double and scale with 16 bit (2.14 fixed point format!)
    y_double = double(y_int16)/2^14;

    % Interleaved left/right
    left  = y_double(1:2:end);
    right = y_double(2:2:end);
    y(:,1) = left; 
    y(:,2) = right; 

elseif filetype == "Matlab"
  y = fscanf(fid,"%f\n");
else
    error('unknown file type %s',filetype);
end

fclose(fid);
