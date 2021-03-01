%-------------------------------------------------------------------------
% File        : fm_test.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Testing different ways to modulate FM.
%-------------------------------------------------------------------------

%% Prepare environment
clear; close all; clc;

addpath(genpath('../helpers/auto-arrange-figs/'));

%=========================================================================
%% Settings
n_sec   = 1e-6;
fc      = 98.1e6;
osr     = 100;
fs      = fc*osr;
delta_f = 75e3;

%=========================================================================
%% Common
tn = (0:1:n_sec*fs-1).';

data = sin(2*pi*5e3/fs*tn) + sin(2*pi*19e3/fs*tn) + ...
       sin(2*pi*38e3/fs*tn) + sin(2*pi*57e3/fs*tn);

modindex = delta_f / (57e3);

%=========================================================================
%% 0: Using MATLAB fmmod

y0 = fmmod(data, fc, fs, delta_f);

%=========================================================================
%% 1: Manual, using integral

data_integrated = cumsum(data)/fs;

% FM modulation
y1 = cos(2*pi*fc/fs*tn + (2*pi*delta_f*data_integrated));

%=========================================================================
%% Analysis

fig_time = figure('Name','Time domain signal');
grid on; hold on;
title('Time domain signal');
plot(tn/fs, y0, 'r', 'DisplayName', 'y0: fmmod');
plot(tn/fs, y1, 'b', 'DisplayName', 'y1: integral');
plot(tn/fs, data_integrated, 'g', 'DisplayName', 'y1: data\_integrated');
xlabel('time [s]');
ylabel('amplitude');
legend();
xlim([0 inf]);

%% Arrange all plots on the display
autoArrangeFigures(2,1,1);
