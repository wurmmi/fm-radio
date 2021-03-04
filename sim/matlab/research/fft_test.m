%-------------------------------------------------------------------------
% File        : fft_test.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Learn about FFT ('perfect' resolution)
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

%=========================================================================
%% Settings

% Simulation Options

% Common
osr = 10;
fs  = 300*osr;

n_sec = 0.1;
tn    = (0:1:fs*n_sec).';


%=========================================================================
%% Signal

fmax = 400;

if false
    phi = 30 * pi/180;
    sig1 = 10 * sin(2*pi*100/fs*tn + phi);
    sig2 =  1 * sin(2*pi*200/fs*tn + phi);
    sig3 =  4 * sin(2*pi*400/fs*tn + phi);
    
    signal = sig1 + sig2 + sig3;
else
    sig1 = cos(2*pi*100/fs*tn);

    % Create double freq and "low pass filter by removing the DC content"
    signal = sig1 .* sig1 * 2 - 1;   
    
    signal = signal .* sig1 * 2; % create triple freq
    % TODO: need to HP filter and other delay signals to align
end

%=========================================================================
%% FFT

% Calculations
Nfft      = length(tn)-1;
%Nfft      = 2^(nextpow2(Nfft)-1);
fft_freqs = (-Nfft/2:Nfft/2-1)/(Nfft/fs);

fft_signal_mag = fftshift(fft(signal,Nfft))/Nfft;

% corect 'zero' values
tol_zero = 1e-6;
fft_signal_mag(abs(fft_signal_mag) < tol_zero) = 0;

fft_signal_phase = angle(fft_signal_mag)*180/pi;
fft_signal_phase(abs(fft_signal_phase) < tol_zero) = 0;

%=========================================================================
%% Plots

%-------------------------------------------------------------------------
fig_title = 'Time domain signal';
fig_time_tx = figure('Name',fig_title);
hold on;
plot(tn/fs, signal, 'DisplayName', 'signal');
grid on;
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

%-------------------------------------------------------------------------
fig_title = 'Frequency domain';
fig_freq = figure('Name',fig_title);
sp1 = subplot(2,1,1);
hold on;
h0 = stem(fft_freqs, abs(fft_signal_mag), 'DisplayName', 'magnitude');
grid on;
xlim([-fmax*1.2,fmax*1.2]);
title(fig_title);
xlabel('Frequency [Hz]');
ylabel('magnitude');

sp2 = subplot(2,1,2);
hold on;
h1 = stem(fft_freqs, fft_signal_phase, 'DisplayName', 'phase');
grid on;
xlim([-fmax*1.2,fmax*1.2]);
xlabel('Frequency [Hz]');
ylabel('phase');
linkaxes([sp1,sp2],'x')

%=========================================================================
%% Arrange all plots on the display

if ~isRunningInOctave()
    autoArrangeFigures(2,2,2);
end

disp('Done.');
