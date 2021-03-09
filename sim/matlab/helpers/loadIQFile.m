%-------------------------------------------------------------------------
% File        : loadIQFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Loads IQ data from a recorded binary file.
%-------------------------------------------------------------------------

function y = loadIQFile(filename)

%
%  y = loadIQFile(filename)
%
% reads complex samples from the RTL-SDR file
%

% Read binary
fid = fopen(filename,'rb');
if fid == -1
  assert(false, sprintf("Could not find file '%s'!", filename));
end

% Convert from uint8 to double in signed range
y = fread(fid,'uint8=>double');
y = y-127.5;

% Convert interleaved I/Q values to complex values
y = y(1:2:end) + 1j*y(2:2:end);