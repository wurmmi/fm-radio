%-------------------------------------------------------------------------
% File        : normalize_signed.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Normalizes signed data to +-1.
%-------------------------------------------------------------------------

function normalized_data = normalize_signed(data)
% Normalize values of an array to be between -1 and 1
% original sign of the array values is maintained.
if abs(min(data)) > max(data)
    max_range_value = abs(min(data));
    min_range_value = min(data);
else
    max_range_value = max(data);
    min_range_value = -max(data);
end

normalized_data = 2 .* data ./ (max_range_value - min_range_value);

end
