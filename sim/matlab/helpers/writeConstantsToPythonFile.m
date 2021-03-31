%-------------------------------------------------------------------------
% File        : writeConstantsToPythonFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes some constants to a Python file.
%-------------------------------------------------------------------------

function status = writeConstantsToPythonFile( ...
    filename, package_name, fp_config, ...
    fs, fs_rx, fs_audio, osr_rx, osr_audio, ...
    pilot_scale_factor, carrier_38k_offset)
%writeConstantsToPythonFile - Writes constants to a Python file.
%   filename             ... filename (obviously)
%   fp_config.width      ... fixed point width
%   fp_config.width_frac ... fixed point width of fractional part
%   other constants      ... should be self-explaining...

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end

%% Write Python header

fprintf(fileID, [ ...
    '# This file is generated by a Matlab script.' newline ...
    '# (C) Michael Wurm 2021' newline ...
    '# *** DO NOT MODIFY ***\n\n' ...
    ]);

%% Write constants

fprintf(fileID, "# Global constants for FM Receiver IP and testbench\n");
fprintf(fileID, "# Package '%s'\n", package_name);

fprintf(fileID, "\n# General\n");
fprintf(fileID, "fp_width_c      = %d\n", fp_config.width);
fprintf(fileID, "fp_width_frac_c = %d\n", fp_config.width_frac);
fprintf(fileID, "\n");
fprintf(fileID, "fs_c            = %d\n", fs);
fprintf(fileID, "fs_rx_c         = %d\n", fs_rx);
fprintf(fileID, "fs_audio_c      = %d\n", fs_audio);
fprintf(fileID, "\n");
fprintf(fileID, "osr_rx_c        = %d\n", osr_rx);
fprintf(fileID, "osr_audio_c     = %d\n", osr_audio);
fprintf(fileID, "\n");

fprintf(fileID, "# IP specific\n");
fprintf(fileID, "pilot_output_scale_c = %d\n", pilot_scale_factor);
fprintf(fileID, "carrier_38k_offset_c = %.2f\n", carrier_38k_offset);

fclose(fileID);


status = true;
end
