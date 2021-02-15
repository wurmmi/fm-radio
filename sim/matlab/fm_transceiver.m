%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File   : fm_transceiver.m
% Author : Michael Wurm <wurm.michael95@gmail.com>
% Topic  : FM-Radio Sender and Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare environment
clear; close all; clc;
%restoredefaultpath;

addpath(genpath('./helpers/auto-arrange-figs/'));

%% Settings
% Channel
fc_oe3_Hz = 98.1e6;

% Simulation Options
EnableTrafficInfoTrigger = false;
EnableAudioReplay        = false;

n_sec = 2;
fs_Hz = 500e3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Audio stream data
% TODO: read this from a file
tn = 0:1:n_sec*fs_Hz-1;

audioFreqL_Hz = 400;
audioDataL   = 1 * sin(2*pi*audioFreqL_Hz/fs_Hz*tn);

audioFreqR_Hz = 500;
audioDataR   = 1 * sin(2*pi*audioFreqR_Hz/fs_Hz*tn);

audioData = audioDataL + audioDataR;
% TODO: upsample (44.1k -> fs), then used upsampled freq (fs) for following tones

%% 19kHz pilot tone

pilotFreq_Hz = 19000;
pilotTone = 0.25 * sin(2*pi*pilotFreq_Hz/fs_Hz*tn);

%% Difference signal (for stereo)

audioDiff = audioDataL - audioDataR;

% Modulate it to 38 kHz
carrier4Diff = 1 * sin(2*pi*38e3/fs_Hz*tn);
audioDiffMod = audioDiff .* carrier4Diff;

%% Radio Data Signal (RDS)
% TODO

%% Hinz-Triller (traffic info trigger)
% TODO
% https://de.wikipedia.org/wiki/Autofahrer-Rundfunk-Information#Hinz-Triller
hinzTriller = 0;
if EnableTrafficInfoTrigger
    %TODO
end

%% FM channel
% Sum up all signal parts

fmChannel = audioData + pilotTone + audioDiffMod + hinzTriller;

%% FM channel spectrum

% Downsample
NDown = 1;
fmChannelDown = downsample(fmChannel,NDown);

% FFT
Nfft = 4096*2;
fmChannelSpec = ( abs( fftshift( fft(fmChannelDown,Nfft) )));

fft_freqs = (-Nfft/2:1:Nfft/2-1)*fs_Hz/NDown/Nfft;

% Plot
figure('Name','FM channel spectrum (linear)');
plot(fft_freqs, fmChannelSpec);
grid on;
title('FM channel spectrum (linear)');
xlabel('Hz')
ylabel('magnitude')
xlim([0 65e3])
xline(19e3,'r--','19 kHz');
xline(38e3,'r--','38 kHz');
xline(57e3,'r--','57 kHz');


%% Arrange all plots on the display
autoArrangeFigures(2,2,1);


