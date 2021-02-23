%-------------------------------------------------------------------------
% File        : fm_sender.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : FM Sender - creates an FM signal,
%               or loads recorded data file.
%-------------------------------------------------------------------------

% Sanity checks
assert( not(EnableSenderSourceRecordedFile && EnableSenderSourceCreateSim), ...
    'Settings Error: Only one sender source can be enabled at a time.')
assert( not(EnableSenderSourceRecordedFile == false && EnableSenderSourceCreateSim == false), ...
    'Settings Error: One sender source must be enabled.')


if EnableSenderSourceCreateSim
    disp('Creating FM data stream in simulation.');
    
    %% Audio stream data
    if EnableAudioFromFile
        fs_file = 44.1e3;
        
        [fileDataAll,fileFsRead] = audioread('./recordings/left-right-test.wav');
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
        
        audioData = audioDataL + audioDataR;
        
        tn = (0:1:length(audioData)-1)';
    else
        tn = (0:1:n_sec*fs-1)';
        
        audioFreqL = 400;
        audioDataL = 1 * sin(2*pi*audioFreqL/fs*tn);
        audioDataL(round(end/2):end) = 0; % mute second half
        
        audioFreqR = 400;
        audioDataR = 1 * sin(2*pi*audioFreqR/fs*tn);
        audioDataR(1:round(end/2)) = 0;   % mute first half
        
        audioData = audioDataL + audioDataR;
    end
    
    %% 19kHz pilot tone
    
    pilotFreq = 19000;
    pilotTone = 0.25 * sin(2*pi*pilotFreq/fs*tn);
    
    %% Difference signal (for stereo)
    
    audioDiff = audioDataL - audioDataR;
    
    % Modulate it to 38 kHz
    carrier38kHzTx = 1 * sin(2*pi*38e3/fs*tn);
    audioLRDiffMod = audioDiff .* carrier38kHzTx;
    
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
        hinz_amplitude      = 1/16;
        
        % Create the 123 Hz Hinz Triller tone and integrate it (for FM modulation)
        t_hinz = (0:1:min(hinz_duration_off_s,n_sec)*fs-1)';
        hinz_tone = sin(2*pi*f_deviation/fs*t_hinz);
        hinz_tone_int = cumsum(hinz_tone)/fs;
        
        % FM modulation (with zero padding at the end, to match signal duration)
        hinz_triller = zeros(1,length(tn))';
        hinz_triller(t_hinz+1) = cos(2*pi*fc_hinz/fs*t_hinz + (2*pi*f_deviation*hinz_tone_int));
        hinz_triller = hinz_amplitude * hinz_triller;
    end
    
    %% Combine all signal parts
    
    fmChannelData = audioData + pilotTone + audioLRDiffMod + hinz_triller;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FM Modulator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Upsample
    osr_mod = 10;
    fmChannelDataUp = resample(fmChannelData, osr_mod, 1);
    fs_mod = fs*osr_mod;
    tn_mod = (0:1:n_sec*fs_mod-1).';
    
    % FM modulator
    fm_delta_f = 100e3; % channel bandwidth
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
    % -- Lowpass filter the spectral replicas at multiple of fc
    % -- ADC: sample with fs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Receive
    rx_fm = tx_fm_awgn;
    
    % Complex baseband mixer
    rx_fm_i  = rx_fm .*  cos(2*pi*fc_oe3/fs_mod*tn_mod);
    rx_fm_q  = rx_fm .* -sin(2*pi*fc_oe3/fs_mod*tn_mod);
    
    rx_fm_bb = rx_fm_i + 1j * rx_fm_q;
    
    % Lowpass filter (for spectral replicas)
    filter_name = sprintf("%s%s",dir_filters,"lowpass_iq_mixer.mat");
    if isRunningInOctave()
        disp("Running in GNU Octave - loading lowpass filter from folder!");
        filter_lp_mixer = load(filter_name);
    else
        ripple_pass_dB = 0.1;           % Passband ripple in dB
        ripple_stop_db = 50;            % Stopband ripple in dB
        cutoff_freqs   = [120e3 250e3]; % Cutoff frequencies
        
        filter_lp_mixer = getLPfilter(  ...
            ripple_pass_dB, ripple_stop_db,  ...
            cutoff_freqs, fs_mod, EnableFilterAnalyzeGUI);
        
        % Save the filter coefficients
        save(filter_name,'filter_lp_mixer','-ascii');
    end
    
    % Filter
    rx_fm_bb = filter(filter_lp_mixer,1, rx_fm_bb);
    
    % ADC (downsample to fs)
    rx_fm_bb = resample(rx_fm_bb, 1, osr_mod);
    
elseif EnableSenderSourceRecordedFile
    disp('Loading FM data stream from file.');
    
    assert(false, 'Not implemented yet.');
    
else
    assert(false, 'Check settings.')
end
