%-------------------------------------------------------------------------
% File        : getEmphasisFilter.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Design (Pre- and De-)Emphasis Filters for FM.
%-------------------------------------------------------------------------

function [filter_coeffs] = getEmphasisFilter(fs, filtType, showGUI)
%getEmphasisFilter
%   fs       ... Sampling frequency
%   filtType ... ['pre','de'] Get pre- or de-emphasis filter.
%   showGUI  ... Use bodeplot to show the filter in a GUI

tau = 50e-6;         % time constant (50µs in Europe, 75us in US)
fc  = 1/(2*pi*tau);  % cut-off frequency

k = fs/(2*pi*fc);

if filtType == "pre"
    filter_coeffs.Denum = [1 0];
    filter_coeffs.Num   = [1+k -k];
elseif filtType == "de"
    filter_coeffs.Num   = [1 0];
    filter_coeffs.Denum = [1+k -k];
else
    error('Check settings.')
end

if showGUI
    emphasis_filter = tf(filter_coeffs.Num, filter_coeffs.Denum, 1/fs);
    figure();
    h = bodeplot(emphasis_filter);
    grid on;
    setoptions(h,'FreqUnits','Hz');
    legend(sprintf("digital %s-emphasis",filtType));
end

end
