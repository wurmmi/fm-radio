%-------------------------------------------------------------------------
% File        : isRunningInOctave.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Returns true, if running in GNU Octave. 
%               Returns false otherwise.
%-------------------------------------------------------------------------

function result = isRunningInOctave()
%isRunningInOctave - Returns true, if running in GNU Octave. Returns false otherwise.

result = exist('OCTAVE_VERSION', 'builtin') ~= 0;

end
