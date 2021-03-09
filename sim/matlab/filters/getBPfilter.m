%-------------------------------------------------------------------------
% File        : getBPfilter.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Design (or load) an equiripple FIR bandpass filter
%               of minimum order.
%-------------------------------------------------------------------------

function [filter_coeff] = getBPfilter(filename, rp, rs, fco, fs, showGUI)
%getLPfilter Design (or load) an equiripple FIR bandpass filter of minimum order.
%   filename ... filename of stored filter
%   rp       ... Passband ripple in dB
%   rs       ... Stopband ripple in dB
%   fco      ... Cutoff frequencies
%   fs       ... Sampling frequency
%   showGUI  ... Use fvtool to show the filter in a GUI

if isRunningInOctave()
    fprintf("Running in GNU Octave - loading filter '%s' from folder!", filename);
    filter_coeff = load(filename);
else
    m = [0 1 0];    % Stop/Pass/Stop-band
    
    % Convert ripple from dB to linear units
    dev = [10^(-rs/20) (10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
    
    % Design the filter
    filter_coeff = getMinOrderFIR(fco, m, dev, fs, showGUI);
    
    % Save the filter coefficients
    save(filename,'filter_coeff','-ascii');
end
end
