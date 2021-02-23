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

% Octave
if isRunningInOctave()
  % Define xline function
  %xline = @(xval, varargin) line([xval xval], ylim, varargin{:});
  xline = @(xval) line([xval xval], ylim, 'color','black','linestyle','--');
end

%% Settings

% Paths
dir_filters = "./filters/";
dir_output  = "./matlab_output/";

% Simulation options
EnableSenderSourceRecordedFile = true;
EnableSenderSourceCreateSim    = false;
EnableTrafficInfoTrigger       = false;
EnableAudioFromFile            = true;

EnableRxAudioReplay    = true;
EnableFilterAnalyzeGUI = false;

% Signal parameters
n_sec = 2;             % 1.7s is "left channel, right channel" in audio file
osr   = 22;            % oversampling rate for fs
fs    = 44.1e3 * osr;  % sampling rate fs

% Channel
fc_oe3 = 98.1e4;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Common
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tn = (0:1:n_sec*fs-1)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_sender();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FM Demodulator ================================================

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

%% Channel decoder ===============================================

%% Downsample

osr_rx = 4;
fs_rx  = fs/osr_rx;
rx_fmChannelData = resample(rx_fmChannelData, 1, osr_rx);

%% Filter the mono part

% Create the low pass filter
filter_name = sprintf("%s%s",dir_filters,"lowpass_mono.mat");
if isRunningInOctave()
    disp("Running in GNU Octave - loading lowpass filter from folder!");
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
filter_name = sprintf("%s%s",dir_filters,"bandpass_lrdiff.mat");
if isRunningInOctave()
    disp("Running in GNU Octave - loading lowpass filter from folder!");
    filter_bp_lrdiff = load(filter_name);
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
bp_groupdelay = (length(filter_bp_lrdiff)-1)/2;

% Compensate the group delay
rx_audio_mono = [zeros(bp_groupdelay,1); rx_audio_mono(1:end-bp_groupdelay)];

rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio replay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRxAudioReplay    
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
if EnableSenderSourceCreateSim
    n_fft = 4096;
    fmChannelSpec = ( abs( fftshift( fft(fmChannelData,n_fft) )));
    fft_freqs = (-n_fft/2:1:n_fft/2-1)*fs/n_fft;
end

% PSD over entire audio file
welch_size  = 4096*4;
n_overlap   = welch_size / 4;
if isRunningInOctave()
    n_overlap = 1/4;
end
n_fft_welch = welch_size;
window      = hanning(welch_size);

if EnableSenderSourceCreateSim
    [psxx_tx, psxx_tx_f]             = pwelch(fmChannelData, window, n_overlap, n_fft_welch, fs);
end
[psxx_rx_fm_bb, psxx_rx_fm_bb_f] = pwelch(rx_fm_bb, window, n_overlap, n_fft_welch, fs);

% Rx %%%%%%%%%%%%%%%%%%%%%
[psxx_rx_mono, psxx_rx_mono_f]                   = pwelch(rx_audio_mono, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_bpfilt, psxx_rx_lrdiff_bpfilt_f] = pwelch(rx_audio_lrdiff_bpfilt, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_mod, psxx_rx_lrdiff_mod_f]       = pwelch(rx_audio_lrdiff_mod, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff, psxx_rx_lrdiff_f]               = pwelch(rx_audio_lrdiff, window, n_overlap, n_fft_welch, fs_rx);

% Rx (RF) %%%%%%%%%%%%%%%%
if EnableSenderSourceCreateSim
    welch_size  = 4096*4*osr_mod;
    n_overlap   = welch_size / 4;
    if isRunningInOctave()
        n_overlap = 1/4;
    end
    n_fft_welch = welch_size;
    window      = hanning(welch_size);
    
    [psxx_rx_fm, psxx_rx_fm_f] = pwelch(rx_fm, window, n_overlap, n_fft_welch, fs_mod);
end

%% Plots

fig_title = 'Time domain signal';
fig_audio_time = figure('Name',fig_title);
if EnableSenderSourceCreateSim
subplot(6,1,1);
plot(tn/fs, audioDataL, 'r', 'DisplayName', 'audioDataL');
title(fig_title);
grid on; legend();
subplot(6,1,2);
plot(tn/fs, audioDataR, 'g', 'DisplayName', 'audioDataR');
grid on; legend();
end
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
saveas(fig_audio_time, sprintf("%s%s",dir_output, "time_audio.png"));

fig_title = 'Time domain signal (modulated and de-modulated)';
fig_time_mod = figure('Name',fig_title);
hold on;
if EnableSenderSourceCreateSim
    plot(tn/fs, fmChannelData,        'b', 'DisplayName', 'fmChannelData (pre-mod)');
end
plot(tnRx/fs_rx, rx_fmChannelData,'r', 'DisplayName', 'rx\_fmChannelData (demod)');
grid on;
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();
saveas(fig_time_mod, sprintf("%s%s",dir_output, "time_mod_demod.png"));

if false
    fig_title = 'FM demodulator';
    fig_time_fm_demodulator = figure('Name',fig_title);
    hold on;
    plot(tn/fs, rx_fm_bb,        'r', 'DisplayName', 'rx\_fm\_bb');
    plot(tn/fs, rx_fm_bb_norm,   'g', 'DisplayName', 'rx\_fm\_bb\_norm');
    plot(tn/fs, rx_fm_demod_raw, 'b', 'DisplayName', 'rx\_fm\_demod\_raw');
    grid on;
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

if false
    fig_title = 'Time domain signal (to check group delay)';
    fig_adapt_grpdelay_time = figure('Name',fig_title);
    hold on;
    plot(tnRx/fs_rx, rx_audio_mono,   'r', 'DisplayName', 'rx\_audio\_mono');
    plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
    grid on; 
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

if false
    fig_title = 'Tx time domain signal';
    fig_tx_time = figure('Name',fig_title);
    hold on;
    plot(tn/fs, fmChannelData, 'b', 'DisplayName', 'Total');
    plot(tn/fs, audioData,     'r', 'DisplayName', 'audioData');
    plot(tn/fs, pilotTone,     'm', 'DisplayName', 'pilotTone');
    plot(tn/fs, audioLRDiffMod,'k', 'DisplayName', 'audioLRDiffMod');
    if EnableTrafficInfoTrigger
        plot(tn/fs, hinz_triller,'g', 'DisplayName', 'hinzTriller');
    end
    grid on; 
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    xlim([0 inf]);
    saveas(fig_tx_time, sprintf("%s%s",dir_output, "time_tx.png"));
end

fig_title = 'Rx channel spectrum complex IQ mixer (linear)';
fig_rx_mod = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
xline(fc_oe3, 'k--', 'fc');
h0 ='';
if EnableSenderSourceCreateSim
h0 = plot(psxx_rx_fm_f, psxx_rx_fm,       'b','DisplayName', 'RxFM');
end
h1 = plot(psxx_rx_fm_bb_f, psxx_rx_fm_bb, 'r','DisplayName', 'RxFM BB');
grid on; 
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','East');
xlim([0 fc_oe3+fc_oe3/5]);
saveas(fig_rx_mod, sprintf("%s%s",dir_output, "psd_iq_mixer.png"));

fig_title = 'FM channel spectrum (linear)';
fig_tx_spec = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
%plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
h0 ='';
if EnableSenderSourceCreateSim
h0 = plot(psxx_tx_f, psxx_tx,             'b','DisplayName', 'Tx');
end
h1 = plot(psxx_rx_fm_bb_f, psxx_rx_fm_bb, 'r','DisplayName', 'Rx');
grid on; 
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','east');
xlim([0 65e3]);
ylimits = ylim();
saveas(fig_tx_spec, sprintf("%s%s",dir_output, "psd_rx_tx.png"));

fig_title = 'Rx spectrum parts (linear)';
fig_rx_spec = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
h0 = plot(psxx_rx_mono_f, psxx_rx_mono,                   'b',  'DisplayName', 'Mono');
h1 = plot(psxx_rx_lrdiff_bpfilt_f, psxx_rx_lrdiff_bpfilt, 'r-.','DisplayName', 'LR Diff bp filtered');
h2 = plot(psxx_rx_lrdiff_mod_f, psxx_rx_lrdiff_mod,       'r',  'DisplayName', 'LR Diff bp filtered and mod');
h3 = plot(psxx_rx_lrdiff_f, psxx_rx_lrdiff,               'g',  'DisplayName', 'LR Diff BB');
grid on; 
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1,h2,h3],'Location','east');
xlim([0 65e3]);
ylim(ylimits);
saveas(fig_rx_spec, sprintf("%s%s",dir_output, "psd_rx_parts.png"));


%% Arrange all plots on the display
if ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

