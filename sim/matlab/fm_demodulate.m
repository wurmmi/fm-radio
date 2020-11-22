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
f_center = 98.0e6;
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

%% Plot closer around the recorded center frequency
plot_FFT_IQ(y,1,range_s*fs,fs,f_center);

len_section = 200000;
n_overlap = 1500;
%figure();
%spectrogram(y,len_section,n_overlap,[-1.25E6:.02E6:1.25E6],fs,'yaxis');
%title('Power Spectrum')

%% Shift the recording from IF down to baseband
delta_f = f_center - fc_oe3;

y_shifted = y .* exp(-1j*2*pi*delta_f*[1:1:length(y)]/fs)';

plot_FFT_IQ(y_shifted,1,range_s*fs,fs,fc_oe3);

%% Decimate (low-pass filter + decimate)
dec_factor = 4;
fs_dec = fs / dec_factor;
y_dec = decimate(y_shifted,dec_factor,'fir');

plot_FFT_IQ(y_dec,1,10*range_s*fs_dec,fs_dec,fc_oe3,'Spectrum of decimated signal');

%% Demodulate

[y_fm_demod] = FM_IQ_Demod(y_dec);
plot_FFT_IQ(y_fm_demod,1,20*range_s*fs_dec,fs_dec,0,'Spectrum of demodulated signal');


%% Decimate again for replay on PCs' audio sound card
dec_factor_audio = 10;
fs_dec_audio = fs_dec / dec_factor_audio;

y_fm_demod_dec = decimate(y_fm_demod,dec_factor_audio,'fir');

plot_FFT_IQ(y_fm_demod_dec,1,10*range_s*fs_dec_audio,fs_dec_audio,0,'Spectrum of demod+dec signal');

sound(y_fm_demod_dec, fs_dec_audio);


autoArrangeFigures(4,4,1);
