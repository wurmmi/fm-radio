%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%FM-Radio Thesis
%%Topic : FM-Radio Demodulator
%%Name  : Michael Wurm
%%Date  : 11/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare environment
clear; close all; clc;

addpath(genpath('./helpers/auto-arrange-figs/'));

%% FM station info
fc_oe3 = 98.1e6;

%% Load recording
fc    = 98.0e6;
fs    = 1e6;
n_sec = 10;

y = loadFile('fm_record.bin');

assert(size(y,1) == n_sec*fs, ...
    'Recording is corrupted. Expected %d samples, but the file only contains %d.', ...
    n_sec*fs, size(y(:,1)))
n_samples = size(y,1);

%% Plot the entire recorded spectrum
range_s = 0.001;

figure();
freqz(y(1:round(n_samples*range_s)),1,(-4e6:.01e6:4e6),fs);
title('Periodic spectrum')

%% Plot closer around the recorded center frequency
plot_FFT_IQ(y,1,range_s*fs,fs,fc);

len_section = round( length(y)/100   ); % calculate 100 sections
n_overlap   = round( len_section/100 ); % overlap 1%

figure();
spectrogram(y,len_section,n_overlap,(-1.25e6:.02e6:1.25e6),fs,'yaxis');
title('Power Spectrum')

%% Shift the recording from IF down to baseband
delta_f = fc - fc_oe3;
t = (1:length(y))/fs;
y_shifted = y .* exp(-1j*2*pi*delta_f*t)';

plot_FFT_IQ(y_shifted,1,range_s*fs,fs,fc_oe3);

%% Demodulate FM
y_fm_demod = FM_IQ_Demod(y_shifted);
plot_FFT_IQ(y_fm_demod,1,20*range_s*fs,fs,0,'Spectrum of demodulated signal');

%% Decimate again for replay on PCs' audio sound card
dec_factor_audio = 20;
fs_dec_audio = fs / dec_factor_audio;

y_fm_demod_dec = decimate(y_fm_demod,dec_factor_audio,'fir');

plot_FFT_IQ(y_fm_demod_dec,1,20*range_s*fs_dec_audio,fs_dec_audio,0,'Spectrum of demod+dec signal');

sound(y_fm_demod_dec, fs_dec_audio);

%% Arrange all plots on the display
autoArrangeFigures(4,4,1);
