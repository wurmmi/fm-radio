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

% --- IP output data ---

% Read binary file
fid = fopen('./data_rec_from_ip/HLS.TXT','rb');
if fid == -1
    assert(false, sprintf("Could not find file '%s'!", filename));
end
y = fread(fid,'int32=>int32');
fclose(fid);

% Split 32 bit into 2x16 bit (left and right channel)
y_int16  = typecast(y,'int16');

% Convert to double and scale with 16 bit (2.14 fixed point format!)
y_double = double(y_int16)/2^14 * -1; % INVERT
audioDataLeft_IP  = y_double(1:2:end);
audioDataRight_IP = y_double(2:2:end);

% --- Matlab simulation data ---

fid = fopen('../../../sim/matlab/verification_data/rx_audio_L.txt','rb');
if fid == -1
    assert(false, sprintf("Could not find file '%s'!", filename));
end
audioDataLeft_Matlab = fscanf(fid,"%f\n");
fclose(fid);

fid = fopen('../../../sim/matlab/verification_data/rx_audio_R.txt','rb');
if fid == -1
    assert(false, sprintf("Could not find file '%s'!", filename));
end
audioDataRight_Matlab = fscanf(fid,'%f\n');
fclose(fid);


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
