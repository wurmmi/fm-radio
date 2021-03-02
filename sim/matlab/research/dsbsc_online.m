                                    % =================================== %
                                    % PROGRAMMED BY SHEIKH MUKHTAR HUSSIN %
                                    % =================================== %
clear;
close all;
clc;

% ===============================
% DSBSC MODULATION SIGNAL 2 (Tri)
% ===============================

fs = 10e3;

t1 = -0.02:1.e-4:0;
t2 = 0:1.e-4:0.02;
Ta = 0.01;

m1 = 1 - abs((t1+Ta)/Ta);
m1 = [zeros([1 200]),m1,zeros([1 400])];
m2 = 1 - abs((t2-Ta)/Ta);
m2 = [zeros([1 400]),m2,zeros([1 200])];

msg = m1 - m2;

t = -0.04:1.e-4:0.04;
fc = 500;                           % Frquency of carrier wave


% Modulation
txCarrier = cos(2*fc*pi*t);
dsb =  2*msg.*txCarrier;

% ====================================
% De-Modulation By Synchoronous Method
% ====================================

phi_rx = 40*pi/180;
rxCarrier = cos(2*fc*pi*t + phi_rx);

dem = dsb.*rxCarrier;

% ==============================
% Filtering out High Frequencies
% ==============================

a = fir1(25,100*1/fs);
b = 1;
rec = filter(a,b,dem);

Nfft = length(t);
Nfft = 2^ceil(log2(Nfft));
f = (-Nfft/2:Nfft/2-1)/(Nfft*1/fs);
mF = fftshift(fft(msg,Nfft));              % Frequency Responce of Message Signal
cF =  fftshift(fft(txCarrier,Nfft));       % Frequency Responce of Carrier Signal
dsbF = fftshift(fft(dsb,Nfft));            % Frequency Responce of DSBSC
recF = fftshift(fft(rec,Nfft));            % Frequency Responce of Recovered Message Signal

% =============================
% Ploting signal in time domain
% =============================

figure(1);
subplot(2,2,1);                                    
plot(t,msg);
title('Message Signal');
xlabel('{\it t} (sec)');
ylabel('m(t)');
grid;

subplot(2,2,2);
plot(t,dsb);
title('DSBSC');
xlabel('{\it t} (sec)');
ylabel('DSBSC');
grid;

subplot(2,2,3);
plot(t,dem);
title('De-Modulated');
xlabel('{\it t} (sec)');
ylabel('dem')
grid;

subplot(2,2,4);
plot(t,rec, 'r'); hold on;
plot(t,msg, 'b--');
title('Recovered Signal');
xlabel('{\it t} (sec)');
ylabel('m(t)');
grid;

% ================================
% Ploting Freq Responce of Signals
% ================================

figure(2);
subplot(2,2,1);                                         
plot(f,abs(mF));
title('Freq Responce of Message Signal');
xlabel('f(Hz)');
ylabel('M(f)');
grid;
axis([-600 600 0 200]);

subplot(2,2,2);
plot(f,abs(cF));
title('Freq Responce of Carrier');
grid;
xlabel('f(Hz)');
ylabel('C(f)');
axis([-600 600 0 500]);

subplot(2,2,3);
plot(f,abs(dsbF));
title('Freq Responce of DSBSC');
xlabel('f(Hz)');
ylabel('DSBSC(f)');
grid;
axis([-600 600 0 200]);

subplot(2,2,4);
plot(f,abs(mF),   'b--'); hold on;
plot(f,abs(recF), 'r'); 
title('Freq Responce of Recovered Signal');
xlabel('f(Hz)');
ylabel('M(f)');
grid;
axis([-600 600 0 200]);


%% Arrange all plots on the display

if ~isRunningInOctave()
    autoArrangeFigures(1,2,2);
end

disp('Done.');
