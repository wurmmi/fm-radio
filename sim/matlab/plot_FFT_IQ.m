function plot_FFT_IQ(x, n0, nf, fs, f0, title_of_plot)

%
%  plot_FFT_IQ(x,n0,nf)
%
%  Plots the FFT of sampled IQ data
%
%                x  -- input signal
%                n0 -- first sample (start time = n0/fs)
%                nf -- block size for transform (signal duration = nf/fs)
%                fs -- sampling frequency [Hz]
%                f0 -- center frequency [Hz]
%                title_of_plot -- title of plot (string) (optional)
%
% This extracts a segment of x starting at n0, of length nf, and plots the FFT.
%

% Transform from Hz to MHz
fs = fs/1e6;
f0 = f0/1e6;

% Extract a small segment of data from signal
x_segment = x(n0:(n0+nf-1));

% Calculate FFT (normalized to maximum)
fft_res      = fftshift(fft(x_segment));
fft_res_norm = 20*log10(abs(fft_res)/max(abs(fft_res)));

% Plot
Low_freq  = (f0-fs/2); % Lowest frequency to plot
High_freq = (f0+fs/2); % Highest frequency to plot

N    = length(fft_res_norm);
freq = (0:1:N-1)*fs/N + Low_freq;

figure();
plot(freq, fft_res_norm);
xlabel('Frequency [MHz]')
ylabel('Relative amplitude [dB down from max]')
axis tight;
grid on;
hold on;

% Add vertical line
xline(f0, 'r','linewidth',2);

% Add title if it was specified
if nargin==6
    title(title_of_plot)
else
    title({'Spectrum',['Center frequency = ' num2str(f0) ' MHz'] })
end
