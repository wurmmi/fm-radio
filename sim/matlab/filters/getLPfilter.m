%-------------------------------------------------------------------------
% File        : getLPfilter.m
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

m = [1 0];      % Pass/Stop-band

% Convert ripple from dB to linear units
dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];

% Design the filter
filter_coeff = getMinOrderFIR(fco, m, dev, fs, showGUI);
end
