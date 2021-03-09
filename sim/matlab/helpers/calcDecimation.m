%-------------------------------------------------------------------------
% File        : calcDecimation.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Returns decimated/downsampled signal.
%-------------------------------------------------------------------------

function signal_down = calcDecimation(x, rate, manual)
%calcDecimation - Decimates/Downsamples a signal.
%   x      ... signal to be decimated/downsampled
%   rate   ... downsampling rate
%   manual ... Downsampling 'manually' with own decimation filter.
%              Otherwise, the Matlab built-in 'resample' is used.

assert(rate > 0 && isIntegerVal(rate), "rate must be a positive integer!");

if manual
    % Low-pass filter
    filter_dec_N = 30;
    filter_dec = fir1(filter_dec_N, 1/rate);
    
    signal_filt = filter(filter_dec,1, x);
    
    % Downsample (take every nth sample)
    signal_down = signal_filt(1:rate:end);
else
    % Option 1
    signal_down = resample(x, 1, rate);
    
    % Option 2
    %signal_down = decimate(x, rate, 'fir');
end

end
