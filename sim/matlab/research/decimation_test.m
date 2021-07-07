%-------------------------------------------------------------------------
% File        : decimation_test.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Testing different ways for downsampling/decimation.
%-------------------------------------------------------------------------

%% Prepare environment
clear; close all; clc;

addpath(genpath('../helpers/auto-arrange-figs/'));

%=========================================================================
%% Settings

n_sec  = 0.05;
osr    = 8;
fs_src = 10000;

%=========================================================================
%% Signal

tn = (0:1:n_sec*fs_src-1)';

sig1 = 10 * sin(2*pi*100/fs_src*tn);
sig2 =  1 * sin(2*pi*200/fs_src*tn);
sig3 =  4 * sin(2*pi*400/fs_src*tn);

signal = sig1 + sig2 + sig3;

%=========================================================================
%% Common

fs_tgt = fs_src/osr;
tn_tgt = (0:1:round(n_sec*fs_tgt)-1)';

%=========================================================================
%% 0: Using MATLAB resample()

y0_res = resample(signal, 1, osr);


%=========================================================================
%% 1: Using MATLAB decimate()

y1_dec = decimate(signal, osr, 'fir');


%=========================================================================
%% 2: Manual, using filter and pick every nth sample.

% Low-pass filter
Nfilt = 50;
filter_dec = fir1(Nfilt, 1/osr);
y2_man_filt = filter(filter_dec,1, signal);

% Compensate for group delay (for test purpose only)
y2_man_filt = circshift(y2_man_filt, -Nfilt/2);

% Downsample (take every nth sample)
y2_man = y2_man_filt(1:osr:end);

%=========================================================================
%% Analysis

skip_end = 10;

fprintf("norm resample-decimate : %.3f\n", norm(y0_res(1:end-skip_end) - y1_dec(1:end-skip_end)));
fprintf("norm own-resample      : %.3f\n", norm(y0_res(1:end-skip_end) - y2_man(1:end-skip_end)));
fprintf("norm own-decimate      : %.3f\n", norm(y1_dec(1:end-skip_end) - y2_man(1:end-skip_end)));

fig_title = 'Time domain signal';
fig_time = figure('Name', fig_title);
grid on; hold on;
title(fig_title);
plot(tn/fs_src,     signal,  'm', 'DisplayName', 'signal','LineWidth',2);
plot(tn_tgt/fs_tgt, y0_res,  'r', 'DisplayName', 'y0\_res');
plot(tn_tgt/fs_tgt, y1_dec,  'b', 'DisplayName', 'y1\_dec');
plot(tn_tgt/fs_tgt, y2_man,  'g', 'DisplayName', 'y1\_man');
plot(tn/fs_src, y2_man_filt, 'g--', 'DisplayName', 'y1\_man\_filt');
xlabel('time [s]');
ylabel('amplitude');
legend();
xlim([0 inf]);

%% Arrange all plots on the display
autoArrangeFigures(1,1,1);
