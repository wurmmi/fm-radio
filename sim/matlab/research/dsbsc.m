%-------------------------------------------------------------------------
% File        : dsbsc.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Learn about DSB-SC (dual sideband AM, suppressed carrier)
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

addpath(genpath('../helpers/'));
addpath(genpath('../filters/'));

%=========================================================================
%% Settings

% Simulation Options
EnableFilterAnalyzeGUI = false;

% Common
osr = 10;
fs  = 57e3*osr;

n_sec = 0.010;
tn    = (0:1:fs*n_sec-1).';

% Signal
fmsg = 57e3/48;
Amsg = 1;

% Tx carrier
fc_tx  = 57e3;
A_tx_c = 1;

% Rx carrier
fc_rx  = 57e3;
phi_rx = 45*pi/180;
A_rx_c = 1;

%=========================================================================
%% Modulate

msg       = Amsg   * cos(2*pi*fmsg/fs *tn);
txCarrier = A_tx_c * cos(2*pi*fc_tx/fs*tn);

tx = 2 * msg .* txCarrier;

%=========================================================================
%% Demodulate

rxCarrier = A_rx_c * cos(2*pi*fc_rx/fs*tn + phi_rx);

rx_msg_demod = tx .* rxCarrier;

%=========================================================================
%% Filter (lowpass)

filter_name = sprintf("./lowpass_rx.mat");
if isRunningInOctave()
    disp("Running in GNU Octave - loading lowpass filter from folder!");
    filter_lp_rx = load(filter_name);
else
    ripple_pass_dB = 0.1;                % Passband ripple in dB
    ripple_stop_db = 50;                 % Stopband ripple in dB
    cutoff_freqs   = [fmsg*10 25*fmsg];  % Cutoff frequencies

    filter_lp_rx = getLPfilter( ...
        ripple_pass_dB, ripple_stop_db, ...
        cutoff_freqs, fs, EnableFilterAnalyzeGUI);

    % Save the filter coefficients
    save(filter_name,'filter_lp_rx','-ascii');
end

%Nfilt = 100;
%wcut = fmsg*15/fs;
%filter_lp = fir1(Nfilt, wcut);
%fvtool(filter_lp,1);

rx_msg = filter(filter_lp_rx,1, rx_msg_demod);

%=========================================================================
%% Compensate filter delay

grp_delay = (length(filter_lp_rx)-1)/2;
msg_del = [zeros(grp_delay,1); msg(1:end-grp_delay)];

%=========================================================================
%% Analysis

%-------------------------------------------------------------------------
fig_title = 'Tx time domain signal';
fig_time_tx = figure('Name',fig_title);
hold on;
plot(tn/fs, txCarrier, 'r--', 'DisplayName', 'txCarrier');
plot(tn/fs, msg,       'm--', 'DisplayName', 'msg');
plot(tn/fs, tx,        'b',   'DisplayName', 'tx');
grid on;
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

%-------------------------------------------------------------------------
fig_title = 'Carriers';
fig_time_carr = figure('Name',fig_title);
hold on;
plot(tn/fs, txCarrier, 'b', 'DisplayName', 'txCarrier');
plot(tn/fs, rxCarrier, 'r', 'DisplayName', 'rxCarrier');
grid on;
xlim([0,0.0001]);
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

%-------------------------------------------------------------------------
fig_title = 'Rx time domain signal';
fig_time_rx = figure('Name',fig_title);
hold on;
plot(tn/fs, msg_del,      'b', 'DisplayName', 'msg\_del');
plot(tn/fs, rx_msg,       'r', 'DisplayName', 'rx\_msg');
grid on;
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

%% Arrange all plots on the display

if ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

disp('Done.');
