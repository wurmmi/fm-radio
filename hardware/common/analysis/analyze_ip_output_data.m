%-------------------------------------------------------------------------
% File        : analyze_ip_output_data.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Loads data file that was recorded from the
%               FPGA IP output by the firmware.
%               Compares this data with the simulation by the Matlab model.
%-------------------------------------------------------------------------

%% Prepare environment
clear; 
close all; 
clc;

%=========================================================================
%% Read data
%=========================================================================

y = loadFile('./data_rec_from_ip/HLS.TXT',"IP");
audioDataLeft_IP  = y(:,1);
audioDataRight_IP = y(:,2);

audioDataLeft_Matlab  = loadFile('../../../sim/matlab/verification_data/rx_audio_L.txt', "Matlab");
audioDataRight_Matlab = loadFile('../../../sim/matlab/verification_data/rx_audio_R.txt', "Matlab");

%% =========================================================================
% Plots
%% =========================================================================

fig_title = 'IP Audio Output';
fig_audio_time = figure('Name',fig_title);
sgtitle(fig_title);

ymax = max([audioDataLeft_IP;audioDataRight_IP])*1.1;
ymin = min([audioDataLeft_IP;audioDataRight_IP])*1.1;
ax1 = subplot(2,1,1); hold on;
plot(audioDataLeft_IP,     'r', 'DisplayName', 'left (IP)');
plot(audioDataLeft_Matlab, 'b', 'DisplayName', 'left (Matlab)');
grid on; legend();
ylim([ymin,ymax]);
ax2 = subplot(2,1,2); hold on;
plot(audioDataRight_IP,     'r', 'DisplayName', 'right (IP)');
plot(audioDataRight_Matlab, 'b', 'DisplayName', 'right (Matlab)');
grid on; legend();
ylim([ymin,ymax]);

xlabel('time [s]');
grid on; legend();
linkaxes([ax1,ax2],'x');
saveas(fig_audio_time, "./time_audio.png");
