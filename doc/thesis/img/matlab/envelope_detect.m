%-------------------------------------------------------------------------
% File        : envelope_detect.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Envelope detector time diagrams
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

addpath(genpath('../../../../sim/matlab/helpers/'));

%=========================================================================
%% Settings

% Simulation Options
EnableFilterAnalyzeGUI = false;

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
Nfilt = 150;
wcut = 2*fmsg/fs;
filter_lp = fir1(Nfilt, wcut);
if EnableFilterAnalyzeGUI
    fvtool(filter_lp,1);
end

% Filter
envelope = filter(filter_lp,1, rf_signal_thresh);

%=========================================================================
%% Compensate filter delay

grp_delay = (length(filter_lp)-1)/2;
msg_del = [zeros(grp_delay,1); msg(1:end-grp_delay)];

%=========================================================================
%% Analysis
set(0,'defaulttextinterpreter','latex')

% Plots
%-------------------------------------------------------------------------
dir_output = './out';
fontsize = 16;

fig_title = 'RF signal';
fig_time_rf = figure('Name',fig_title);
hold on;
plot(tn/fs, msg,       'r--', 'LineWidth',2, 'DisplayName', 'msg');
plot(tn/fs, rf_signal, 'b', 'LineWidth',1, 'DisplayName', 'rf\_signal');
%grid on;
xlim([-0.1/fmsg,3/fmsg]);
ylim([-3,3]);
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
%box on;
title(fig_title, 'FontSize',fontsize);
xlabel('time [s]','FontSize',fontsize);
ylabel('amplitude','FontSize',fontsize);
set(gca,'XTickLabel',[],'YTickLabel',[])
legend();
saveas(fig_time_rf, sprintf("%s/%s",dir_output, "fig_time_rf.png"));

fig_title = 'Half-wave rectified';
fig_time_rf_thresh = figure('Name',fig_title);
hold on;
plot(tn/fs, rf_signal_thresh, 'b', 'DisplayName', 'rf\_signal\_thresh');
%grid on;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlim([-0.1/fmsg,3/fmsg]);
ylim([-1,3]);
title(fig_title, 'FontSize',fontsize);
Ylm=ylim();                          % get x, y axis limits 
Xlm=xlim();                          % so can position relative instead of absolute
Xlb=mean(Xlm);                       % set horizontally at midpoint
Ylb=0.99*Ylm(1);                     % and just 1% below minimum y value
xlabel('time [s]','FontSize',fontsize, 'Position',[Xlb Ylb],'HorizontalAlignment','center');
ylabel('amplitude','FontSize',fontsize);
set(gca,'XTickLabel',[],'YTickLabel',[])
%hXLbl=xlabel('XLabel',,'VerticalAlignment','top','HorizontalAlignment','center'); 
legend();
saveas(fig_time_rf_thresh, sprintf("%s/%s",dir_output, "fig_time_rf_thresh.png"));

fig_title = 'Detected envelope';
fig_time_envelope = figure('Name',fig_title);
hold on;
plot(tn/fs, envelope, 'b', 'DisplayName', 'envelope');
%grid on;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlim([-0.1/fmsg,3/fmsg]);
ylim([-0.1,3]);
title(fig_title, 'FontSize',fontsize);
xlabel('time [s]','FontSize',fontsize);
ylabel('amplitude','FontSize',fontsize);
set(gca,'XTickLabel',[],'YTickLabel',[])
legend();
saveas(fig_time_envelope, sprintf("%s/%s",dir_output, "fig_time_envelope.png"));


%-------------------------------------------------------------------------

%% Arrange all plots on the display

if ~isRunningInOctave()
    autoArrangeFigures(2,3,2);
end

disp('Done.');
