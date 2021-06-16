%-------------------------------------------------------------------------
% File        : writeDataToFileWAV.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes data to a file.
%-------------------------------------------------------------------------

function status = writeDataToFileWAV(data, fs, filedir, filename, fp_config)
%writeDataToFileWAV - Writes data to file.
%   data                 ... data to be written
%   fs                   ... sample rate
%   filedir              ... directory where to store the VHDL file
%   filename             ... filename
%   fp_config.width      ... fixed point data width
%   fp_config.width_frac ... fixed point data width of fractional part


% Split data
data_real = real(data);
data_imag = imag(data);

% Get maximum before scaling
max_real_before = max(data_real);
max_imag_before = max(data_imag);

% Scale data to int16
data_real = int16(data_real*2^fp_config.width_frac);
data_imag = int16(data_imag*2^fp_config.width_frac);

% Check maximum after scaling
max_real_scaled = max(data_real);
max_imag_scaled = max(data_imag);

if ((max_real_scaled > 2^fp_config.width_frac) || ...
    (max_imag_scaled > 2^fp_config.width_frac))
    fprintf("ERROR in WAV: values of '%s' exceeding maximum bitwidth!\n", filename);
    fprintf("REAL before scaling: %f, after scaling %d\n", max_real_before, max_real_scaled);
    fprintf("IMAG before scaling: %f, after scaling %d\n", max_imag_before, max_imag_scaled);
end

fileAudioData = zeros(length(data),2,'int16');  % create empty data buffer for 2 channels
fileAudioData(:,1) = data_imag;                 % imag data in Left channel
fileAudioData(:,2) = data_real;                 % real data in Right channel

filename = sprintf('%s/%s.wav', filedir, filename);
audiowrite(filename, fileAudioData, fs,'BitsPerSample',16);

status = true;
end
