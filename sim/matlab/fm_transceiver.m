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
EnableTrafficInfoTrigger = false;
EnableAudioFromFile      = true;
EnableFilterAnalyzeGUI   = true;

% Signal parameters
n_sec = 1.7;  % 1.7s is "left channel, right channel"
osr   = 22;
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
    audioDataL = 1 * sin(2*pi*audioFreqL/fs*tn);
    audioDataL(round(end/2):end) = 0; % mute second half
    
    audioFreqR = 400;
    audioDataR = 1 * sin(2*pi*audioFreqR/fs*tn);
    audioDataR(1:round(end/2)) = 0;   % mute first half
    
    audioData = audioDataL + audioDataR;
end

%% 19kHz pilot tone

pilotFreq = 19000;
pilotTone = 0.25 * sin(2*pi*pilotFreq/fs*tn);

%% Difference signal (for stereo)

audioDiff = audioDataL - audioDataR;

% Modulate it to 38 kHz
carrier38kHzTx = 1 * sin(2*pi*38e3/fs*tn);
audioLRDiffMod = audioDiff .* carrier38kHzTx;

%% Radio Data Signal (RDS)
% TODO

%% Hinz-Triller (traffic info trigger)
% https://de.wikipedia.org/wiki/Autofahrer-Rundfunk-Information#Hinz-Triller

hinz_triller = 0;
if EnableTrafficInfoTrigger
    fc_hinz             = 2350;
    f_deviation         = 123;
    hinz_duration_on_s  = 1.2;
    hinz_duration_off_s = 0.5;
    hinz_amplitude      = 1/16;
    
    % Create the 123 Hz Hinz Triller tone and integrate it (for FM modulation)
    t_hinz = (0:1:min(hinz_duration_off_s,n_sec)*fs-1)';
    hinz_tone = sin(2*pi*f_deviation/fs*t_hinz);
    hinz_tone_int = cumsum(hinz_tone)/fs;
    
    % FM modulation (with zero padding at the end, to match signal duration)
    hinz_triller = zeros(1,length(tn))';
    hinz_triller(t_hinz+1) = cos(2*pi*fc_hinz/fs*t_hinz + (2*pi*f_deviation*hinz_tone_int));
    hinz_triller = hinz_amplitude * hinz_triller;
end

%% Combine all signal parts

tx_FM = audioData + pilotTone + audioLRDiffMod + hinz_triller;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: (up-convert to RF, AWGN, down-convert from RF)

tx_FM_channel = tx_FM;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Downsample

fs_rx = fs; %TODO: reduce sample rate here!!
osr_rx = fs/fs_rx;
rx_FM = resample(tx_FM_channel, 1, osr_rx);

%% Filter the mono part

% Create lowpass filter (Equiripple FIR)
rp  = 1;            % Passband ripple in dB
rs  = 50;           % Stopband ripple in dB
fco = [15e3 19e3];  % Cutoff frequencies
m   = [1 0];        % Pass/Stop-band

dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
[n,fo,ao,wLp] = firpmord(fco,m,dev,fs_rx);

% NOTE: Group delay needs to be an integer. Therefore, filter order needs to be odd.
while mod(n,2) ~= 0
    % Increase filter order, which fixes the group delay.
    % The only side effect of this is positive - it increases
    % the filters' accuracy.
    n = n + 1;
end

filter_lp_mono = firpm(n,fo,ao,wLp);
if EnableFilterAnalyzeGUI fvtool(filter_lp_mono); end

% Filter
rx_audio_mono = filter(filter_lp_mono,1, rx_FM);

%% Filter the LR-diff-part

% Create bandpass filter
rp  = 1;                      % Passband ripple in dB
rs  = 50;                     % Stopband ripple in dB
fco = [19e3 23e3 53e3 57e3];  % Band frequencies (defined like slopes)
m   = [0 1 0];                % Stop/Pass/Stop-band

dev = [10^(-rs/20) (10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
[n,fo,ao,wLp] = firpmord(fco,m,dev,fs_rx);
while mod(n,2) ~= 0
    n = n + 1;
end

filter_bp_lrdiff = firpm(n,fo,ao,wLp);
if EnableFilterAnalyzeGUI fvtool(filter_bp_lrdiff); end

% Filter (Bandpass 23k..53kHz)
rx_audio_lrdiff_bpfilt = filter(filter_bp_lrdiff,1, rx_FM);

% Modulate down to baseband
tnRx = (0:1:length(rx_audio_lrdiff_bpfilt)-1)';
carrier38kHzRx = sin(2*pi*38e3/fs_rx*tnRx);
rx_audio_lrdiff_mod = rx_audio_lrdiff_bpfilt .* carrier38kHzRx;

% Filter (lowpass 15kHz)
rx_audio_lrdiff = filter(filter_lp_mono,1, rx_audio_lrdiff_mod);

% TODO: where does this come from?? Factor 2 = ~3 dB
scalefactor = 2.33;
rx_audio_lrdiff = rx_audio_lrdiff * scalefactor;

%% Combine received signal
% L = (L+R) + (L-R) = (2)L
% R = (L+R) - (L-R) = (2)R
% where (L+R) = mono, and (L-R) is lrdiff

% Delay the mono signal to match the lrdiff signal
% NOTE: The mono signal only needs to pass through a single LP.
%       The lrdiff signal passed through a BP and a LP. Thus, it needs to
%       be delayed by the BP's groupdelay, since the LP is the same.
bp_groupdelay = filtord(filter_bp_lrdiff)/2+1;

% Compensate the group delay
rx_audio_mono = [zeros(bp_groupdelay,1); rx_audio_mono(1:end-bp_groupdelay)];

rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio replay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableAudioReplay
    fs_audioReplay = 44.1e3;
    osr_replay = fs_rx/fs_audioReplay;
    
    % Create LR audio signal for output
    rx_audioReplay = zeros(length(rx_audio_L),2);
    rx_audioReplay(:,1) = rx_audio_L;
    rx_audioReplay(:,2) = rx_audio_R;
    
    rx_audioReplay = resample(rx_audioReplay, 1, osr_replay);
    
    sound(rx_audioReplay, fs_audioReplay);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create output folder to save figures
outputDir = "./matlab_output/";
if ~exist(outputDir, 'dir')
    mkdir(outputDir)
end

%% Calculations

% Tx %%%%%%%%%%%%%%%%%%%%%
% FFT
n_fft = 4096;
fmChannelSpec = ( abs( fftshift( fft(tx_FM,n_fft) )));
fft_freqs = (-n_fft/2:1:n_fft/2-1)*fs/n_fft;

% PSD over entire audio file
welch_size  = 4096;
n_overlap   = welch_size / 4;
n_fft_welch = welch_size;
window      = hanning(welch_size);

[psxx_tx, psxx_tx_f] = pwelch(tx_FM, window, n_overlap, n_fft_welch, fs);
psxx_tx_dB = 10*log10(psxx_tx);

% Rx %%%%%%%%%%%%%%%%%%%%%
[psxx_rx_mono, psxx_rx_mono_f] = pwelch(rx_audio_mono, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_bpfilt, psxx_rx_lrdiff_bpfilt_f] = pwelch(rx_audio_lrdiff_bpfilt, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_mod, psxx_rx_lrdiff_mod_f] = pwelch(rx_audio_lrdiff_mod, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff, psxx_rx_lrdiff_f] = pwelch(rx_audio_lrdiff, window, n_overlap, n_fft_welch, fs_rx);

%% Plots

fig_audio_time = figure('Name','Audio file time domain signal');
subplot(6,1,1);
plot(tn/fs, audioDataL, 'r', 'DisplayName', 'audioDataL');
title('Audio file time domain signal');
grid on; legend();
subplot(6,1,2);
plot(tn/fs, audioDataR, 'g', 'DisplayName', 'audioDataR');
grid on; legend();
subplot(6,1,3); hold on;
plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
grid on; legend();
subplot(6,1,4);
plot(tnRx/fs_rx, rx_audio_mono, 'b', 'DisplayName', 'rx\_audio\_mono');
grid on; legend();
subplot(6,1,5);
plot(tnRx/fs_rx, rx_audio_L, 'r', 'DisplayName', 'rx\_audio\_L');
grid on; legend();
subplot(6,1,6);
plot(tnRx/fs_rx, rx_audio_R, 'g', 'DisplayName', 'rx\_audio\_R');
xlabel('time [s]');
ylabel('amplitude');
grid on; legend();

if false
    fig_adapt_grpdelay_time = figure('Name','Audio time domain signal (adapt group delay)');
    grid on; hold on;
    plot(tnRx/fs_rx, rx_audio_mono, 'r', 'DisplayName', 'rx\_audio\_mono');
    plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    
    fig_tx_time = figure('Name','Tx time domain signal');
    grid on; hold on;
    plot(tn/fs, tx_FM,  'b','DisplayName', 'Total');
    plot(tn/fs, audioData,     'r', 'DisplayName', 'audioData');
    plot(tn/fs, pilotTone,     'm', 'DisplayName', 'pilotTone');
    plot(tn/fs, audioLRDiffMod,'k', 'DisplayName', 'audioLRDiffMod');
    if EnableTrafficInfoTrigger
        plot(tn/fs, hinz_triller,  'g', 'DisplayName', 'hinzTriller');
    end
    title('Tx time domain signal');
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    xlim([0 inf]);
    saveas(fig_tx_time, outputDir + "tx_time_domain.png");
end

fig_tx_spec = figure('Name','Tx channel spectrum (linear)');
grid on; hold on;
xline(19e3,'r--','19 kHz');
xline(38e3,'r--','38 kHz');
xline(57e3,'r--','57 kHz');
%plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
h0 = plot(psxx_tx_f, psxx_tx, 'b', 'DisplayName', 'Total');
legend([h0]);
title('Tx FM channel spectrum (linear)');
xlabel('frequency [Hz]');
ylabel('magnitude');
xlim([0 65e3]);
ylimits = ylim();
saveas(fig_tx_spec, outputDir + "tx_freq_domain.png");

fig_rx_spec = figure('Name','Rx channel spectrum (linear)');
grid on; hold on;
xline(19e3,'r--','19 kHz');
xline(38e3,'r--','38 kHz');
xline(57e3,'r--','57 kHz');
h0 = plot(psxx_rx_mono_f, psxx_rx_mono,                   'b',  'DisplayName', 'Mono');
h1 = plot(psxx_rx_lrdiff_bpfilt_f, psxx_rx_lrdiff_bpfilt, 'r--','DisplayName', 'LR Diff bp filtered');
h2 = plot(psxx_rx_lrdiff_mod_f, psxx_rx_lrdiff_mod,       'r',  'DisplayName', 'LR Diff bp filtered and mod');
h3 = plot(psxx_rx_lrdiff_f, psxx_rx_lrdiff,               'g',  'DisplayName', 'LR Diff BB');
title('Rx FM channel spectrum (linear)');
xlabel('frequency [Hz]');
ylabel('magnitude');
xlim([0 65e3]);
ylim(ylimits);
legend([h0,h1,h2,h3]);
saveas(fig_rx_spec, outputDir + "tx_freq_domain.png");


%% Arrange all plots on the display
autoArrangeFigures(2,2,1);


