%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File   : fm_transceiver.m
% Author : Michael Wurm <wurm.michael95@gmail.com>
% Topic  : FM-Radio Sender and Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prepare environment
clear; close all; clc;
%restoredefaultpath;

addpath(genpath('./helpers/auto-arrange-figs/'));

%% Settings
% Channel
fc_oe3 = 98.1e6;

fs    = 1e6;
n_sec = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Audio stream data
t = 0:1/fs:n_sec-1;

audioFreqLHz = 500;
audioDataL   = 1 * sin(2*pi*audioFreqLHz/fs*t);

audioFreqRHz = 500;
audioDataR   = 1 * sin(2*pi*audioFreqRHz/fs*t);

audioData = audioDataL + audioDataR;

%% 19kHz pilot tone

pilotFreqHz = 19000;
pilotTone = 1 * sin(2*pi*pilotFreqHz/fs);

%% Difference signal (for stereo)

audioDiff = audioDataL - audioDataR;

% Modulate it to 38 kHz
audioDiffMod = audioDiff * 0.5; %TODO

%% Radio Data Signal (RDS)
% TODO

%% FM channel
% Sum up all signal parts

fmChannel = audioData + pilotTone + audioDiffMod;

%% FM channel spectrum




figure();






%% Arrange all plots on the display
autoArrangeFigures(4,4,1);
