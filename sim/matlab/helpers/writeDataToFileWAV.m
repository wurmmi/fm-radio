%-------------------------------------------------------------------------
% File        : writeDataToFileWAV.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes data to a file.
%-------------------------------------------------------------------------

function status = writeDataToFileWAV(data, fs, filename)
%writeDataToFileWAV - Writes data to file.
%   data     ... data to be written
%   fs       ... sample rate
%   filename ... filename

% Split data
data_real = real(data);
data_imag = imag(data);

% Scale data to int16
data_real = int16(data_real*2^15);
data_imag = int16(data_imag*2^15);

fileAudioData = zeros(length(data),2);  % create empty data buffer for 2 channels
fileAudioData(:,1) = data_real;         % real data in Left channel
fileAudioData(:,2) = data_imag;         % imag data in Right channel

audiowrite(filename, fileAudioData, fs);

status = true;
end
