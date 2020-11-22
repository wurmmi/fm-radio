%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%FM-Radio Thesis
%%Topic : FM-Radio Demodulator
%%Name  : Michael Wurm
%%Date  : 11/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare environment
clear; close all; clc;

%% Recording
f_center = 97.0e6;
fs = 1e6;
n_seconds = 10;

y = loadFile('fm_record.bin');

assert(size(y,1) == n_seconds*fs, ...
    'Recording is corrupted. Expected %d samples, but the file only contains %d.', n_seconds*fs, size(y(:,1)))
n_samples = size(y,1);

%% Plot the entire recorded spectrum

range_s = 0.001;

figure();
freqz(y(1:round(n_samples*range_s)),1,[-4E6:.01E6:4E6],fs);

%% Plot 2ms of data, at the recorded center frequency
plot_FFT_IQ(y,1,range_s*fs,fs,f_center);

