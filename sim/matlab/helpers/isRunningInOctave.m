%-------------------------------------------------------------------------
% File        : isOctave.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM-Radio Sender and Receiver
%-------------------------------------------------------------------------

function result = isRunningInOctave()
%isOctave - Returns true, if running in GNU Octave. Returns false otherwise.

result = exist('OCTAVE_VERSION', 'builtin') ~= 0;

end
