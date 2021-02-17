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
EnableAudioReplay        = true;
EnableTrafficInfoTrigger = true;
EnableAudioFromFile      = true;

% Signal parameters
n_sec = 2;  % 1.7s is "left channel, right channel"
osr   = 20;
fs    = 44.1e3 * osr;

% Channel
fc_oe3 = 98.1e6;

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
    tn = (0:1:n_sec*fs-1)';
    
    audioFreqL = 400;
    audioDataL    = 1 * sin(2*pi*audioFreqL/fs*tn);
    
    audioFreqR = 500;
    audioDataR    = 1 * sin(2*pi*audioFreqR/fs*tn);
    
    audioData = audioDataL + audioDataR;
end

%% 19kHz pilot tone

pilotFreq = 19000;
pilotTone = 0.25 * sin(2*pi*pilotFreq/fs*tn);

%% Difference signal (for stereo)

audioDiff = audioDataL - audioDataR;

% Modulate it to 38 kHz
carrier4Diff = 1 * sin(2*pi*38e3/fs*tn);
audioLRDiffMod = audioDiff .* carrier4Diff;

%% Radio Data Signal (RDS)
% TODO

%% Hinz-Triller (traffic info trigger)
% TODO
% https://de.wikipedia.org/wiki/Autofahrer-Rundfunk-Information#Hinz-Triller
hinz_triller = 0;
if EnableTrafficInfoTrigger
    fc_hinz             = 2350;
    f_deviation         = 123;
    hinz_duration_on_s  = 1.2;
    hinz_duration_off_s = 0.5;
    
    % Create the 123 Hz Hinz Triller tone and integrate it (for FM modulation)
    t_hinz = (0:1:min(hinz_duration_off_s,n_sec)*fs-1)';
    hinz_tone = sin(2*pi*f_deviation/fs*t_hinz);
    hinz_tone_int = cumsum(hinz_tone)/fs;
    
    % FM modulation with zero padding at the end
    hinz_triller = zeros(1,length(tn))';
    hinz_triller(t_hinz+1) = cos(2*pi*fc_hinz/fs*t_hinz + (2*pi*f_deviation*hinz_tone_int));
    
    if false
        hinzTriller2 = fmmod(hinz_tone, fc_hinz, fs, f_deviation);
        
        figure();
        subplot(2,1,1);
        plot(t_hinz,hinz_tone); hold on;
        plot(t_hinz,hinz_tone_int, 'r');
        ylabel('amplitude');xlabel('time index');title('Modulating signal');
        subplot(2,1,2);
        plot(tn,hinz_triller,       'DisplayName','hinzTriller'); hold on;
        plot(t_hinz,hinzTriller2, 'r', 'DisplayName','hinzTriller2');
        legend();
        ylabel('amplitude');xlabel('time index');title('Frequency modulated signal');
    end
end

%% FM channel
% Sum up all signal parts

tx_fmChannel = audioData + pilotTone + audioLRDiffMod + hinz_triller;

%% FM channel spectrum

% FFT
n_fft = 4096;
fmChannelSpec = ( abs( fftshift( fft(tx_fmChannel,n_fft) )));
fft_freqs = (-n_fft/2:1:n_fft/2-1)*fs/n_fft;

% Welch PSD over entire audio file
welch_size  = 4096;
n_overlap   = welch_size / 4;
n_fft_welch = welch_size;

window = hanning(welch_size);
[psxx, psxx_f] = pwelch(tx_fmChannel, window, n_overlap, n_fft_welch, fs);
psxx_dB = 10*log10(psxx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




if EnableAudioReplay
    audioReplay = resample(tx_fmChannel, 1, osr);
    
    fs_audioReplay = fs/osr;
    sound(audioReplay,fs_audioReplay);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create output folder to save figures
outputDir = "./matlab_output/";
if ~exist(outputDir, 'dir')
    mkdir(outputDir)
end

fig0 = figure('Name','Audio file time domain signal');
subplot(2,1,1);
title('Audio file time domain signal');
plot(tn/fs, audioDataL, 'r', 'DisplayName', 'audioDataL');
grid on;
legend();
subplot(2,1,2);
plot(tn/fs, audioDataR, 'g', 'DisplayName', 'audioDataR');
grid on;
legend();

fig1 = figure('Name','TX Time domain signal');
grid on; hold on;
plot(tn/fs, tx_fmChannel,  'b','DisplayName', 'Total');
plot(tn/fs, audioData,     'r', 'DisplayName', 'audioData');
plot(tn/fs, pilotTone,     'm', 'DisplayName', 'pilotTone');
plot(tn/fs, audioLRDiffMod,'k', 'DisplayName', 'audioLRDiffMod');
if EnableTrafficInfoTrigger
    plot(tn/fs, hinz_triller,  'g', 'DisplayName', 'hinzTriller');
end
title('Time domain signal');
xlabel('time [s]');
ylabel('amplitude');
legend();
xlim([0 inf]);
saveas(fig1, outputDir + "tx_time_domain.png");

fig2 = figure('Name','FM channel spectrum (linear)');
grid on; hold on;
xline(19e3,'r--','19 kHz');
xline(38e3,'r--','38 kHz');
xline(57e3,'r--','57 kHz');
%plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
plot(psxx_f, psxx,             'b', 'DisplayName', 'Welch PSD');
title('FM channel spectrum (linear)');
xlabel('frequency [Hz]');
ylabel('magnitude');
xlim([0 65e3]);
saveas(fig2, outputDir + "tx_freq_domain.png");


%% Arrange all plots on the display
autoArrangeFigures(2,2,1);


