%-------------------------------------------------------------------------
% File        : fm_transceiver.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM-Radio Sender and Receiver
%-------------------------------------------------------------------------

% TODO: make everything fixed point

% TODO: change/optimize things for better HW implementation

% TODO: draw a block diagram

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
dir_filters = "./filters/stored/";
dir_output  = "./matlab_output/";

% Simulation options
EnableWriteDataFiles = true;
EnablePlots = true;

EnableSenderSourceRecordedFile = false;
EnableSenderSourceCreateSim    = true;
EnableAudioFromFile            = true;
EnableTrafficInfoTrigger       = false;

EnableRxAudioReplay    = true;
EnableFilterAnalyzeGUI = false;
EnableSavePlotsToPng   = false;
EnablePlotsLogarithmic = true;

% Signal processing options
EnableProcessingLikeHW = true;
EnablePreEmphasis      = false;
EnableDeEmphasis       = false;
EnableManualDecimation = true;
EnableRDSDecoder       = false;

% Signal parameters
n_sec = 1.7;           % 1.7s is "left channel, right channel" in audio file
osr   = 20;            % oversampling rate for fs
fs    = 48e3 * osr;    % sampling rate fs

phi_pilot = (-60)*pi/180; % phase shift between local carrier and Rx pilot

% Channel
fc_oe3 = 98.1e4;

%% Sanity checks
assert( not(EnableRDSDecoder && EnableSenderSourceRecordedFile == false), ...
    'Settings Error: RDS decoder only works with binary file data. (Simulator does not generate RDS!)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_sender();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_receiver();

% TODO: implement an implementation that is suitable for hardware
% fm_receiver_fixed_point();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio replay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRxAudioReplay
    disp('### Audio Replay ###');
    
    % Create LR audio signal for output
    rx_audioReplay = zeros(length(rx_audio_L),2);
    rx_audioReplay(:,1) = rx_audio_L;
    rx_audioReplay(:,2) = rx_audio_R;
    
    % Downsample for PC soundcard
    osr_replay = 3;
    fs_audioReplay = fs_rx/osr_replay;
    rx_audioReplay = resample(rx_audioReplay, 1, osr_replay);
    
    sound(rx_audioReplay, fs_audioReplay);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Store data to file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableWriteDataFiles
    disp('### Write verification data ###');
    
    fp_width      = 32;
    fp_width_frac = 31;
    fp_maximum    = 0.999;
    
    n_sec_file = 0.03;

    num_samples = n_sec_file * fs/osr_rx;
    
    % Test data
    writeDataToFile(rx_fm_bb,         num_samples*osr_rx,'./verification_data/rx_fm_bb.txt',         fp_width, fp_width_frac);
    writeDataToFile(rx_fm_demod,      num_samples*osr_rx,'./verification_data/rx_fm_demod.txt',      fp_width, fp_width_frac);
    %writeDataToFile(rx_fmChannelData, num_samples,       './verification_data/rx_fmChannelData.txt', fp_width, fp_width_frac);
    %writeDataToFile(rx_pilot,         num_samples,       './verification_data/rx_pilot.txt',         fp_width, fp_width_frac);
    %writeDataToFile(rx_audio_mono,    num_samples,       './verification_data/rx_audio_mono.txt',    fp_width, fp_width_frac);
    %writeDataToFile(rx_audio_L,       num_samples,       './verification_data/rx_audio_L.txt',       fp_width, fp_width_frac);
    %writeDataToFile(rx_audio_R,       num_samples,       './verification_data/rx_audio_R.txt',       fp_width, fp_width_frac);
    
    % Filter coefficients
    %writeFilterCoeffsToVHDLFile(filter_diff, 'filter_diff', ...
    %    '../../hardware/src/filter_coeff_pkgs/', fp_width, fp_width_frac);
    writeFilterCoeffsToVHDLFile(filter_bp_pilot, 'filter_bp_pilot', ...
        '../../hardware/src/filter_coeff_pkgs/', fp_width, fp_width_frac);
    writeFilterCoeffsToVHDLFile(filter_lp_mono, 'filter_lp_mono', ...
        '../../hardware/src/filter_coeff_pkgs/', fp_width, fp_width_frac);
    writeFilterCoeffsToVHDLFile(filter_bp_lrdiff, 'filter_bp_lrdiff', ...
        '../../hardware/src/filter_coeff_pkgs/', fp_width, fp_width_frac);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('### Analysis ###');

if ~EnablePlots
    disp('-- skipped calculations (plots are disabled)');
    return
end

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
[psxx_rx_fmChannelData, psxx_rxChannelData_f] = pwelch(rx_fm_demod, window, n_overlap, n_fft_welch, fs);

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
if EnableRDSDecoder
    [psxx_rx_rds, psxx_rx_rds_f]                 = pwelch(rx_rds, window, n_overlap, n_fft_welch, fs_rx);
end

% fs_rds domain %%%%%%%%%%%%%%%%%%%%%
if EnableRDSDecoder
    welch_size  = length(rx_rds_mod);
    n_overlap   = welch_size / 4;
    if isRunningInOctave()
        n_overlap = 1/4;
    end
    n_fft_welch = welch_size;
    window      = hanning(welch_size);
    
    [psxx_rx_rds_mod, psxx_rx_rds_mod_f] = pwelch(rx_rds_mod, window, n_overlap, n_fft_welch, fs_rds);
    [psxx_rx_rds_bb, psxx_rx_rds_bb_f]   = pwelch(rx_rds_bb, window, n_overlap, n_fft_welch, fs_rds);
end

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

% Calc logarithmus
if EnablePlotsLogarithmic
    if EnableSenderSourceCreateSim
        psxx_tx_fmChannelData = 10*log10(psxx_tx_fmChannelData);
        psxx_rx_fm            = 10*log10(psxx_rx_fm);
    end
    psxx_rx_fm_bb         = 10*log10(psxx_rx_fm_bb);
    psxx_rx_fmChannelData    = 10*log10(psxx_rx_fmChannelData);
    psxx_rx_mono          = 10*log10(psxx_rx_mono);
    psxx_rx_lrdiff_bpfilt = 10*log10(psxx_rx_lrdiff_bpfilt);
    psxx_rx_lrdiff_mod    = 10*log10(psxx_rx_lrdiff_mod);
    psxx_rx_lrdiff        = 10*log10(psxx_rx_lrdiff);
    if EnableRDSDecoder
        psxx_rx_rds           = 10*log10(psxx_rx_rds);
        psxx_rx_rds_mod       = 10*log10(psxx_rx_rds_mod);
        psxx_rx_rds_bb        = 10*log10(psxx_rx_rds_bb);
    end
end

%% Plots

disp('-- Plots');

fig_title = 'Time domain signal';
fig_audio_time = figure('Name',fig_title);
title(fig_title);
ax1='';
ax2='';
if EnableSenderSourceCreateSim
    ax1 = subplot(6,1,1);
    plot(tn/fs, audioDataL, 'r', 'DisplayName', 'audioDataL');
    grid on; legend();
    ax2 = subplot(6,1,2);
    plot(tn/fs, audioDataR, 'g', 'DisplayName', 'audioDataR');
    grid on; legend();
end
ax3 = subplot(6,1,3);
hold on;
plot(tnRx/fs_rx, rx_audio_lrdiff, 'b', 'DisplayName', 'rx\_audio\_lrdiff');
plot(tnRx/fs_rx, rx_audio_mono, 'r', 'DisplayName', 'rx\_audio\_mono');
ylabel('amplitude');
grid on; legend();
ax4 = subplot(6,1,4);
plot(tnRx/fs_rx, rx_audio_mono, 'b', 'DisplayName', 'rx\_audio\_mono');
grid on; legend();
ax5 = subplot(6,1,5);
plot(tnRx/fs_rx, rx_audio_L, 'r', 'DisplayName', 'rx\_audio\_L');
ymax = max(rx_audio_L);
ylim([-ymax,ymax]);
grid on; legend();
ax6 = subplot(6,1,6);
plot(tnRx/fs_rx, rx_audio_R, 'g', 'DisplayName', 'rx\_audio\_R');
ylim([-ymax,ymax]);
xlabel('time [s]');
grid on; legend();
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x');
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
    h0 = plot(psxx_rx_fm_f, psxx_rx_fm,   'b','DisplayName', 'RxFM');
end
h1 = plot(psxx_rx_fm_bb_f, psxx_rx_fm_bb, 'r','DisplayName', 'RxFM BB');
grid on;
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','East');
xlim([0 fc_oe3*1.5]);
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
h1 = plot(psxx_rxChannelData_f, psxx_rx_fmChannelData,  'r','DisplayName', 'Rx Demod');
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
h0 = plot(psxx_rx_mono_f, psxx_rx_mono,                   'b',  'DisplayName', 'Mono');
%h1 = plot(psxx_rx_lrdiff_bpfilt_f, psxx_rx_lrdiff_bpfilt, 'r-.','DisplayName', 'LR Diff bp filtered');
h2 = plot(psxx_rx_lrdiff_mod_f, psxx_rx_lrdiff_mod,       'r',  'DisplayName', 'LR Diff bp filtered and mod');
h3 = plot(psxx_rx_lrdiff_f, psxx_rx_lrdiff,               'g',  'DisplayName', 'LR Diff BB');
grid on;
title(fig_title);
xlabel('frequency [Hz]');
ylabel('magnitude');
legend([h0,h2,h3],'Location','east');
xlim([0 100e3]);
ylim(ylimits);
if EnableSavePlotsToPng
    saveas(fig_rx_spec, sprintf("%s%s",dir_output, "psd_rx_parts.png"));
end

if EnableRDSDecoder
    fig_title = 'Rx RDS spectrum parts';
    fig_rx_spec_rds = figure('Name',fig_title);
    hold on;
    xline(19e3,'k--','19 kHz');
    xline(38e3,'k--','38 kHz');
    xline(57e3,'k--','57 kHz');
    xline(57e3/48,'k--','1187.5 Hz');
    h0 = plot(psxx_rx_rds_f, psxx_rx_rds,         'b','DisplayName', 'RDS');
    h1 = plot(psxx_rx_rds_mod_f, psxx_rx_rds_mod, 'r','DisplayName', 'RDS BB Mod');
    h2 = plot(psxx_rx_rds_bb_f, psxx_rx_rds_bb,   'g','DisplayName', 'RDS BB Filtered');
    grid on;
    title(fig_title);
    xlabel('frequency [Hz]');
    ylabel('magnitude');
    legend([h0,h1,h2],'Location','east');
    xlim([0 70e3]);
    if EnableSavePlotsToPng
        saveas(fig_rx_spec_rds, sprintf("%s%s",dir_output, "psd_rx_rds_parts.png"));
    end
end

fig_title = 'Carrier phase recovery';
fig_rx_time_rds = figure('Name',fig_title);
hold on;
plot(tnRx/fs_rx, rx_pilot,             'm',   'DisplayName', 'carrier19kHz (rec.)', 'LineWidth',2);
plot(tnRx/fs_rx, pilot_local,          'm--', 'DisplayName', 'carrier19kHz (local)');
plot(tnRx/fs_rx, carrier38kHzRx,       'b',   'DisplayName', 'carrier38kHz (rec.)', 'LineWidth',2);
plot(tnRx/fs_rx, carrier38kHzRx_local, 'b--', 'DisplayName', 'carrier38kHz (local)');
if EnableRDSDecoder
    plot(tnRx/fs_rx, carrier57kHzRx,       'g',   'DisplayName', 'carrier57kHz (rec.)', 'LineWidth',2);
    plot(tnRx/fs_rx, carrier57kHzRx_local, 'g--', 'DisplayName', 'carrier57kHz (local)');
end
grid on;
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();
offset = 0.1;
xlim([offset, offset + 1/19e3*2]);

% Arrange all plots on the display
if ~isRunningInOctave()
    autoArrangeFigures(3,2,2);
end

disp('Done.');
