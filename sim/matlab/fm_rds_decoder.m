%-------------------------------------------------------------------------
% File        : fm_rds_decoder.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM RDS Decoder - decodes the RDS data stream.
%-------------------------------------------------------------------------

%=========================================================================
% NOTE:
%   This file only works when called from "fm_transceiver.m".
%=========================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RDS decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-- RDS Decoder');

%% Sanity checks

% 61 kHz is the highest frequency content in the RDS band
assert(fs_rx > 61e3 * 2, 'Sampling frequency fs_rx too low --> Nyquist!');

%% Modulate down to baseband

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_rds.mat");
ripple_pass_dB = 0.1;                   % Passband ripple in dB
ripple_stop_db = 80;                    % Stopband ripple in dB
cutoff_freqs   = [53e3 55e3 59e3 61e3]; % Band frequencies (defined like slopes)

filter_bp_rds = getBPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (Bandpass 53k..61kHz)
rx_rds = filter(filter_bp_rds,1, rx_fmChannelData);

% Modulate down to baseband
rx_rds_mod = 2 * rx_rds .* carrier57kHzRx;

% Downsample
osr_rds = 5;
fs_rds = fs_rx/osr_rds;

rx_rds_mod = calcDecimation(rx_rds_mod, osr_rds, EnableManualDecimation);

tnRDS = (0:1:n_sec*fs_rds-1)';

% Create the lowpass filter
filter_name = sprintf("%s%s",dir_filters,"lowpass_rds.mat");
ripple_pass_dB = 0.01;          % Passband ripple in dB
ripple_stop_db = 50;            % Stopband ripple in dB
cutoff_freqs   = [1.5e3 3e3];   % Cutoff frequencies

filter_lp_rds = getLPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rds, EnableFilterAnalyzeGUI);

% Filter (lowpass 1.5kHz)
rx_rds_bb = filter(filter_lp_rds,1, rx_rds_mod);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: see 'research/RBDSExample.m'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Decode

%userInput = helperRBDSInit();
%userInput.Duration = n_sec;
%userInput.SignalSource =

%[rbdsParam, sigSrc] = helperRBDSConfig(userInput);
