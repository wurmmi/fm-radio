%-------------------------------------------------------------------------
% File        : generateHinzTrillerFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Stores the Hinz Triller in an audio file (*.wav).
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

%% Settings
fs                  = 48e3;
fc_hinz             = 2350;
f_deviation         = 123;
hinz_duration_on_s  = 1.2;
hinz_duration_off_s = 0.5;

%% Create the Hinz Triller

tn        = (0:1:hinz_duration_on_s*fs-1).';
hinz_tone = sin(2*pi*f_deviation/fs*tn);

% FM modulation
hinz_tone_int = cumsum(hinz_tone)/fs;
hinz_triller  = cos(2*pi*fc_hinz/fs*tn + (2*pi*f_deviation*hinz_tone_int));

%% Save to file

% ON sequence
hinz_filename = sprintf('../recordings/wav/hinz_triller_on_%d.wav',fs);
audiowrite(hinz_filename, hinz_triller, fs);

% OFF sequence
hinz_filename = sprintf('../recordings/wav/hinz_triller_off_%d.wav',fs);

idx_end = hinz_duration_off_s*fs;
audiowrite(hinz_filename, hinz_triller(1:idx_end), fs);

disp('Done.');
