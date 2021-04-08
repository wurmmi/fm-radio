%-------------------------------------------------------------------------
% File        : writeConstantsToVHDLFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes some constants to a VHDL file.
%-------------------------------------------------------------------------

function status = writeConstantsToVHDLFile( ...
    filename, package_name, fp_config, ...
    fs, fs_rx, fs_audio, osr_rx, osr_audio, ...
    pilot_scale_factor, carrier_38k_offset)
%writeConstantsToVHDLFile - Writes constants to a VHDL file.
%   filename             ... filename (obviously)
%   fp_config.width      ... fixed point width
%   fp_config.width_frac ... fixed point width of fractional part
%   other constants      ... should be self-explaining...

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end

%% Write VHDL header

package_name = sprintf('%s_pkg', package_name);

fprintf(fileID, [ ...
    '-- This file is generated by a Matlab script.' newline ...
    '-- (C) Michael Wurm 2021' newline ...
    '-- *** DO NOT MODIFY ***' newline ...
    newline ...
    sprintf('package %s is\n\n', package_name) ...
    ]);

%% Write constants
fprintf(fileID, "  -- General\n");
fprintf(fileID, "  constant fp_width_spec_c      : natural := %d;\n", fp_config.width);
fprintf(fileID, "  constant fp_width_frac_spec_c : natural := %d;\n", fp_config.width_frac);
fprintf(fileID, "  constant fp_width_int_spec_c  : natural := %d;\n", fp_config.width - fp_config.width_frac - 1);
fprintf(fileID, "\n");
fprintf(fileID, "  constant fs_spec_c            : natural := %d;\n", fs);
fprintf(fileID, "  constant fs_rx_spec_c         : natural := %d;\n", fs_rx);
fprintf(fileID, "  constant fs_audio_spec_c      : natural := %d;\n", fs_audio);
fprintf(fileID, "\n");
fprintf(fileID, "  constant osr_rx_spec_c        : natural := %d;\n", osr_rx);
fprintf(fileID, "  constant osr_audio_spec_c     : natural := %d;\n", osr_audio);
fprintf(fileID, "\n");

fprintf(fileID, "  -- IP specific\n");
fprintf(fileID, "  constant pilot_scale_factor_spec_c : real := %.2f;\n", pilot_scale_factor);
fprintf(fileID, "  constant carrier_38k_offset_spec_c : real := %.2f;\n", carrier_38k_offset);

%% Write VHDL end

fprintf(fileID, [ ...
    sprintf('\nend package %s;', package_name) newline ...
    newline ...
    sprintf('package body %s is', package_name) newline ...
    sprintf('end package body %s;\n', package_name) ...
    ]);

fclose(fileID);


status = true;
end
