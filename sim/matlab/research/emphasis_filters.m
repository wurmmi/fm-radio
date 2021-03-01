%-------------------------------------------------------------------------
% File        : emphasis_filters.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Creates Pre- and De-emphasis filters.
%               https://lehrer.bulme.at/~tr/SDR/PRE_DE_EMPHASIS_web.html
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

%% Settings

%fs  = 970.2e3;       % sampling frequency
fs  = 625e3;         % sampling frequency
tau = 50e-6;         % time constant (50µs in Europe, 75us in US)
fc  = 1/(2*pi*tau);  % cut-off frequency

%% Transfer functions of analog and digital filters

k=fs/(2*pi*fc);

pre_analog  = tf([1/(2*pi*fc) 1], 1,'variable','s');
pre_digital = tf([1+k -k],[1 0],1/fs,'variable','z^-1');
de_digital  = tf([1 0],[1+k -k],1/fs,'variable','z^-1');

pre_n_de = pre_digital * de_digital;

% Version from paper (NOTE: only valid for fs=625e3 !!!)
a0 =  1;
a1 = -0.9685612914;
b0 =  0.0157493543;
b1 =  0.0157493543;

b_num = [b0, b1];
a_den = [a0, a1];
de_paper = tf(b_num, a_den, 1/fs);
%%%

disp('Filter functions:');
pre_digital   % x 
de_digital    % 1/x (exact inversion of pre-emphasis filter)
pre_n_de      % x/x=1 (filters cancel each other)
de_paper

%% Bode-Diagram of all filters in comparison 

figure;
h = bodeplot(pre_analog, pre_digital, de_digital, de_paper, pre_n_de);
grid on;
setoptions(h,'FreqUnits','Hz');
legend('analog pre-emphasis','digital pre-emphasis','digital de-emphasis', 'digital de-paper', 'digital pre and de');
