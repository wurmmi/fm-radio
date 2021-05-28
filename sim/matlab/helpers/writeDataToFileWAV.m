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

fprintf('before\n');
fprintf('max(data_real): %f\n', max(data_real));
fprintf('max(data_imag): %f\n', max(data_imag));

% Scale data to int16
data_real = int16(data_real*2^14);
data_imag = int16(data_imag*2^14);

fprintf('after\n');
fprintf('max(data_real): %f\n', max(data_real));
fprintf('max(data_imag): %f\n', max(data_imag));

fileAudioData = zeros(length(data),2,'int16');  % create empty data buffer for 2 channels
fileAudioData(:,1) = data_real;                 % real data in Left channel
fileAudioData(:,2) = data_imag;                 % imag data in Right channel

audiowrite(filename, fileAudioData, fs,'BitsPerSample',16);

status = true;
end
