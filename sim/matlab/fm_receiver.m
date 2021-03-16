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
if EnableProcessingLikeHW
    rx_fm_bb_norm = rx_fm_bb;
else
    rx_fm_bb_norm = rx_fm_bb ./ abs(rx_fm_bb);
end

% Demodulate
rx_fm_i = real(rx_fm_bb_norm);
rx_fm_q = imag(rx_fm_bb_norm);

% Design differentiator
filter_diff = [1,0,-1];

if EnableProcessingLikeHW
    n_shift = 3;
    rx_fm_i_diff = rx_fm_i - [zeros(n_shift,1); rx_fm_i(1:end-n_shift)];
    rx_fm_q_diff = rx_fm_q - [zeros(n_shift,1); rx_fm_q(1:end-n_shift)];
else
    rx_fm_i_diff = filter(filter_diff,1, rx_fm_i);
    rx_fm_q_diff = filter(filter_diff,1, rx_fm_q);
    
    % Compensate group delay of filter
    rx_fm_i_diff = circshift(rx_fm_i_diff,-1);
    rx_fm_q_diff = circshift(rx_fm_q_diff,-1);
    
    %rx_fm_demod =  ...
    %    (rx_fm_i .* conv(rx_fm_q,filter_diff,'same') -   ...
    %    rx_fm_q .* conv(rx_fm_i,filter_diff,'same')) ./  ...
    %    (rx_fm_i.^2 + rx_fm_q.^2);
end

part_demod_a = rx_fm_i .* rx_fm_q_diff;
part_demod_b = rx_fm_q .* rx_fm_i_diff;

rx_fm_demod = part_demod_a - part_demod_b;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% De-emphasis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableDeEmphasis
    disp('-- De-emphasis');
    
    % Create de-emphasis filter
    filter_de_emphasis = getEmphasisFilter(fs, 'de', EnableFilterAnalyzeGUI);
    
    % Filter
    rx_fm_demod = filter(filter_de_emphasis.Num, filter_de_emphasis.Denum, rx_fm_demod);
end

%% Downsample
% NOTE: This receiver is NOT decoding the RDS stream.
%       Thus, the highest frequency content is 53kHz (end of LR-Diff band).
%       Consequently, the sampling frequency only needs to be 53kHz * 2,
%       according to Nyquist.

osr_rx = 8;
fs_rx  = fs/osr_rx;
tnRx   = (0:1:n_sec*fs_rx-1)';

assert(isIntegerVal(fs_rx), 'Sampling frequency fs_rx must be an integer!');
assert(fs_rx > 53e3 * 2,    'Sampling frequency fs_rx too low --> Nyquist!');

rx_fmChannelData = calcDecimation(rx_fm_demod, osr_rx, EnableManualDecimation);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recover pilot tone and subcarriers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the bandpass filter
filter_name = sprintf("%s%s",dir_filters,"bandpass_pilot.mat");
ripple_pass_dB = 1;                         % Passband ripple in dB
ripple_stop_db = 40;                        % Stopband ripple in dB
cutoff_freqs   = [15e3 18.5e3 19.5e3 23e3]; % Band frequencies (defined like slopes)

filter_bp_pilot = getBPfilter( ...
    filter_name, ...
    ripple_pass_dB, ripple_stop_db, ...
    cutoff_freqs, fs_rx, EnableFilterAnalyzeGUI);

% Filter (Bandpass 18.5k..19.5kHz)
rx_pilot = filter(filter_bp_pilot,1, rx_fmChannelData);

% Amplify
% NOTE: Theoretically, the factor should be 10, since the pilot is
%       transmitted with an amplitude of 10%.
rx_pilot = rx_pilot * 12; %TODO: adapt this value

% Amplify again, if a de-emphasis filter is used.
% TODO: check this
if EnableDeEmphasis
    rx_pilot = rx_pilot * 7;
end

%% Generate sub-carriers

% 38 kHz carrier
carrier38kHzRx = rx_pilot .* rx_pilot * 1 - 1;

if EnableRDSDecoder
    if fs_rx < 57e3 * 2
        error('Sampling rate fs_rx is too small for the 57kHz carrier! (Nyquist)')
    end
    
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
    filter_hp57k_groupdelay = (length(filter_hp_57k)-1)/2;
    carrier57kHzRx = circshift(carrier57kHzRx, -filter_hp57k_groupdelay);
end

% For test purpose only.
pilot_local          = cos(2*pi*19e3/fs_rx*tnRx + phi_pilot);
carrier38kHzRx_local = cos(2*pi*38e3/fs_rx*tnRx + phi_pilot*2);
carrier57kHzRx_local = cos(2*pi*57e3/fs_rx*tnRx + phi_pilot*3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RDS decoder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRDSDecoder
    fm_rds_decoder();
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

% TODO: check, why this is inverted, depending on the sample rate..
rx_audio_lrdiff = -1 * rx_audio_lrdiff;


%% Combine received signal
% L = (L+R) + (L-R) = (2)L
% R = (L+R) - (L-R) = (2)R
% where (L+R) = mono, and (L-R) is lrdiff

% Delay the mono signal to match the lrdiff signal
% NOTE: The mono signal only needs to pass through a single LP.
%       The lrdiff signal passed through a BP and a LP. Thus, it needs to
%       be delayed by the BP's groupdelay, since the LP is the same.
filter_bp_lrdiff_groupdelay = (length(filter_bp_lrdiff)-1)/2;

% Compensate the group delay
rx_audio_mono = [zeros(filter_bp_lrdiff_groupdelay,1); rx_audio_mono(1:end-filter_bp_lrdiff_groupdelay)];

% Compute left and right channel signals
rx_audio_L = rx_audio_mono + rx_audio_lrdiff;
rx_audio_R = rx_audio_mono - rx_audio_lrdiff;

disp('Done.');
