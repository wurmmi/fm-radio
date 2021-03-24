%-------------------------------------------------------------------------
% File        : writeConstantsToCPPFile.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Writes some constants to a C++ file.
%-------------------------------------------------------------------------

function status = writeConstantsToCPPFile( ...
    filename, package_name, fp_config, fs, fs_rx, osr_rx, ...
    pilot_scale_factor, carrier_38k_offset)
%writeConstantsToCPPFile - Writes constants to a C++ file.
%   filename             ... filename (obviously)
%   fp_config.width      ... fixed point width
%   fp_config.width_frac ... fixed point width of fractional part
%   other constants      ... should be self-explaining...

fileID = fopen(filename, 'w');
if fileID <= 0
    error("Could not open file '%s'!", filename);
end

%% Write C++ header
header_define = sprintf("_%s_H", upper(package_name));

fprintf(fileID, [ ...
    '// This file is generated by a Matlab script.' newline ...
    '// (C) Michael Wurm 2021' newline ...
    '// *** DO NOT MODIFY ***\n' ...
    newline ...
    sprintf('#ifndef %s', header_define), newline ...
    sprintf('#define %s\n\n', header_define), ...
    ]);

%% Write constants

fprintf(fileID, "// Global constants for FM Receiver IP and testbench\n");

fprintf(fileID, "\n// General\n");
fprintf(fileID, "#define FP_WIDTH      ((uint32_t)%d + 1)\n", fp_config.width);
fprintf(fileID, "#define FP_WIDTH_FRAC ((uint32_t)%d + 1)\n", fp_config.width_frac);
fprintf(fileID, "#define FP_WIDTH_INT  (FP_WIDTH - FP_WIDTH_FRAC)\n");

fprintf(fileID, "\n// IP specific\n");
fprintf(fileID, "#define PILOT_SCALE_FACTOR (%d)\n", pilot_scale_factor);
fprintf(fileID, "#define CARRIER_38K_OFFSET (%.2f)\n", carrier_38k_offset);

%% Write C++ header end
fprintf(fileID, "\n#endif /* %s */\n", header_define);

fclose(fileID);


status = true;
end