%-------------------------------------------------------------------------
% File        : envelope_detect.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Envelope detector time diagrams
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

addpath(genpath('../helpers/'));

%=========================================================================
%% Settings

dir_output = '../../../doc/thesis/img/matlab';

% Simulation Options
EnableFilterAnalyzeGUI = false;
EnableShowFigures      = true;
EnablePlotSaveSVG      = true;
EnablePlotSavePDF      = false;
EnablePlotSavePNG      = false;

% Common
fs = 1e6;

n_sec = 0.01;
tn    = (0:1:fs*n_sec-1).';

% Modulation carrier
fc  = 15e3;
A_c = 1;

%=========================================================================
%% Message signal

fmsg = 1e3;
Amsg = 1;
msg  = 1.4 + Amsg * cos(2*pi*fmsg/fs*tn);

%=========================================================================
%% Modulate

carrier = A_c * cos(2*pi*fc/fs*tn);

rf_signal = msg .* carrier;

%=========================================================================
%% Thresholding

rf_signal_thresh = rf_signal;             % copy entire signal
rf_signal_thresh(rf_signal_thresh<0) = 0; % threshold

%=========================================================================
%% Filter (lowpass)

% Create filter
Nfilt = 116;
wcut = 2*fmsg/fs;
filter_lp = fir1(Nfilt, wcut);
if EnableFilterAnalyzeGUI
    fvtool(filter_lp,1);
end

% Filter
envelope = filter(filter_lp,1, rf_signal_thresh) * 2;

%=========================================================================
%% Compensate filter delay

grp_delay = (length(filter_lp)-1)/2;
msg_del = [zeros(grp_delay,1); msg(1:end-grp_delay)];

%=========================================================================
%% Analysis
set(0,'defaulttextinterpreter','latex')

% Plots
%-------------------------------------------------------------------------
fontsize = 22;

fig_title = 'RF signal';
fig_time_rf = figure('Name',fig_title);
hold on;
plot(tn/fs, msg,       'r--', 'LineWidth',3, 'DisplayName', 'msg');
plot(tn/fs, rf_signal, 'b',   'LineWidth',1, 'DisplayName', 'rf\_signal');
xlim([-0.1/fmsg,3/fmsg]);
ylim([-3,3]);
fig_time_rf = format_plot(fig_time_rf,fig_title,fontsize);
if EnablePlotSaveSVG saveas(fig_time_rf, sprintf("%s/%s",dir_output, "fig_1_time_rf.svg"),'svg'); end
if EnablePlotSavePDF saveas(fig_time_rf, sprintf("%s/%s",dir_output, "fig_1_time_rf.pdf"),'pdf'); end
if EnablePlotSavePNG exportgraphics(fig_time_rf, sprintf("%s/%s",dir_output, "fig_1_time_rf.png")); end

fig_title = 'Half-wave rectified';
fig_time_rf_thresh = figure('Name',fig_title);
hold on;
plot(tn/fs, msg,              'r--', 'LineWidth',3, 'DisplayName', 'msg');
plot(tn/fs, rf_signal_thresh, 'b',   'LineWidth',1, 'DisplayName', 'rf\_signal\_thresh');
xlim([-0.1/fmsg,3/fmsg]);
ylim([-1,3]);
fig_time_rf_thresh = format_plot(fig_time_rf_thresh,fig_title,fontsize);
if EnablePlotSaveSVG saveas(fig_time_rf_thresh, sprintf("%s/%s",dir_output, "fig_2_time_rf_thresh.svg"),'svg'); end
if EnablePlotSavePDF saveas(fig_time_rf_thresh, sprintf("%s/%s",dir_output, "fig_2_time_rf_thresh.pdf"),'pdf'); end
if EnablePlotSavePNG exportgraphics(fig_time_rf_thresh, sprintf("%s/%s",dir_output, "fig_2_time_rf_thresh.png")); end

fig_title = 'Detected envelope';
fig_time_envelope = figure('Name',fig_title);
hold on;
plot(tn/fs, envelope, 'r', 'LineWidth',3, 'DisplayName', 'envelope');
xlim([-0.1/fmsg,3/fmsg]);
ylim([-1,3]);
fig_time_envelope = format_plot(fig_time_envelope,fig_title,fontsize);
if EnablePlotSaveSVG saveas(fig_time_envelope, sprintf("%s/%s",dir_output, "fig_3_time_envelope.svg"),'svg'); end
if EnablePlotSavePDF saveas(fig_time_envelope, sprintf("%s/%s",dir_output, "fig_3_time_envelope.pdf"),'pdf'); end
if EnablePlotSavePNG exportgraphics(fig_time_envelope, sprintf("%s/%s",dir_output, "fig_3_time_envelope.png")); end


%-------------------------------------------------------------------------

%% Arrange all plots on the display
if EnableShowFigures == false
    close all;
elseif ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

disp('Done.');
