%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File   : fm_transceiver.m
% Author : Michael Wurm <wurm.michael95@gmail.com>
% Topic  : FM-Radio Sender and Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare environment
clear; close all; clc;

addpath(genpath('./helpers/auto-arrange-figs/'));

%% Settings

% Simulation Options
EnableTrafficInfoTrigger = false;
EnableAudioReplay        = false;
EnableAudioFromFile      = false;

% Signal parameters
n_sec = 2;
osr   = 20;
fs_Hz = 44.1e3 * osr;

% Channel
fc_oe3_Hz = 98.1e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Audio stream data

if EnableAudioFromFile
    fs_file = 44.1e3;
    n_sec_offset = 0.15;
    
    [fileDataAll,Fs] = audioread('./recordings/left-right-test.mp3');
    if Fs ~= fs_file
        error("Unexpected sample frequency of file!");
    end
    
    % Select area of interest
    fileData = fileDataAll(round(n_sec_offset*fs_file):round((n_sec_offset+n_sec)*fs_file)-1,:);
    
    % Upsample
    fileData = resample(fileData, osr, 1);
    
    % Split/Combine left and right channel
    audioDataL = fileData(:,1);
    audioDataR = fileData(:,2);
    
    audioData = audioDataL + audioDataR;
    
    tn = (0:1:length(audioData)-1)';
else
    tn = (0:1:n_sec*fs_Hz-1)';

    audioFreqL_Hz = 400;
    audioDataL    = 1 * sin(2*pi*audioFreqL_Hz/fs_Hz*tn);
    
    audioFreqR_Hz = 500;
    audioDataR    = 1 * sin(2*pi*audioFreqR_Hz/fs_Hz*tn);
    
    audioData = audioDataL + audioDataR;
end

%% 19kHz pilot tone

pilotFreq_Hz = 19000;
pilotTone = 0.25 * sin(2*pi*pilotFreq_Hz/fs_Hz*tn);

%% Difference signal (for stereo)

audioDiff = audioDataL - audioDataR;

% Modulate it to 38 kHz
carrier4Diff = 1 * sin(2*pi*38e3/fs_Hz*tn);
audioLRDiffMod = audioDiff .* carrier4Diff;

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

tx_fmChannel = audioData + pilotTone + audioLRDiffMod + hinzTriller;

%% FM channel spectrum

% FFT
Nfft = 4096;
fmChannelSpec = ( abs( fftshift( fft(tx_fmChannel,Nfft) )));
fft_freqs = (-Nfft/2:1:Nfft/2-1)*fs_Hz/Nfft;

% Welch PSD over entire audio file
[psxx, psxx_f] = pwelch(tx_fmChannel, hanning(4096), 2048, 4096, fs_Hz);
psxx_dB = 10*log10(psxx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create output folder to save figures
outputDir = "./matlab_output/";
if ~exist(outputDir, 'dir')
    mkdir(outputDir)
end

figure('Name','Audio file time domain signal');
subplot(2,1,1);
title('Audio file time domain signal');
plot(tn/fs_Hz, audioDataL, 'r', 'DisplayName', 'audioDataL');
grid on;
legend();
subplot(2,1,2);
plot(tn/fs_Hz, audioDataR, 'g', 'DisplayName', 'audioDataR');
grid on;
legend();

figure('Name','TX Time domain signal');
grid on; hold on;
plot(tn/fs_Hz, audioData,     'r', 'DisplayName', 'audioData');
plot(tn/fs_Hz, pilotTone,     'm', 'DisplayName', 'pilotTone');
plot(tn/fs_Hz, audioLRDiffMod,'k', 'DisplayName', 'audioLRDiffMod');
plot(tn/fs_Hz, tx_fmChannel,  'b','DisplayName', 'Total');
title('Time domain signal');
xlabel('time [s]');
ylabel('amplitude');
legend();
xlim([0 inf]);
saveas(gcf, outputDir + "tx_time_domain.png");

figure('Name','FM channel spectrum (linear)');
grid on; hold on;
xline(19e3,'r--','19 kHz');
xline(38e3,'r--','38 kHz');
xline(57e3,'r--','57 kHz');
%plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
plot(psxx_f, psxx,           'b', 'DisplayName', 'Welch PSD');
title('FM channel spectrum (linear)');
xlabel('frequency [Hz]');
ylabel('magnitude');
xlim([0 65e3]);
saveas(gcf, outputDir + "tx_freq_domain.png");


%% Arrange all plots on the display
autoArrangeFigures(2,2,1);


