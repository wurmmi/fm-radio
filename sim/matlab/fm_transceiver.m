%-------------------------------------------------------------------------
% File        : fm_transceiver.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM-Radio Sender and Receiver
%-------------------------------------------------------------------------

%TODO: find places, where power is attenuated --> Tx and Rx should be equal
%      --> only amplify at a single place (at the receiver input)
%TODO: try to lower computation time 

%% Prepare environment
clear; close all; clc;

addpath(genpath('./helpers/'));
addpath(genpath('./filters/'));

%% Settings

% Paths
dir_filters = "./filters/";
dir_output = "./matlab_output/";

% Simulation options
EnableAudioReplay        = true;
EnableTrafficInfoTrigger = false;
EnableAudioFromFile      = true;
EnableFilterAnalyzeGUI   = false;

% Signal parameters
n_sec = 1.7;  % 1.7s is "left channel, right channel" in audio file
osr   = 22;
fs    = 44.1e3 * osr;

% Channel
fc_oe3 = 98.1e4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Audio stream data

if EnableAudioFromFile
    fs_file = 44.1e3;
    
    [fileDataAll,fileFsRead] = audioread('./recordings/left-right-test.wav');
    if fileFsRead ~= fs_file
        error("Unexpected sample frequency of file!");
    end
    
    % Select area of interest (skip silence at beginning of file)
    n_sec_offset = 0.15;
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

fmChannelData = audioData + pilotTone + audioLRDiffMod + hinz_triller;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FM Modulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Upsample
osr_mod = 10;
fmChannelDataUp = resample(fmChannelData, osr_mod, 1);
fs_mod = fs*osr_mod;
tn_mod = (0:1:n_sec*fs_mod-1).';

% FM modulator
fm_delta_f = 100e3; % channel bandwidth
fm_fmax    = 57e3;  % max. frequency in fmChannelData

fm_modindex = fm_delta_f / fm_fmax;

fmChannelDataInt = cumsum(fmChannelDataUp) / fs_mod;
tx_fm = cos(2*pi*fc_oe3/fs_mod*tn_mod + (2*pi*fm_delta_f*fmChannelDataInt));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Channel (AWGN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

awgn = 0;
tx_fm_awgn = tx_fm + awgn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 'Analog' frontend
% -- Direct down-conversion (DDC) to baseband with a complex mixer (IQ)
% -- Lowpass filter the spectral replicas at multiple of fc
% -- ADC: sample with fs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Receive
rx_fm = tx_fm_awgn;

% Complex baseband mixer
rx_fm_i  = rx_fm .*  cos(2*pi*fc_oe3/fs_mod*tn_mod);
rx_fm_q  = rx_fm .* -sin(2*pi*fc_oe3/fs_mod*tn_mod);

rx_fm_bb = rx_fm_i + 1j * rx_fm_q;

% Lowpass filter (for spectral replicas)
filter_name = dir_filters + "lowpass_iq_mixer.mat";
if isRunningInOctave()
    warning("Running in GNU Octave - loading lowpass filter from folder!");
    filter_lp_mixer = load(filter_name);
else
    ripple_pass_dB = 0.1;           % Passband ripple in dB
    ripple_stop_db = 50;            % Stopband ripple in dB
    cutoff_freqs   = [120e3 250e3]; % Cutoff frequencies

    filter_lp_mixer = getLPfilter(  ...
        ripple_pass_dB, ripple_stop_db,  ...
        cutoff_freqs, fs_mod, EnableFilterAnalyzeGUI);
    
    % Save the filter coefficients
    save(filter_name,'filter_lp_mixer','-ascii');
end

% Filter
rx_fm_bb = filter(filter_lp_mixer,1, rx_fm_bb);

% ADC (downsample)
rx_fm_bb = resample(rx_fm_bb, 1, osr_mod);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FM De-Modulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Normalize the amplitude (remove amplitude variations)
rx_fm_bb_norm = rx_fm_bb ./ abs(rx_fm_bb);

% Design differentiator
filter_diff = [1,0,-1];

% Demodulate
rx_fm_i = real(rx_fm_bb_norm);
rx_fm_q = imag(rx_fm_bb_norm);

rx_fm_demod =  ...
    (rx_fm_i .* conv(rx_fm_q,filter_diff,'same') -   ...
    rx_fm_q .* conv(rx_fm_i,filter_diff,'same')) ./  ...
    (rx_fm_i.^2 + rx_fm_q.^2);

rx_fmChannelData = rx_fm_demod;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Downsample

osr_rx = 4;
fs_rx  = fs/osr_rx;
rx_fmChannelData = resample(rx_fmChannelData, 1, osr_rx);

%% Filter the mono part

% Create the low pass filter
filter_name = dir_filters + "lowpass_mono.mat";
if isRunningInOctave()
    warning("Running in GNU Octave - loading lowpass filter from folder!");
    filter_lp_mono = load(filter_name);
else
    ripple_pass_dB = 0.1;         % Passband ripple in dB
    ripple_stop_db = 50;          % Stopband ripple in dB
    cutoff_freqs   = [15e3 19e3]; % Cutoff frequencies

    filter_lp_mono = getLPfilter( ...
        ripple_pass_dB, ripple_stop_db, ...
        cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);
    
    % Save the filter coefficients
    save(filter_name,'filter_lp_mono','-ascii');
end

% Filter
rx_audio_mono = filter(filter_lp_mono,1, rx_fmChannelData);

%% Filter the LR-diff-part

% Create the bandpass filter
filter_name = dir_filters + "bandpass_lrdiff.mat";
if isRunningInOctave()
    warning("Running in GNU Octave - loading lowpass filter from folder!");
    filter_lp_mono = load(filter_name);
else
    ripple_pass_dB = 0.1;                   % Passband ripple in dB
    ripple_stop_db = 50;                    % Stopband ripple in dB
    cutoff_freqs   = [19e3 23e3 53e3 57e3]; % Band frequencies (defined like slopes)

    filter_bp_lrdiff = getBPfilter( ...
        ripple_pass_dB, ripple_stop_db, ...
        cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);
    
    % Save the filter coefficients
    save(filter_name,'filter_bp_lrdiff','-ascii');
end

% Filter (Bandpass 23k..53kHz)
rx_audio_lrdiff_bpfilt = filter(filter_bp_lrdiff,1, rx_fmChannelData);

% Modulate down to baseband
tnRx = (0:1:n_sec*fs_rx-1)';
carrier38kHzRx = cos(2*pi*38e3/fs_rx*tnRx);
rx_audio_lrdiff_mod = rx_audio_lrdiff_bpfilt .* carrier38kHzRx;

% Filter (lowpass 15kHz)
rx_audio_lrdiff = filter(filter_lp_mono,1, rx_audio_lrdiff_mod);

% TODO: where does this come from?? Factor 2 = ~3 dB
% NOTE: normalize to 1 before the add/sub
scalefactor = 4.33;
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
    % Create LR audio signal for output
    rx_audioReplay = zeros(length(rx_audio_L),2);
    rx_audioReplay(:,1) = rx_audio_L;
    rx_audioReplay(:,2) = rx_audio_R;

    % Downsample for PC soundcard
    osr_replay = 5;
    fs_audioReplay = fs_rx/osr_replay;
    rx_audioReplay = resample(rx_audioReplay, 1, osr_replay);
    
    sound(rx_audioReplay, fs_audioReplay);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create output folder to save figures
if ~exist(dir_output, 'dir')
    mkdir(dir_output)
end

%% Calculations

% Tx %%%%%%%%%%%%%%%%%%%%%
% FFT
n_fft = 4096;
fmChannelSpec = ( abs( fftshift( fft(fmChannelData,n_fft) )));
fft_freqs = (-n_fft/2:1:n_fft/2-1)*fs/n_fft;

% PSD over entire audio file
welch_size  = 4096*4;
n_overlap   = welch_size / 4;
n_fft_welch = welch_size;
window      = hanning(welch_size);

[psxx_tx, psxx_tx_f]             = pwelch(fmChannelData, window, n_overlap, n_fft_welch, fs);
[psxx_rx_fm_bb, psxx_rx_fm_bb_f] = pwelch(rx_fm_bb, window, n_overlap, n_fft_welch, fs);

% Rx %%%%%%%%%%%%%%%%%%%%%
[psxx_rx_mono, psxx_rx_mono_f]                   = pwelch(rx_audio_mono, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_bpfilt, psxx_rx_lrdiff_bpfilt_f] = pwelch(rx_audio_lrdiff_bpfilt, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_mod, psxx_rx_lrdiff_mod_f]       = pwelch(rx_audio_lrdiff_mod, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff, psxx_rx_lrdiff_f]               = pwelch(rx_audio_lrdiff, window, n_overlap, n_fft_welch, fs_rx);

% Rx (RF) %%%%%%%%%%%%%%%%
welch_size  = 4096*4*osr_mod;
n_overlap   = welch_size / 4;
n_fft_welch = welch_size;
window      = hanning(welch_size);

[psxx_rx_fm, psxx_rx_fm_f] = pwelch(rx_fm, window, n_overlap, n_fft_welch, fs_mod);

%% Plots

fig_title = 'Time domain signal';
fig_audio_time = figure('Name',fig_title);
subplot(6,1,1);
plot(tn/fs, audioDataL, 'r', 'DisplayName', 'audioDataL');
title(fig_title);
grid on; legend();
subplot(6,1,2);
plot(tn/fs, audioDataR, 'g', 'DisplayName', 'audioDataR');
grid on; legend();
subplot(6,1,3);
plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
ylabel('amplitude');
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
grid on; legend();

fig_title = 'Time domain signal (modulated and de-modulated)';
fig_time_mod = figure('Name',fig_title);
grid on; hold on;
plot(tn/fs, fmChannelData,        'b', 'DisplayName', 'fmChannelData (pre-mod)');
plot(tnRx/fs_rx, rx_fmChannelData,'r', 'DisplayName', 'rx\_fmChannelData (demod)');
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

if false
    fig_title = 'FM demodulator';
    fig_time_fm_demodulator = figure('Name',fig_title);
    grid on; hold on;
    plot(tn/fs, rx_fm_bb,        'r', 'DisplayName', 'rx\_fm\_bb');
    plot(tn/fs, rx_fm_bb_norm,   'g', 'DisplayName', 'rx\_fm\_bb\_norm');
    plot(tn/fs, rx_fm_demod_raw, 'b', 'DisplayName', 'rx\_fm\_demod\_raw');
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

if false
    fig_title = 'Time domain signal (to check group delay)';
    fig_adapt_grpdelay_time = figure('Name',fig_title);
    grid on; hold on;
    plot(tnRx/fs_rx, rx_audio_mono,   'r', 'DisplayName', 'rx\_audio\_mono');
    plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

if false
    fig_title = 'Tx time domain signal';
    fig_tx_time = figure('Name',fig_title);
    grid on; hold on;
    plot(tn/fs, fmChannelData, 'b', 'DisplayName', 'Total');
    plot(tn/fs, audioData,     'r', 'DisplayName', 'audioData');
    plot(tn/fs, pilotTone,     'm', 'DisplayName', 'pilotTone');
    plot(tn/fs, audioLRDiffMod,'k', 'DisplayName', 'audioLRDiffMod');
    if EnableTrafficInfoTrigger
        plot(tn/fs, hinz_triller,'g', 'DisplayName', 'hinzTriller');
    end
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    xlim([0 inf]);
    saveas(fig_tx_time, dir_output + "time_tx.png");
end

fig_title = 'Rx channel spectrum complex IQ mixer (linear)';
fig_rx_mod = figure('Name',fig_title);
grid on; hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
xline(fc_oe3, 'k--', 'fc');
h0 = plot(psxx_rx_fm_f, psxx_rx_fm,       'b','DisplayName', 'RxFM');
h1 = plot(psxx_rx_fm_bb_f, psxx_rx_fm_bb, 'r','DisplayName', 'RxFM BB');
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','east');
xlim([0 fc_oe3+fc_oe3/5]);
saveas(fig_rx_mod, dir_output + "psd_iq_mixer.png");

fig_title = 'FM channel spectrum (linear)';
fig_tx_spec = figure('Name',fig_title);
grid on; hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
%plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
h0 = plot(psxx_tx_f, psxx_tx,             'b','DisplayName', 'Tx');
h1 = plot(psxx_rx_fm_bb_f, psxx_rx_fm_bb, 'r','DisplayName', 'Rx');
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','east');
xlim([0 65e3]);
ylimits = ylim();
saveas(fig_tx_spec, dir_output + "psd_rx_tx.png");

fig_title = 'Rx spectrum parts (linear)';
fig_rx_spec = figure('Name',fig_title);
grid on; hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
h0 = plot(psxx_rx_mono_f, psxx_rx_mono,                   'b',  'DisplayName', 'Mono');
h1 = plot(psxx_rx_lrdiff_bpfilt_f, psxx_rx_lrdiff_bpfilt, 'r-.','DisplayName', 'LR Diff bp filtered');
h2 = plot(psxx_rx_lrdiff_mod_f, psxx_rx_lrdiff_mod,       'r',  'DisplayName', 'LR Diff bp filtered and mod');
h3 = plot(psxx_rx_lrdiff_f, psxx_rx_lrdiff,               'g',  'DisplayName', 'LR Diff BB');
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1,h2,h3],'Location','east');
xlim([0 65e3]);
ylim(ylimits);
saveas(fig_rx_spec, dir_output + "psd_rx_parts.png");


%% Arrange all plots on the display
autoArrangeFigures(2,3,2);


