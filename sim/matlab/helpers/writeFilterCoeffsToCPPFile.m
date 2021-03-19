%-------------------------------------------------------------------------
% File        : writeFilterCoeffsToCPPFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes filter coefficients to VHDL file.
%-------------------------------------------------------------------------

function status = writeFilterCoeffsToCPPFile(coeffs, filtername, filedir, fp_config)
%writeFilterCoeffsToCPPFile - Writes filter coefficients to C++ file.
%   data                 ... data to be written
%   filtername           ... name used for VHDL entity and constant
%   filedir              ... directory where to store the VHDL file
%   fp_config.width      ... fixed point data width
%   fp_config.width_frac ... fixed point data width of fractional part

fp_maximum = 0.999;
coeff_max = max(coeffs);
if fp_config.max_check
    assert(coeff_max <= fp_maximum, ...
        "Max. value (%.5f) exceeds fixed point range! This will lead to overflows in the hardware.", coeff_max);
end

filename = sprintf('%s/%s.h', filedir,filtername);

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end


%% Write C++ header

fprintf(fileID, [ ...
    '// This file is generated by a Matlab script.' newline ...
    '// (C) Michael Wurm 2021' newline ...
    '// *** DO NOT MODIFY ***' newline ...
    newline ...
    '#include \"fm_global.hpp\"\n\n' ...
    ]);

%% Write coefficients

% Convert to fixed point
%coeffs_fp = cast(coeffs, 'like', fi([], true, fp_config.width,fp_config.width_frac));
coeffs_fp = num2fixpt( ...
    coeffs, fixdt(true, fp_config.width, fp_config.width_frac));

num_coeffs = length(coeffs);
grpdelay   = (num_coeffs-1)/2;

fprintf(fileID, "const int %s_grpdelay_c = %d;\n\n", filtername, grpdelay);
fprintf(fileID, "const int %s_num_coeffs_c = %d;\n\n", filtername, num_coeffs);

fprintf(fileID, "const coeff_t %s_coeffs_c[%d] = {\n", filtername, num_coeffs);
fprintf(fileID, "    (coeff_t)%.32f,\n", coeffs_fp(1:end-1));
fprintf(fileID, "    (coeff_t)%.32f};\n", coeffs_fp(end));

%% Write VHDL end

fprintf(fileID, [ ...
    '']);

fclose(fileID);


status = true;
end
