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

%--- from FPGA hardware IP
% HLS
y = loadFile('./data_rec_from_ip/HLS.TXT',"IP");
audioDataLeft_HLS_IP  = y(:,1);
audioDataRight_HLS_IP = y(:,2);

% VHDL
y = loadFile('./data_rec_from_ip/VHDL.TXT',"IP");
audioDataLeft_VHDL_IP  = y(:,1);
audioDataRight_VHDL_IP = y(:,2);

%--- from HDL simulation
% HLS
audioDataLeft_HLS_SIM  = loadFile('../../hls/tb/output/data_out_audio_L.txt',"Matlab");
audioDataRight_HLS_SIM = loadFile('../../hls/tb/output/data_out_audio_R.txt',"Matlab");

% VHDL
%y = loadFile('./data_rec_from_ip/VHDL.TXT',"IP");
%audioDataLeft_VHDL_IP  = y(:,1);
%audioDataRight_VHDL_IP = y(:,2);

%--- from Matlab
audioDataLeft_Matlab  = loadFile('../../../sim/matlab/verification_data/rx_audio_L_long.txt', "Matlab");
audioDataRight_Matlab = loadFile('../../../sim/matlab/verification_data/rx_audio_R_long.txt', "Matlab");


%% =========================================================================
% Plots
%% =========================================================================

% Shift by N samples for alignment
audioDataLeft_Matlab  = circshift(audioDataLeft_Matlab, -4);
audioDataRight_Matlab = circshift(audioDataRight_Matlab,-4);

audioDataLeft_HLS_SIM  = circshift(audioDataLeft_HLS_SIM, 1);
audioDataRight_HLS_SIM = circshift(audioDataRight_HLS_SIM,1);

% Plot
fig_title = 'IP Audio Output';
fig_audio_time = figure('Name',fig_title);
sgtitle(fig_title);

ymax = max([audioDataLeft_HLS_IP;audioDataRight_HLS_IP])*1.1;
ymin = min([audioDataLeft_HLS_IP;audioDataRight_HLS_IP])*1.1;

ax1 = subplot(2,1,1); hold on;
title('Left channel');
plot(audioDataLeft_Matlab,  'b',  'DisplayName', 'Matlab', 'LineWidth',2);
plot(audioDataLeft_HLS_IP,  'r',  'DisplayName', 'HLS IP');
plot(audioDataLeft_HLS_SIM, 'r--','DisplayName', 'HLS SIM');
plot(audioDataLeft_VHDL_IP, 'g',  'DisplayName', 'VHDL IP');
%plot(audioDataLeft_SIM_VHDL,'g--','DisplayName', 'VHDL SIM');
grid on; legend();
ylim([ymin,ymax]);

ax2 = subplot(2,1,2); hold on;
title('Right channel');
plot(audioDataRight_Matlab,  'b', 'DisplayName', 'Matlab', 'LineWidth',2);
plot(audioDataRight_HLS_IP,  'r',  'DisplayName', 'HLS IP');
plot(audioDataRight_HLS_SIM, 'r--','DisplayName', 'HLS SIM');
plot(audioDataRight_VHDL_IP, 'g',  'DisplayName', 'VHDL IP');
%plot(audioDataRight_SIM_VHDL,'g--','DisplayName', 'VHDL SIM');
grid on; legend();
ylim([ymin,ymax]);

xlabel('time [s]');
grid on; legend();
linkaxes([ax1,ax2],'xy');
saveas(fig_audio_time, "./time_audio.png");
