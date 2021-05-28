%-------------------------------------------------------------------------
% File        : fm_transceiver.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM-Radio Sender and Receiver
%-------------------------------------------------------------------------

% TODO: draw a block diagram

% TODO: find a benchmark to compare against (--> sent vs. received)

%% Prepare environment
clear;
close all;
clc;

addpath(genpath('./helpers/'));
addpath(genpath('./filters/'));

% Octave
if isRunningInOctave()
    % Define xline function
    %xline = @(xval, varargin) line([xval xval], ylim, varargin{:});
    xline = @(xval) line([xval xval], ylim, 'color','black','linestyle','--');
end

%% Settings

% Paths
dir_filters = "./filters/stored/";
dir_output  = "./matlab_output/";

% Simulation options
EnableWriteDataFiles = true;
EnablePlots          = true;

EnableSenderSourceRecordedFile = false;
EnableSenderSourceCreateSim    = true;
EnableAudioFromFile            = true;
EnableTrafficInfoTrigger       = false;

EnableRxAudioReplay    = true;
EnableFilterAnalyzeGUI = false;
EnableSavePlotsToPng   = false;
EnablePlotsLogarithmic = true;

% Signal processing options
EnableProcessingLikeHW = true;
EnablePreEmphasis      = false;
EnableDeEmphasis       = false;
EnableManualDecimation = false;
EnableRDSDecoder       = false;

fp_config.enable     = true;
fp_config.width      = 16;
fp_config.width_frac = 14;
fp_config.max_check  = false;

% Signal parameters
n_sec = 1.7;           % 1.7s is "left channel, right channel" in audio file
osr   = 20;            % oversampling rate for fs
fs    = 48e3 * osr;    % sampling rate fs

phi_pilot = (-60)*pi/180; % phase shift between local carrier and Rx pilot

% Channel
fc_oe3 = 98.1e4;

%% Sanity checks
assert( not(EnableRDSDecoder && EnableSenderSourceRecordedFile == false), ...
    'Settings Error: RDS decoder only works with binary file data. (Simulator does not generate RDS!)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sender
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_sender();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_receiver();

% TODO: implement an implementation that is suitable for hardware
% fm_receiver_fixed_point();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Audio replay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableRxAudioReplay
    disp('### Audio Replay ###');
    
    % Create LR audio signal for output
    rx_audioReplay = zeros(length(rx_audio_L),2);
    rx_audioReplay(:,1) = rx_audio_L;
    rx_audioReplay(:,2) = rx_audio_R;
    
    sound(rx_audioReplay, fs_audio);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Store data to file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if EnableWriteDataFiles
    disp('### Write data to files ###');

    % Filter coefficients
    disp('--- Filter coefficients to VHDL');
    folder = '../../hardware/vhdl/rtl/packages';
    writeFilterCoeffsToVHDLFile(filter_bp_pilot, 'filter_bp_pilot',  folder, fp_config);
    writeFilterCoeffsToVHDLFile(filter_lp_mono,  'filter_lp_mono',   folder, fp_config);
    writeFilterCoeffsToVHDLFile(filter_bp_lrdiff,'filter_bp_lrdiff', folder, fp_config);

    disp('--- Filter coefficients to C++');
    folder = '../../hardware/hls/src/filter_coeff_headers/';
    writeFilterCoeffsToCPPFile(filter_bp_pilot, 'filter_bp_pilot', folder, fp_config);
    writeFilterCoeffsToCPPFile(filter_lp_mono,  'filter_lp_mono',  folder, fp_config);
    writeFilterCoeffsToCPPFile(filter_bp_lrdiff,'filter_bp_lrdiff',folder, fp_config);

    % Simulation constants
    disp('--- Constants to VHDL/C++/Python');
    writeConstantsToPythonFile('../../hardware/common/tb/packages/fm_global/fm_global.py', 'fm_global_spec', ...
        fp_config, fs, fs_rx, fs_audio, osr_rx, osr_audio, pilot_scale_factor, rx_carrier_38kHz_offset);
    writeConstantsToVHDLFile(  '../../hardware/vhdl/rtl/packages/fm_global_spec_pkg.vhd','fm_global_spec', ...
        fp_config, fs, fs_rx, fs_audio, osr_rx, osr_audio, pilot_scale_factor, rx_carrier_38kHz_offset);
    writeConstantsToCPPFile(  '../../hardware/hls/src/fm_global_spec.hpp',               'fm_global_spec', ...
        fp_config, fs, fs_rx, fs_audio, osr_rx, osr_audio, pilot_scale_factor, rx_carrier_38kHz_offset);
    
    disp('--- Verification data');
    % Only write a fraction of the simulation time to file
    n_sec_file  = 0.1;
    num_samples = n_sec_file * fs_rx;
    num_samples_audio = n_sec_file * fs_audio;
    
    % Test data
    writeDataToFile(rx_fm_bb,         num_samples*osr_rx,'./verification_data/rx_fm_bb.txt',         fp_config);
    writeDataToFile(rx_fm_demod,      num_samples*osr_rx,'./verification_data/rx_fm_demod.txt',      fp_config);
    writeDataToFile(rx_fmChannelData, num_samples,       './verification_data/rx_fm_channel_data.txt',fp_config);
    writeDataToFile(rx_audio_mono,    num_samples_audio, './verification_data/rx_audio_mono.txt',    fp_config);
    writeDataToFile(rx_pilot,         num_samples,       './verification_data/rx_pilot.txt',         fp_config);
    writeDataToFile(rx_carrier_38kHz, num_samples,       './verification_data/rx_carrier_38k.txt',   fp_config);
    writeDataToFile(rx_audio_lrdiff,  num_samples_audio, './verification_data/rx_audio_lrdiff.txt',  fp_config);
    writeDataToFile(rx_audio_L,       num_samples_audio, './verification_data/rx_audio_L.txt',       fp_config);
    writeDataToFile(rx_audio_R,       num_samples_audio, './verification_data/rx_audio_R.txt',       fp_config);

    writeDataToFileWAV(rx_fm_bb, fs, '../../hardware/vivado/sdk/fm_radio_app/resource/wav/rx_fm_bb.wav');
    disp('Done.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fm_analysis();

disp('### Done. ###');
