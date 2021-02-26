%-------------------------------------------------------------------------
% File        : fm_transceiver.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM-Radio Sender and Receiver
%-------------------------------------------------------------------------

% TODO: check RX spectrum.. looks fishy - where does the 57k come from??
%        - 19khz + 38 = 57 (--> better bp filter!)

% TODO: find integer osr for entire system

%TODO: find places, where power is attenuated --> Tx and Rx should be equal
%      --> only amplify at a single place (at the receiver input)

% TODO: change FM demodulator, for better HW implementation

% TODO: change other things, for better HW implementation

% TODO: find a benchmark to compare against

%% Prepare environment
clear;
close all;
clc;

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
EnableAudioFromFile            = false;
EnableTrafficInfoTrigger       = false;

EnablePreEmphasis = false;
EnableDeEmphasis  = true;

EnableRxAudioReplay    = true;
EnableFilterAnalyzeGUI = false;
EnableSavePlotsToPng   = false;

% Signal parameters
n_sec = 1.7;           % 1.7s is "left channel, right channel" in audio file
osr   = 22;            % oversampling rate for fs
fs    = 44.1e3 * osr;  % sampling rate fs

% Channel
fc_oe3 = 98.1e4;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_sender();

% TODO
%fm_sender_fixed_point();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_receiver();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio replay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('### Audio Replay ###');

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
disp('### Analysis ###');

% Create output folder to save figures
if ~exist(dir_output, 'dir')
    mkdir(dir_output)
end

%% Calculations
disp('-- FFT and PSD calculations');

%% FFT
% Tx %%%%%%%%%%%%%%%%%%%%%
if EnableSenderSourceCreateSim
    n_fft = 4096*10;
    fmChannelSpec = ( abs( fftshift( fft(fmChannelData,n_fft) )));
    fft_freqs = (-n_fft/2:1:n_fft/2-1)*fs/n_fft;
end

%% PSD over entire audio file

% fs domain %%%%%%%%%%%%%%%%%%%%%
welch_size = length(rx_fm_bb);
n_overlap  = welch_size / 4;
if isRunningInOctave()
    n_overlap = 1/4;
end
n_fft_welch = welch_size;
window      = hanning(welch_size);

if EnableSenderSourceCreateSim
    [psxx_tx_fmChannelData, psxx_tx_fmChannelData_f] = pwelch(fmChannelData, window, n_overlap, n_fft_welch, fs);
end
[psxx_rx_fm_bb, psxx_rx_fm_bb_f] = pwelch(rx_fm_bb, window, n_overlap, n_fft_welch, fs);
[psxx_rxChannelData, psxx_rxChannelData_f] = pwelch(rx_fm_demod, window, n_overlap, n_fft_welch, fs);

% fs_rx domain %%%%%%%%%%%%%%%%%%%%%
welch_size  = length(rx_audio_mono);
n_overlap   = welch_size / 4;
if isRunningInOctave()
    n_overlap = 1/4;
end
n_fft_welch = welch_size;
window      = hanning(welch_size);

[psxx_rx_mono, psxx_rx_mono_f]                   = pwelch(rx_audio_mono, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_bpfilt, psxx_rx_lrdiff_bpfilt_f] = pwelch(rx_audio_lrdiff_bpfilt, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff_mod, psxx_rx_lrdiff_mod_f]       = pwelch(rx_audio_lrdiff_mod, window, n_overlap, n_fft_welch, fs_rx);
[psxx_rx_lrdiff, psxx_rx_lrdiff_f]               = pwelch(rx_audio_lrdiff, window, n_overlap, n_fft_welch, fs_rx);

% fs_mod domain %%%%%%%%%%%%%%%%%%%%%
if EnableSenderSourceCreateSim
    welch_size  = length(rx_fm);
    n_overlap   = welch_size / 4;
    if isRunningInOctave()
        n_overlap = 1/4;
    end
    n_fft_welch = welch_size;
    window      = hanning(welch_size);
    
    [psxx_rx_fm, psxx_rx_fm_f] = pwelch(rx_fm, window, n_overlap, n_fft_welch, fs_mod);
end

%% Plots
disp('-- Plots');

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
if EnableSavePlotsToPng
    saveas(fig_audio_time, sprintf("%s%s",dir_output, "time_audio.png"));
end

if EnableSenderSourceCreateSim
    fig_title = 'Time domain signal (modulated and de-modulated)';
    fig_time_mod = figure('Name',fig_title);
    hold on;
    plot(tn/fs, fmChannelData,        'b', 'DisplayName', 'fmChannelData (pre-mod)');
    plot(tnRx/fs_rx, rx_fmChannelData,'r', 'DisplayName', 'rx\_fmChannelData (demod)');
    grid on;
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    if EnableSavePlotsToPng
        saveas(fig_time_mod, sprintf("%s%s",dir_output, "time_mod_demod.png"));
    end
end

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
    plot(tn/fs, audioDataMono, 'r', 'DisplayName', 'audioDataMono');
    plot(tn/fs, audioLRDiff,'k', 'DisplayName', 'audioLRDiff');
    if EnableTrafficInfoTrigger
        plot(tn/fs, hinz_triller,'g', 'DisplayName', 'hinzTriller');
    end
    grid on;
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
    xlim([0 inf]);
    if EnableSavePlotsToPng
        saveas(fig_tx_time, sprintf("%s%s",dir_output, "time_tx.png"));
    end
end

fig_title = 'Rx channel spectrum complex IQ mixer';
fig_rx_mod = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
xline(fc_oe3, 'k--', 'fc\_oe3');
xline(fs, 'k--', 'fs');
h0 ='';
if EnableSenderSourceCreateSim
    h0 = plot(psxx_rx_fm_f, 10*log10(psxx_rx_fm),   'b','DisplayName', 'RxFM');
end
h1 = plot(psxx_rx_fm_bb_f, 10*log10(psxx_rx_fm_bb), 'r','DisplayName', 'RxFM BB');
grid on;
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','East');
xlim([0 fs+fs/8]);
if EnableSavePlotsToPng
    saveas(fig_rx_mod, sprintf("%s%s",dir_output, "psd_iq_mixer.png"));
end

fig_title = 'FM channel spectrum';
fig_tx_spec = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
h0 ='';
if EnableSenderSourceCreateSim
    h0 = plot(psxx_tx_fmChannelData_f, psxx_tx_fmChannelData, 'b','DisplayName', 'Tx (pre-mod)');
end
h1 = plot(psxx_rxChannelData_f, psxx_rxChannelData,  'r','DisplayName', 'Rx Demod');
%h2 = plot(fft_freqs, fmChannelSpec, 'k--', 'DisplayName', 'FFT');
h2 = '';
grid on;
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1,h2],'Location','east');
xlim([0 62e3]);
ylimits = ylim();
if EnableSavePlotsToPng
    saveas(fig_tx_spec, sprintf("%s%s",dir_output, "psd_rx_tx.png"));
end

fig_title = 'Rx spectrum parts';
fig_rx_spec = figure('Name',fig_title);
hold on;
xline(19e3,'k--','19 kHz');
xline(38e3,'k--','38 kHz');
xline(57e3,'k--','57 kHz');
h0 = plot(psxx_rx_mono_f, 10*log10(psxx_rx_mono),                   'b',  'DisplayName', 'Mono');
h1 = plot(psxx_rx_lrdiff_bpfilt_f, 10*log10(psxx_rx_lrdiff_bpfilt), 'r-.','DisplayName', 'LR Diff bp filtered');
h2 = plot(psxx_rx_lrdiff_mod_f, 10*log10(psxx_rx_lrdiff_mod),       'r',  'DisplayName', 'LR Diff bp filtered and mod');
h3 = plot(psxx_rx_lrdiff_f, 10*log10(psxx_rx_lrdiff),               'g',  'DisplayName', 'LR Diff BB');
grid on;
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1,h2,h3],'Location','east');
xlim([0 100e3]);
ylim(ylimits);
if EnableSavePlotsToPng
    saveas(fig_rx_spec, sprintf("%s%s",dir_output, "psd_rx_parts.png"));
end


%% Arrange all plots on the display
if ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

disp('Done.');
