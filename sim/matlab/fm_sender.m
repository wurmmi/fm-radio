%-------------------------------------------------------------------------
% File        : fm_sender.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM Sender - creates an FM signal,
%               or loads recorded data file.
%-------------------------------------------------------------------------

%=========================================================================
% NOTE:
%   This file only works when called from "fm_transceiver.m".
%=========================================================================

disp('### Sender Tx ###');

% Sanity checks
assert( not(EnableSenderSourceRecordedFile && EnableSenderSourceCreateSim), ...
    'Settings Error: Only one sender source can be enabled at a time.')
assert( not(EnableSenderSourceRecordedFile == false && EnableSenderSourceCreateSim == false), ...
    'Settings Error: One sender source must be enabled.')


if EnableSenderSourceCreateSim
    disp('-- Creating FM data stream');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Generate audio stream data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if EnableAudioFromFile
        fs_file = 44.1e3;
        
        [fileDataAll,fileFsRead] = audioread('./recordings/wav/left-right-test.wav');
        if fileFsRead ~= fs_file
            error("Unexpected sample frequency of file!");
        end
        
        % Select area of interest (skip silence at beginning of file)
        n_sec_offset = 0.15;
        fileData = fileDataAll(round(n_sec_offset*fs_file):round((n_sec_offset+n_sec)*fs_file)-1,:);
        
        % Upsample
        fileData = resample(fileData, osr, 1);
        
        % Split/Combine left and right channel
        audioDataL = fileData(:,1);
        audioDataR = fileData(:,2);
        
        audioDataMono = audioDataL + audioDataR;
        
        tn = (0:1:length(audioDataMono)-1)';
    else
        tn = (0:1:n_sec*fs-1)';
        
        audioFreqL = 443;
        audioDataL = sin(2*pi*audioFreqL/fs*tn);
        audioDataL(round(end/2):end) = 0; % mute second half
        
        audioFreqR = 443;
        audioDataR = sin(2*pi*audioFreqR/fs*tn);
        audioDataR(1:round(end/2)) = 0;   % mute first half
        
        audioDataMono = audioDataL + audioDataR;
    end
    
    %% 19kHz pilot tone
    
    pilotTone = cos(2*pi*19e3/fs*tn);
    
    %% Difference signal (for stereo)
    
    audioLRDiff = audioDataL - audioDataR;
    
    % Modulate it to 38 kHz
    carrier38kHzTx = cos(2*pi*38e3/fs*tn);
    audioLRDiffMod = audioLRDiff .* carrier38kHzTx;
    
    %% Radio Data Signal (RDS)
    % TODO
    
    %% Hinz-Triller (traffic info trigger)
    % https://de.wikipedia.org/wiki/Autofahrer-Rundfunk-Information#Hinz-Triller
    
    hinz_triller = 0;
    if EnableTrafficInfoTrigger
        fc_hinz             = 2350;
        f_deviation         = 123;
        hinz_duration_on_s  = 1.2;
        hinz_duration_off_s = 0.5;
        
        % Create the 123 Hz Hinz Triller tone and integrate it (for FM modulation)
        t_hinz        = (0:1:min(hinz_duration_off_s,n_sec)*fs-1)';
        hinz_tone     = sin(2*pi*f_deviation/fs*t_hinz);
        hinz_tone_int = cumsum(hinz_tone)/fs;
        
        % FM modulation (with zero padding at the end, to match signal duration)
        hinz_triller = zeros(1,length(tn))';
        hinz_triller(t_hinz+1) = cos(2*pi*fc_hinz/fs*t_hinz + (2*pi*f_deviation*hinz_tone_int));
    end
    
    %% Combine all signal parts
    % TODO: fix this somehow...
    % See formula in https://en.wikipedia.org/wiki/FM_broadcasting#Stereo_FM
    fmChannelData = ...
        0.9 * (audioDataMono/2 + audioLRDiffMod/2) + ...
        0.1 * pilotTone + ...
        1/16 * hinz_triller;
    
    %fmChannelData = ...
    %    1.00 * audioDataMono + ...
    %    0.25 * pilotTone + ...
    %    0.50 * audioLRDiffMod + ...
    %    1/16 * hinz_triller;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Pre-emphasis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO: is this the correct place to do this?
    %       should it be earlier, like separately for L and R?
    if EnablePreEmphasis
        disp('-- Pre-emphasis');
        % Create pre-emphasis filter
        filter_pre_emphasis = getEmphasisFilter(fs, 'pre', EnableFilterAnalyzeGUI);
        
        % Filter
        fmChannelData = filter(filter_pre_emphasis.Num, filter_pre_emphasis.Denum, fmChannelData);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FM Modulator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('-- FM modulator');
    
    % Upsample
    osr_mod = 10;
    fmChannelDataUp = resample(fmChannelData, osr_mod, 1);
    fs_mod = fs*osr_mod;
    tn_mod = (0:1:n_sec*fs_mod-1).';
    
    % FM modulator
    fm_delta_f = 75e3; % channel bandwidth
    fm_fmax    = 57e3;  % max. frequency in fmChannelData
    
    fm_modindex = fm_delta_f / fm_fmax;
    
    fmChannelDataInt = cumsum(fmChannelDataUp) / fs_mod;
    tx_fm = cos(2*pi*fc_oe3/fs_mod*tn_mod + (2*pi*fm_delta_f*fmChannelDataInt));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Channel (AWGN)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    awgn = 0;
    tx_fm_awgn = tx_fm + awgn;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 'Analog' frontend
    % -- Direct down-conversion (DDC) to baseband with a complex mixer (IQ)
    % -- Lowpass filter the spectral replicas at multiple of fs
    % -- ADC: sample with fs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('-- Complex IQ mixer');
    
    % Receive
    rx_fm = tx_fm_awgn;
    
    % Complex baseband mixer
    rx_fm_i  = 2 * rx_fm .*  cos(2*pi*fc_oe3/fs_mod*tn_mod);
    rx_fm_q  = 2 * rx_fm .* -sin(2*pi*fc_oe3/fs_mod*tn_mod);
    
    rx_fm_bb = rx_fm_i + 1j * rx_fm_q;
    
    % Lowpass filter (for spectral replicas)
    filter_name = sprintf("%s%s",dir_filters,"lowpass_iq_mixer.mat");
    ripple_pass_dB = 0.1;           % Passband ripple in dB
    ripple_stop_db = 50;            % Stopband ripple in dB
    cutoff_freqs   = [120e3 250e3]; % Cutoff frequencies
    
    filter_lp_mixer = getLPfilter(  ...
        filter_name, ...
        ripple_pass_dB, ripple_stop_db,  ...
        cutoff_freqs, fs_mod, EnableFilterAnalyzeGUI);
    
    % Filter
    rx_fm_bb = filter(filter_lp_mixer,1, rx_fm_bb);
    
    % ADC (downsample to fs)
    rx_fm_bb = resample(rx_fm_bb, 1, osr_mod);
elseif EnableSenderSourceRecordedFile
    disp('-- Loading FM data stream');
    
    filename = sprintf("./recordings/bin/fm_record_fs%d.bin",fs);
    rx_fm_bb = loadIQFile(filename);
    fprintf("filename: %s", filename);
    
    % Trim data to requested length
    max_idx = n_sec*fs;
    assert(max_idx <= length(rx_fm_bb), 'File is shorter than requested length!');
    rx_fm_bb = rx_fm_bb(1:max_idx);
    
    tn = (0:1:n_sec*fs-1)';
else
    error('Check settings.')
end

disp('Done.');
