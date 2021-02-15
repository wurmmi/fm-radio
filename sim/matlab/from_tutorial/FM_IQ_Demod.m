function [y_fm_demod] = FM_IQ_Demod(y)

%
% y_fm_demod = FM_IQ_Demod(y);
%
% This function demodualtes an FM signal. 
% It is assumed that the FM signal is complex (i.e. an IQ signal), 
% that is centered at DC and occupies less than 90%
% of total bandwidth.
%

% Normalize the amplitude (remove amplitude variations)
d = y ./ abs(y);
rd = real(d);
id = imag(d);

% Design differentiator
diff = firls(30,[0 .9],[0 1],'differentiator'); 

% Demodulate
y_fm_demod = (rd.*conv(id,diff,'same') - id.*conv(rd,diff,'same')) ./ (rd.^2 + id.^2); 

end
