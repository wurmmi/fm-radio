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
audioDataLeft_IP_HLS  = y(:,1);
audioDataRight_IP_HLS = y(:,2);

y = loadFile('./data_rec_from_ip/VHDL.TXT',"IP");
audioDataLeft_IP_VHDL  = y(:,1);
audioDataRight_IP_VHDL = y(:,2);

audioDataLeft_Matlab  = loadFile('../../../sim/matlab/verification_data/rx_audio_L.txt', "Matlab");
audioDataRight_Matlab = loadFile('../../../sim/matlab/verification_data/rx_audio_R.txt', "Matlab");

%% =========================================================================
% Plots
%% =========================================================================

fig_title = 'IP Audio Output';
fig_audio_time = figure('Name',fig_title);
sgtitle(fig_title);

ymax = max([audioDataLeft_IP_HLS;audioDataRight_IP_HLS])*1.1;
ymin = min([audioDataLeft_IP_HLS;audioDataRight_IP_HLS])*1.1;
ax1 = subplot(2,1,1); hold on;
plot(audioDataLeft_IP_HLS, 'r', 'DisplayName', 'left (IP HLS)');
plot(audioDataLeft_IP_VHDL,'g', 'DisplayName', 'left (IP VHDL)');
plot(audioDataLeft_Matlab, 'b', 'DisplayName', 'left (Matlab)');
grid on; legend();
ylim([ymin,ymax]);
ax2 = subplot(2,1,2); hold on;
plot(audioDataRight_IP_HLS, 'r', 'DisplayName', 'right (IP HLS)');
plot(audioDataRight_IP_VHDL,'g', 'DisplayName', 'right (IP VHDL)');
plot(audioDataRight_Matlab, 'b', 'DisplayName', 'right (Matlab)');
grid on; legend();
ylim([ymin,ymax]);

xlabel('time [s]');
grid on; legend();
linkaxes([ax1,ax2],'x');
saveas(fig_audio_time, "./time_audio.png");
