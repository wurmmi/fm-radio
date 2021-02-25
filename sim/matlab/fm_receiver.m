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
    tau = 50e-6;         % time constant (50µs in Europe, 75us in US)
    fc  = 1/(2*pi*tau);  % cut-off frequency
    
    k = fs/(2*pi*fc);
    
    filter_de_emphasis.Num = [1 0];
    filter_de_emphasis.Denum = [1+k -k];
    
    rx_fm_demod = filter(filter_de_emphasis.Num, filter_de_emphasis.Denum, rx_fm_demod);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Channel decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-- Channel decoder');

rx_fmChannelData = rx_fm_demod;

%% Downsample

osr_rx = 1;
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

% Compute left and right channel signals
rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

disp('Done.');
