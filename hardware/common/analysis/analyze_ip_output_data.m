%-------------------------------------------------------------------------
% File        : analyze_ip_output_data.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Loads data file that was recorded from the
%               FPGA IP output by the firmware and analyzes it.
%-------------------------------------------------------------------------

%% Prepare environment
clear; 
close all; 
clc;

%=========================================================================
%% Read file

% Read binary file
fid = fopen('./data_rec_from_ip/HLS.TXT','rb');
if fid == -1
    assert(false, sprintf("Could not find file '%s'!", filename));
end
y = fread(fid,'uint32=>uint32');

% Split 32 bit into 2x16 bit (left and right channel)
y_uint16 = typecast(y,'uint16');
audioDataLeft  = y_uint16(1:2:end);
audioDataRight = y_uint16(2:2:end);

%=========================================================================
%% Plots

fig_title = 'Time domain signal';
fig_audio_time = figure('Name',fig_title);
title(fig_title);

ymax = 2;
ax1 = subplot(2,1,1);
plot(audioDataLeft,  'r', 'DisplayName', 'audioDataL');
grid on; legend();
ylim([-ymax,ymax]);
ax2 = subplot(2,1,2);
plot(audioDataRight, 'g', 'DisplayName', 'audioDataR');
grid on; legend();
ylim([-ymax,ymax]);

xlabel('time [s]');
grid on; legend();
linkaxes([ax1,ax2],'x');
saveas(fig_audio_time, "./time_audio.png");
