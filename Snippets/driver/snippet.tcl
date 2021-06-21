

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" <IP_NAME> "NUM_INSTANCES" "DEVICE_ID"  "C_BASEADDR" "C_HIGHADDR" <PARAM_LIST>
}
