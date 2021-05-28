%-------------------------------------------------------------------------
% File        : wav_to_txt.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Convert audio data from .wav file to .txt
%-------------------------------------------------------------------------

%% Prepare environment
clear; close all; clc;

%=========================================================================
%% Load WAV and store as TXT

filenames = {
  '../sdk/fm_radio_app/resource/wav/cantina_band_44100',
  '../sdk/fm_radio_app/resource/wav/cantina_band_48000'
};


for i = 1:length(filenames)  
  filename = filenames{i};
  filename_wav = [filename '.wav'];
  filename_txt = [filename '.txt'];

  fprintf("Converting file: %s\n", filename_wav);
  
  [data, fs] = audioread(filename_wav);
  save(filename_txt, 'data', '-ascii');
end 
  
disp('Done.');
