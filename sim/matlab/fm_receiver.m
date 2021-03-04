%-------------------------------------------------------------------------
% File        : fm_receiver.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM Receiver - demodulates FM and decodes the FM channel.
%-------------------------------------------------------------------------

%=========================================================================
% NOTE:
%   This file only works when called from "fm_transceiver.m".
%=========================================================================

disp('### Receiver Rx ###');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FM Demodulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-- FM demodulator');

% Normalize the amplitude (remove amplitude variations)
rx_fm_bb_norm = rx_fm_bb ./ abs(rx_fm_bb);

% Design differentiator
filter_diff = [1,0,-1];

% Demodulate
rx_fm_i = real(rx_fm_bb_norm);
rx_fm_q = imag(rx_fm_bb_norm);

%rx_fm_demod =  ...
%    (rx_fm_i .* conv(rx_fm_q,filter_diff,'same') -   ...
%    rx_fm_q .* conv(rx_fm_i,filter_diff,'same')) ./  ...
%    (rx_fm_i.^2 + rx_fm_q.^2);

part_demod_a = rx_fm_i .* filter(filter_diff,1, rx_fm_q);
part_demod_b = rx_fm_q .* filter(filter_diff,1, rx_fm_i);

rx_fm_demod = part_demod_a - part_demod_b;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% De-emphasis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('-- De-emphasis');

if EnableDeEmphasis
    % Create de-emphasis filter
    filter_de_emphasis = getEmphasisFilter(fs, 'de', EnableFilterAnalyzeGUI);
    
    % Filter
    rx_fm_demod = filter(filter_de_emphasis.Num, filter_de_emphasis.Denum, rx_fm_demod);
end

%% Downsample

rx_fmChannelData = rx_fm_demod;

osr_rx = 4;
fs_rx  = fs/osr_rx;
tnRx = (0:1:n_sec*fs_rx-1)';

rx_fmChannelData = resample(rx_fmChannelData, 1, osr_rx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recover pilot tone and subcarriers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_pilot.mat");
ripple_pass_dB = 0.1;                       % Passband ripple in dB
ripple_stop_db = 50;                        % Stopband ripple in dB
cutoff_freqs   = [17e3 18.5e3 19.5e3 21e3]; % Band frequencies (defined like slopes)

filter_bp_pilot = getBPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (Bandpass 18.5k..19.5kHz)
rx_pilot = filter(filter_bp_pilot,1, rx_fmChannelData);

% Amplify 
% NOTE: Theoretically, the factor should be 10, since the pilot is
%       transmitted with an amplitude of 10%.
rx_pilot = rx_pilot * 11;

%% Generate sub-carriers

% 38 kHz carrier
carrier38kHzRx = rx_pilot .* rx_pilot * 2 - 1;

% 57 kHz carrier
carrier57kHzRx = carrier38kHzRx .* rx_pilot * 2 - 1;

% Create the lowpass filter
filter_name = sprintf("%s%s",dir_filters,"lowpass_57kHz.mat");
ripple_pass_dB = 0.1;          % Passband ripple in dB
ripple_stop_db = 50;           % Stopband ripple in dB
cutoff_freqs   = [20e3 36e3];  % Cutoff frequencies

filter_hp_57k = getHPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (lowpass 1.5kHz)
carrier57kHzRx = filter(filter_hp_57k,1, carrier57kHzRx);

% TODO: delay all other carriers and the rx signal (rx_fmChannelData)
%       to compensate for the HP filter.
% NOTE: Using a "circshift" as a workaround for now. 
%       This cannot be done in hardware!
filt_hp57k_groupdelay = (length(filter_hp_57k)-1)/2;
carrier57kHzRx = circshift(carrier57kHzRx, -filt_hp57k_groupdelay);

% For test purpose only.
pilot_local          = cos(2*pi*19e3/fs_rx*tnRx + phi_pilot);
carrier38kHzRx_local = cos(2*pi*38e3/fs_rx*tnRx + phi_pilot*2);
carrier57kHzRx_local = cos(2*pi*57e3/fs_rx*tnRx + phi_pilot*3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RDS decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRDSDecoder
    disp('-- RDS Decoder');
    
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
    rx_rds_mod = resample(rx_rds_mod, 1, osr_rds);
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio channel decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-- Channel decoder');

%% Filter the mono part

% Create the low pass filter
filter_name = sprintf("%s%s",dir_filters,"lowpass_mono.mat");
ripple_pass_dB = 0.1;         % Passband ripple in dB
ripple_stop_db = 50;          % Stopband ripple in dB
cutoff_freqs   = [15e3 19e3]; % Cutoff frequencies

filter_lp_mono = getLPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (lowpass 15kHz)
rx_audio_mono = filter(filter_lp_mono,1, rx_fmChannelData);

% TODO: remove mean (?)
%mean_mono = mean(rx_audio_mono);
%rx_audio_mono = rx_audio_mono - mean_mono;

%% Filter the LR-diff-part

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_lrdiff.mat");
ripple_pass_dB = 0.1;                   % Passband ripple in dB
ripple_stop_db = 50;                    % Stopband ripple in dB
cutoff_freqs   = [19e3 23e3 53e3 57e3]; % Band frequencies (defined like slopes)

filter_bp_lrdiff = getBPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (Bandpass 23k..53kHz)
rx_audio_lrdiff_bpfilt = filter(filter_bp_lrdiff,1, rx_fmChannelData);

% Modulate down to baseband
rx_audio_lrdiff_mod = 2 * rx_audio_lrdiff_bpfilt .* carrier38kHzRx;

% Filter (lowpass 15kHz)
rx_audio_lrdiff = filter(filter_lp_mono,1, rx_audio_lrdiff_mod);


%% Combine received signal
% L = (L+R) + (L-R) = (2)L
% R = (L+R) - (L-R) = (2)R
% where (L+R) = mono, and (L-R) is lrdiff

% Delay the mono signal to match the lrdiff signal
% NOTE: The mono signal only needs to pass through a single LP.
%       The lrdiff signal passed through a BP and a LP. Thus, it needs to
%       be delayed by the BP's groupdelay, since the LP is the same.
filt_bp_groupdelay = (length(filter_bp_lrdiff)-1)/2;

% Compensate the group delay
rx_audio_mono = [zeros(filt_bp_groupdelay,1); rx_audio_mono(1:end-filt_bp_groupdelay)];

% Compute left and right channel signals
rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

disp('Done.');
