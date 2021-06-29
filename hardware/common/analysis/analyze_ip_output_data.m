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

%% Settings
EnableZoomToBegin = true;

%=========================================================================
%% Read data
%=========================================================================

%--- from FPGA hardware IP ---
% HLS
y = loadFile('./data_rec_from_fpga/HLS.TXT',"IP");
audioDataLeft_HLS_FPGA  = y(:,1);
audioDataRight_HLS_FPGA = y(:,2);

% VHDL
y = loadFile('./data_rec_from_fpga/VHDL.TXT',"IP");
audioDataLeft_VHDL_FPGA  = y(:,1);
audioDataRight_VHDL_FPGA = y(:,2);

%--- from HDL simulation ---
% HLS
audioDataLeft_HLS_SIM  = loadFile('../../hls/tb/output/data_out_audio_L.txt',"Matlab");
audioDataRight_HLS_SIM = loadFile('../../hls/tb/output/data_out_audio_R.txt',"Matlab");

% VHDL
audioDataLeft_VHDL_SIM  = loadFile('../../vhdl/ip/tb/integration_test/sim_build/audio_L.txt',"Matlab");
audioDataRight_VHDL_SIM = loadFile('../../vhdl/ip/tb/integration_test/sim_build/audio_R.txt',"Matlab");

%--- from Matlab ---
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

audioDataLeft_VHDL_SIM  = circshift(audioDataLeft_VHDL_SIM, 1);
audioDataRight_VHDL_SIM = circshift(audioDataRight_VHDL_SIM,1);

audioDataLeft_VHDL_FPGA  = circshift(audioDataLeft_VHDL_FPGA, 3);
audioDataRight_VHDL_FPGA = circshift(audioDataRight_VHDL_FPGA,3);

% Plot
fig_title = 'Audio Output';
fig_audio_time = figure('Name',fig_title);
sgtitle(fig_title);

ymax = max([audioDataLeft_HLS_FPGA;audioDataRight_HLS_FPGA])*1.1;
ymin = min([audioDataLeft_HLS_FPGA;audioDataRight_HLS_FPGA])*1.1;

ax1 = subplot(2,1,1); hold on;
title('Left channel');
h0 = plot(audioDataLeft_Matlab,   'b',  'DisplayName', 'Matlab', 'LineWidth',2);
h1 = plot(audioDataLeft_HLS_FPGA, 'r',  'DisplayName', 'HLS FPGA');
h2 = plot(audioDataLeft_HLS_SIM,  'r--','DisplayName', 'HLS SIM');
h3 = plot(audioDataLeft_VHDL_FPGA,'g',  'DisplayName', 'VHDL FPGA');
h4 = plot(audioDataLeft_VHDL_SIM, 'g--','DisplayName', 'VHDL SIM');
xline(length(audioDataLeft_HLS_FPGA),'k--','FPGA');
xline(length(audioDataLeft_HLS_SIM), 'k--','HLS SIM');
xline(length(audioDataLeft_VHDL_SIM),'k--','VHDL SIM');
grid on; legend([h0,h1,h2,h3,h4],'Location','east');
ylim([ymin,ymax]);

ax2 = subplot(2,1,2); hold on;
title('Right channel');
h0 = plot(audioDataRight_Matlab,   'b',  'DisplayName', 'Matlab', 'LineWidth',2);
h1 = plot(audioDataRight_HLS_FPGA, 'r',  'DisplayName', 'HLS FPGA');
h2 = plot(audioDataRight_HLS_SIM,  'r--','DisplayName', 'HLS SIM');
h3 = plot(audioDataRight_VHDL_FPGA,'g',  'DisplayName', 'VHDL FPGA');
h4 = plot(audioDataRight_VHDL_SIM, 'g--','DisplayName', 'VHDL SIM');
xline(length(audioDataRight_HLS_FPGA),'k--','FPGA');
xline(length(audioDataRight_HLS_SIM), 'k--','HLS SIM');
xline(length(audioDataRight_VHDL_SIM),'k--','VHDL SIM');
grid on; legend([h0,h1,h2,h3,h4],'Location','east');
ylim([ymin,ymax]);

xlabel('time [sample]');
linkaxes([ax1,ax2],'xy');
if EnableZoomToBegin
    xlim([0,length(audioDataLeft_VHDL_SIM)]);
    ylim([-0.035,0.035]);
end
saveas(fig_audio_time, "./audio_output.png");
