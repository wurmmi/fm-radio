-- This file is generated by a Matlab script.
-- (C) Michael Wurm 2021
-- *** DO NOT MODIFY ***

library work;
use work.fm_pkg.all;

package filter_bp_pilot_pkg is

  constant filter_bp_pilot_grpdelay_c : natural := 36;

  constant filter_bp_pilot_coeffs_c : filter_coeffs_t := (
    0.00000000000000000000000000000000,
    -0.00128173828125000000000000000000,
    -0.00109863281250000000000000000000,
    0.00030517578125000000000000000000,
    0.00231933593750000000000000000000,
    0.00274658203125000000000000000000,
    -0.00006103515625000000000000000000,
    -0.00439453125000000000000000000000,
    -0.00573730468750000000000000000000,
    -0.00115966796875000000000000000000,
    0.00659179687500000000000000000000,
    0.01007080078125000000000000000000,
    0.00366210937500000000000000000000,
    -0.00878906250000000000000000000000,
    -0.01580810546875000000000000000000,
    -0.00811767578125000000000000000000,
    0.01000976562500000000000000000000,
    0.02227783203125000000000000000000,
    0.01446533203125000000000000000000,
    -0.00976562500000000000000000000000,
    -0.02893066406250000000000000000000,
    -0.02264404296875000000000000000000,
    0.00714111328125000000000000000000,
    0.03442382812500000000000000000000,
    0.03173828125000000000000000000000,
    -0.00225830078125000000000000000000,
    -0.03796386718750000000000000000000,
    -0.04095458984375000000000000000000,
    -0.00500488281250000000000000000000,
    0.03857421875000000000000000000000,
    0.04870605468750000000000000000000,
    0.01354980468750000000000000000000,
    -0.03601074218750000000000000000000,
    -0.05401611328125000000000000000000,
    -0.02252197265625000000000000000000,
    0.03033447265625000000000000000000,
    0.05578613281250000000000000000000,
    0.03033447265625000000000000000000,
    -0.02252197265625000000000000000000,
    -0.05401611328125000000000000000000,
    -0.03601074218750000000000000000000,
    0.01354980468750000000000000000000,
    0.04870605468750000000000000000000,
    0.03857421875000000000000000000000,
    -0.00500488281250000000000000000000,
    -0.04095458984375000000000000000000,
    -0.03796386718750000000000000000000,
    -0.00225830078125000000000000000000,
    0.03173828125000000000000000000000,
    0.03442382812500000000000000000000,
    0.00714111328125000000000000000000,
    -0.02264404296875000000000000000000,
    -0.02893066406250000000000000000000,
    -0.00976562500000000000000000000000,
    0.01446533203125000000000000000000,
    0.02227783203125000000000000000000,
    0.01000976562500000000000000000000,
    -0.00811767578125000000000000000000,
    -0.01580810546875000000000000000000,
    -0.00878906250000000000000000000000,
    0.00366210937500000000000000000000,
    0.01007080078125000000000000000000,
    0.00659179687500000000000000000000,
    -0.00115966796875000000000000000000,
    -0.00573730468750000000000000000000,
    -0.00439453125000000000000000000000,
    -0.00006103515625000000000000000000,
    0.00274658203125000000000000000000,
    0.00231933593750000000000000000000,
    0.00030517578125000000000000000000,
    -0.00109863281250000000000000000000,
    -0.00128173828125000000000000000000,
    0.00000000000000000000000000000000);

end package filter_bp_pilot_pkg;

package body filter_bp_pilot_pkg is
end package body filter_bp_pilot_pkg;
