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

rx_fm_demod =  ...
    (rx_fm_i .* conv(rx_fm_q,filter_diff,'same') -   ...
    rx_fm_q .* conv(rx_fm_i,filter_diff,'same')) ./  ...
    (rx_fm_i.^2 + rx_fm_q.^2);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pilot tone recovery
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_pilot.mat");
if isRunningInOctave()
    disp("Running in GNU Octave - loading bandpass filter from folder!");
    filter_bp_pilot = load(filter_name);
else
    ripple_pass_dB = 0.1;                       % Passband ripple in dB
    ripple_stop_db = 50;                        % Stopband ripple in dB
    cutoff_freqs   = [17e3 18.5e3 19.5e3 21e3]; % Band frequencies (defined like slopes)

    filter_bp_pilot = getBPfilter( ...
        ripple_pass_dB, ripple_stop_db, ...
        cutoff_freqs, fs, EnableFilterAnalyzeGUI);

    % Save the filter coefficients
    save(filter_name,'filter_bp_pilot','-ascii');
end

% Filter (Bandpass 18.5k..19.5kHz)
rx_pilot = filter(filter_bp_pilot,1, rx_fm_demod);

%% Downsample

rx_fmChannelData = rx_fm_demod;

osr_rx = 4;
fs_rx  = fs/osr_rx;
rx_fmChannelData = resample(rx_fmChannelData, 1, osr_rx);

%% Generate sub-carriers

% TODO: Generate local carriers here
%         -- use the rx_pilot and multiply with itself = 38kHz!
%         -- LP filter replicas at >19khz
%         -- use this signal as the carrier38kHz!

tnRx = (0:1:n_sec*fs_rx-1)';
carrier38kHzRx = cos(2*pi*38e3/fs_rx*tnRx + phi_pilot*2);
carrier57kHzRx = cos(2*pi*57e3/fs_rx*tnRx + phi_pilot*3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RDS decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRDSDecoder
    disp('-- RDS Decoder');
    
    % Create the bandpass filter
    filter_name = sprintf("%s%s",dir_filters,"bandpass_rds.mat");
    if isRunningInOctave()
        disp("Running in GNU Octave - loading bandpass filter from folder!");
        filter_bp_rds = load(filter_name);
    else
        ripple_pass_dB = 0.1;                   % Passband ripple in dB
        ripple_stop_db = 80;                    % Stopband ripple in dB
        cutoff_freqs   = [53e3 55e3 59e3 61e3]; % Band frequencies (defined like slopes)
        
        filter_bp_rds = getBPfilter( ...
            ripple_pass_dB, ripple_stop_db, ...
            cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);
        
        % Save the filter coefficients
        save(filter_name,'filter_bp_rds','-ascii');
    end
    
    % Filter (Bandpass 53k..61kHz)
    rx_rds = filter(filter_bp_rds,1, rx_fmChannelData);
    
    % Modulate down to baseband
    rx_rds_mod = 2 * rx_rds .* carrier57kHzRx;
    
    % Downsample
    osr_rds = 5;
    fs_rds = fs_rx/osr_rds;
    rx_rds_mod = resample(rx_rds_mod, 1, osr_rds);
    tnRDS = (0:1:n_sec*fs_rds-1)';

    % Filter (lowpass 3kHz)
    filter_name = sprintf("%s%s",dir_filters,"lowpass_rds.mat");
    if isRunningInOctave()
        disp("Running in GNU Octave - loading lowpass filter from folder!");
        filter_lp_rds = load(filter_name);
    else
        ripple_pass_dB = 0.01;          % Passband ripple in dB
        ripple_stop_db = 50;            % Stopband ripple in dB
        cutoff_freqs   = [1.5e3 3e3]; % Cutoff frequencies
        
        filter_lp_rds = getLPfilter( ...
            ripple_pass_dB, ripple_stop_db, ...
            cutoff_freqs, fs_rds, EnableFilterAnalyzeGUI);
        
        % Save the filter coefficients
        save(filter_name,'filter_lp_rds','-ascii');
    end
    rx_rds_bb = filter(filter_lp_rds,1, rx_rds_mod);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio channel decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-- Channel decoder');

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

% TODO: remove mean (?)
%mean_mono = mean(rx_audio_mono);
%rx_audio_mono = rx_audio_mono - mean_mono;

%% Filter the LR-diff-part

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_lrdiff.mat");
if isRunningInOctave()
    disp("Running in GNU Octave - loading bandpass filter from folder!");
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
bp_groupdelay = (length(filter_bp_lrdiff)-1)/2;

% Compensate the group delay
rx_audio_mono = [zeros(bp_groupdelay,1); rx_audio_mono(1:end-bp_groupdelay)];

% Compute left and right channel signals
rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

disp('Done.');
