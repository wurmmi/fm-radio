function y = loadFile(filename)
%  y = loadFile(filename)
%
% reads complex samples from the RTL-SDR file
%

% Read binary
fid = fopen(filename,'rb');

% Convert from uint8 to double in signed range
y = fread(fid,'uint8=>double');
y = y-127.5;

% Convert interleaved I/Q values to complex values
y = y(1:2:end) + 1j*y(2:2:end);
