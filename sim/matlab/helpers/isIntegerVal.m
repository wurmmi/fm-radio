%-------------------------------------------------------------------------
% File        : isIntegerVal.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Returns whether a value is an integer.
%-------------------------------------------------------------------------

function result = isIntegerVal(x)
%isIntegerVal - Returns whether a value is an integer.
%   x ... the value

result = mod(x, 1) == 0;

end
