%-------------------------------------------------------------------------
% File        : writeFilterCoeffsToVHDLFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes filter coefficients to a VHDL file.
%-------------------------------------------------------------------------

function status = writeFilterCoeffsToVHDLFile( ...
    coeffs, filtername, filedir, fp_config)
%writeFilterCoeffsToVHDLFile - Writes filter coefficients to a VHDL file.
%   coeffs               ... data to be written
%   filtername           ... name used for VHDL entity and constant
%   filedir              ... directory where to store the VHDL file
%   fp_config.width      ... fixed point width
%   fp_config.width_frac ... fixed point width of fractional part

fp_maximum = 0.999;
coeff_max = max(coeffs);
if fp_config.max_check
    assert(coeff_max <= fp_maximum, ...
        "Max. value (%.5f) exceeds fixed point range! This will lead to overflows in the hardware.", coeff_max);
end

filename = sprintf('%s/%s_pkg.vhd', filedir,filtername);

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end


%% Write VHDL header

package_name = sprintf('%s_pkg', filtername);

fprintf(fileID, [ ...
    '-- This file is generated by a Matlab script.' newline ...
    '-- (C) Michael Wurm 2021' newline ...
    '-- *** DO NOT MODIFY ***' newline ...
    newline ...
    'library work;' newline ...
    'use work.fm_pkg.all;' newline ...
    newline ...
    sprintf('package %s is\n\n', package_name) ...
    ]);

%% Write coefficients

% Convert to fixed point
%coeffs_fp = cast(coeffs, 'like', fi([], true, fp_config.width,fp_config.width_frac));
coeffs_fp = num2fixpt( ...
    coeffs, fixdt(true, fp_config.width, fp_config.width_frac));

grpdelay = (length(coeffs)-1)/2;
fprintf(fileID, "  constant %s_grpdelay_c : natural := %d;\n\n", filtername, grpdelay);

fprintf(fileID, "  constant %s_coeffs_c : filter_coeffs_t := (\n", filtername);
fprintf(fileID, "    %.32f,\n", coeffs_fp(1:end-1));
fprintf(fileID, "    %.32f);\n\n", coeffs_fp(end));

%% Write VHDL end

fprintf(fileID, [ ...
    sprintf('end package %s;', package_name) newline ...
    newline ...
    sprintf('package body %s is', package_name) newline ...
    sprintf('end package body %s;\n', package_name) ...
    ]);

fclose(fileID);


status = true;
end
