

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "gem_loader_v" "NUM_INSTANCES" "DEVICE_ID"  "C_S_CFG_AXI_BASEADDR" "C_S_CFG_AXI_HIGHADDR" "C_S_C2C_AXI_BASEADDR" "C_S_C2C_AXI_HIGHADDR"
}
