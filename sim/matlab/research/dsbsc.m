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
EnableEqirippleFIR     = true;
EnableTriangleMessage  = true;

EnablePlotPhaseRecover   = false;
EnablePlotPhaseShiftTest = false;

% Common
fs = 196608; % Nfft * x

n_sec = 0.03;
tn    = (0:1:fs*n_sec-1).';

% Tx carrier
fc_tx  = 57e3;
A_tx_c = 1;

% Rx carrier
fc_rx  = 57e3;       % <-- ADAPT FREQUENCY ERROR
phi_rx = 30*pi/180;  % <-- ADAPT PHASE ERROR
A_rx_c = 1;

%=========================================================================
%% Message signal

fmsg = 57e3/48;
Amsg = 1;

if EnableTriangleMessage
    %tmsg = (0:1:n_sec*2/4*fs-1).';
    %msg  = Amsg * sawtooth(2*pi*fmsg/fs*tmsg+pi/2,1/2);
    %msg  = [zeros(n_sec/4*fs,1); msg; zeros(n_sec/4*fs,1)];
    
    msg  = Amsg * sawtooth(2*pi*fmsg/fs*tn, 1/2);
else
    msg  = Amsg * cos(2*pi*fmsg/fs*tn);
end

%=========================================================================
%% Modulate

txCarrier = A_tx_c * cos(2*pi*fc_tx/fs*tn);

tx = msg .* txCarrier;

%=========================================================================
%% Demodulate

rxCarrier = A_rx_c * cos(2*pi*fc_rx/fs*tn + phi_rx);

rx_msg_demod = 2 * tx .* rxCarrier;

%=========================================================================
%% Filter (lowpass)

% Create filter
if EnableEqirippleFIR
    filter_name = sprintf("./lowpass_rx.mat");
    if isRunningInOctave()
        disp("Running in GNU Octave - loading lowpass filter from folder!");
        filter_lp_rx = load(filter_name);
    else
        ripple_pass_dB = 0.1;                % Passband ripple in dB
        ripple_stop_db = 50;                 % Stopband ripple in dB
        cutoff_freqs   = [fmsg*5 fmsg*20]; % Cutoff frequencies
        
        filter_lp_rx = getLPfilter( ...
            ripple_pass_dB, ripple_stop_db, ...
            cutoff_freqs, fs, EnableFilterAnalyzeGUI);
        
        % Save the filter coefficients
        save(filter_name,'filter_lp_rx','-ascii');
    end
else
    Nfilt = 100;
    wcut = fmsg*10/fs;
    filter_lp_rx = fir1(Nfilt, wcut);
    if EnableFilterAnalyzeGUI
        fvtool(filter_lp_rx,1);
    end
end

% Filter
rx_msg = filter(filter_lp_rx,1, rx_msg_demod);

%=========================================================================
%% Compensate filter delay

grp_delay = (length(filter_lp_rx)-1)/2;
msg_del = [zeros(grp_delay,1); msg(1:end-grp_delay)];

%=========================================================================
%% Carrier shift test

phi_pilot = 80*pi/180;

carrier19k = cos(2*pi*19e3/fs*tn + phi_pilot  );
carrier38k = cos(2*pi*38e3/fs*tn + phi_pilot*2);
carrier57k = cos(2*pi*57e3/fs*tn + phi_pilot*3);

%=========================================================================
%% Analysis

% Calculations
Nfft      = 4096*4;
fft_bin = fs/Nfft;
% fs = Nfft * x;
fprintf('fft_bin: %.2f Hz\n', fft_bin);

%Nfft      = 2^nextpow2(Nfft);
fft_freqs = (-Nfft/2:Nfft/2-1)/(Nfft*1/fs);

fft_msg    = abs(fftshift( fft( hanning(length(msg)) .* msg,    Nfft) ))/Nfft;
fft_msg_rx = abs(fftshift( fft( hanning(length(msg)) .* rx_msg, Nfft) ))/Nfft;


% Plots
%-------------------------------------------------------------------------
fig_title = 'Tx time domain signal';
fig_time_tx = figure('Name',fig_title);
hold on;
plot(tn/fs, txCarrier, 'r', 'DisplayName', 'txCarrier');
plot(tn/fs, msg,       'g', 'DisplayName', 'msg');
plot(tn/fs, tx,        'b',   'DisplayName', 'tx');
grid on;
xlim([1/fmsg*2,1/fmsg*5]);
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

%-------------------------------------------------------------------------
if EnablePlotPhaseRecover
    fig_title = 'Carrier phase recovery';
    fig_time_carr_recovery = figure('Name',fig_title);
    hold on;
    plot(tn/fs, txCarrier, 'b', 'DisplayName', 'txCarrier');
    plot(tn/fs, rxCarrier, 'r', 'DisplayName', 'rxCarrier');
    grid on;
    xlim([0,1/19e3*4]);
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

%-------------------------------------------------------------------------
if EnablePlotPhaseShiftTest
    fig_title = 'Carrier phase shift test';
    fig_time_carr_test = figure('Name',fig_title);
    hold on;
    plot(tn/fs, carrier19k, 'r', 'DisplayName', 'carrier19k');
    plot(tn/fs, carrier38k, 'g', 'DisplayName', 'carrier38k');
    plot(tn/fs, carrier57k, 'b', 'DisplayName', 'carrier57k');
    grid on;
    xlim([0,1/19e3*2]);
    title(fig_title);
    xlabel('time [s]');
    ylabel('amplitude');
    legend();
end

%-------------------------------------------------------------------------
fig_title = 'Rx time domain signal';
fig_time_rx = figure('Name',fig_title);
hold on;
plot(tn/fs, msg_del, 'b', 'DisplayName', 'msg\_del');
plot(tn/fs, rx_msg,  'r', 'DisplayName', 'rx\_msg');
plot(tn/fs, cos(2*pi*abs(fc_tx-fc_rx)/fs*tn),  'g', 'DisplayName', 'Frequency error artifact');
grid on;
%xlim([0,1/fmsg*4]);
title(fig_title);
xlabel('time [s]');
ylabel('amplitude');
legend();

fig_title = 'Frequency domain signal';
fig_freq_tx = figure('Name',fig_title);
hold on;
xline(-fmsg,'k--','-fmsg');
xline( fmsg,'k--','fmsg');
yline(cos(phi_rx)*max(fft_msg), 'k--', 'power loss due to Rx phase error')
h0 = plot(fft_freqs, fft_msg,    'b', 'DisplayName', 'msg tx');
h1 = plot(fft_freqs, fft_msg_rx, 'r', 'DisplayName', 'msg rx');
grid on;
xlim([0,fmsg*2]);
title(fig_title);
xlabel('Frequency [Hz]');
ylabel('magnitude');
legend([h0,h1],'Location','east');


%% Arrange all plots on the display

if ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

disp('Done.');
