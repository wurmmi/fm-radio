

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "fm_receiver_vhdl" "NUM_INSTANCES" "DEVICE_ID"  "C_s_axi_BASEADDR" "C_s_axi_HIGHADDR"
}
