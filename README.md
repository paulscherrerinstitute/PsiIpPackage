# General Information

## Maintainer
Jonas Purtschert [jonas.purtschert@psi.ch]

## Authors
Oliver Bründler [oliver.bruendler@psi.ch]

## License
This library is published under [PSI HDL Library License](License.txt), which is [LGPL](LGPL2_1.txt) plus some additional exceptions to clarify the LGPL terms in the context of firmware development.

## Detailed Documentation
See [Command Reference](CommandRef.md)
See [Tips](Tips.md)

## Changelog
See [Changelog](Changelog.md)

## Tagging Policy
Stable releases are tagged in the form *major*.*minor*.*bugfix*. 

* Whenever a change is not fully backward compatible, the *major* version number is incremented
* Whenever new features are added, the *minor* version number is incremented
* If only bugs are fixed (i.e. no functional changes are applied), the *bugfix* version is incremented

# Dependencies

Currently none

# Usage
This TCL framework allows to easily package Vivado IP-Cores from tcl scripts. This has many advantages in terms of 
less interactive (and error-prone) packaging, reproducibility and maintainabilit (scripts can easily be version controlled).

## Notes
The framework is written with portability to newer vivado versions in mind. By default, the latest version of Vivado
should be used but it is possible to run the framework for any specific older version of Vivado at any time.

In the example below, a variable *vivadoVersion* is defined to allow easily changing the Vivado version targeted.

## Example Packaging Script
```
###############################################################
# Include PSI packaging commands
###############################################################
source ../../../../Libraries/TCL/PsiIpPackage/PsiIpPackage.tcl
namespace import psi::ip_package::2017_2_1::*

###############################################################
# General Information
###############################################################
set IP_NAME data_rec
set IP_VERSION 1.0
set IP_REVISION "auto"
set IP_LIBRARY GPAC3
set IP_DESCIRPTION "Mutli channel data recorder (supports pre-trigger and self-triggering)"

init $IP_NAME $IP_VERSION $IP_REVISION $IP_LIBRARY
set_description $IP_DESCIRPTION
set_logo_relative "../doc/psi_logo_150.gif"
set_datasheet_relative "../doc/$IP_NAME.pdf"

###############################################################
# Add Source Files
###############################################################

#Relative Source Files
add_sources_relative { \
	../hdl/data_rec_register_pkg.vhd \
	../hdl/data_rec.vhd \
	../hdl/data_rec_vivado_wrp.vhd \
}

#Relative Library Files
add_lib_relative \
	"../../../../Libraries"	\
	{ \
		VHDL/psi_common/hdl/psi_common_math_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_array_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_pulse_cc.vhd \
		VHDL/psi_common/hdl/psi_common_status_cc.vhd \
		VHDL/psi_common/hdl/psi_common_simple_cc.vhd \
		VHDL/psi_common/hdl/psi_common_tdp_ram_rbw.vhd \
		VivadoIp/axi_slave_ipif_package/hdl/axi_slave_ipif_package.vhd \
	}			

###############################################################
# GUI Parameters
###############################################################

#User Parameters
gui_add_page "Configuration"

gui_create_parameter "NumOfInputs_g" "Data Channels"
gui_parameter_set_range 1 8
gui_add_parameter

gui_create_parameter "InputWidth_g" "Data Channel Width"
gui_parameter_set_range 1 32
gui_add_parameter

gui_create_parameter "MemoryDepth_g" "Recording Buffer size"
gui_add_parameter

#Remove reset interface (Vivado messes up polarity...)
remove_autodetected_interface Rst

###############################################################
# Optional Ports
###############################################################

for {set i 0} {$i < 8} {incr i} {
	add_port_enablement_condition "In_Data$i" "\$NumOfInputs_g > $i"
}

###############################################################
# Package Core
###############################################################
set TargetDir ".."
#                                           Edit  Synth	
package_ip $TargetDir                       false true
```


