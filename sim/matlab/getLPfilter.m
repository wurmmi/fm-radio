%-------------------------------------------------------------------------
% File        : getLowPassfilter.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Design an equiripple FIR lowpass filter of minimum order.
%-------------------------------------------------------------------------

function [filter_coeff] = getLPfilter(rp, rs, fco, fs, showGUI)
%getLPfilter Design an equiripple FIR lowpass filter of minimum order.
%   rp      ... Passband ripple in dB
%   rs      ... Stopband ripple in dB
%   fco     ... Cutoff frequencies
%   fs      ... Sampling frequency
%   showGUI ... Use fvtool to show the filter in a GUI

m = [1 0];  % Pass/Stop-band

% Convert ripple from dB to linear units
dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];

% Estimate the minimum filter order for the given specification
[n_lp,fo,ao,wLp] = firpmord(fco,m,dev,fs);

% NOTE: Group delay needs to be an integer.
%       Therefore, the filter order needs to be odd,
%       according to the formula: groupdelay = (N-1)/2
while mod(n_lp,2) ~= 0
    % Increase filter order, which fixes the group delay.
    % The only side effect of this is positive - it increases
    % the filters' accuracy.
    n_lp = n_lp + 1;
end

% Design the filter
filter_lp = firpm(n_lp,fo,ao,wLp);

if showGUI
    fvtool(filter_lp);
end

filter_coeff = filter_lp;
end
