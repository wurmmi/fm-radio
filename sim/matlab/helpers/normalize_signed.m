%-------------------------------------------------------------------------
% File        : normalize_plusminus1.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Normalizes signed data to +-1.
%-------------------------------------------------------------------------

function norm_value = normalize_signed(data)
% Normalise values of an array to be between -1 and 1
% original sign of the array values is maintained.
if abs(min(data)) > max(data)
      max_range_value = abs(min(data));
      min_range_value = min(data);
  else
      max_range_value = max(data);
      min_range_value = -max(data);
  end
norm_value = 2 .* data ./ (max_range_value - min_range_value);
end
