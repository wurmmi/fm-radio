

proc generate {drv_handle} {
    xdefine_include_file $drv_handle "xparameters.h" "fm_receiver_vhdl" \
        "NUM_INSTANCES" \
        "DEVICE_ID" \
        "C_S_AXI_API_BASEADDR" \
        "C_S_AXI_API_HIGHADDR"
}
