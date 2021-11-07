##############################################################################
#  Copyright (c) 2020 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler, Patrick Studer
##############################################################################

####################################################################
# TCL package to generate Vivado IPI Components for Vivado 2017_2_1
####################################################################

#Dependencies
variable fileLoc [file normalize [file dirname [info script]]]
source $fileLoc/PsiUtilPath.tcl
source $fileLoc/PsiUtilString.tcl
namespace export -clear

#Internal Variables
variable IpVersion 
variable IpVersionUnderscore
variable IpRevision
variable IpName 
variable IpDispName 
variable IpLibrary
variable IpVendor
variable IpVendorShort
variable IpVendorUrl
variable IpDescription
variable IpTargetLanguage
variable IpTaxonomy
variable SrcRelative
variable LibRelative
variable LibCopied
variable GuiPages
variable CurrentPage
variable CurrentGroup
variable GuiParameters 
variable CurrentParameter
variable Logo
variable DataSheet
variable ImportInterfaceDefinitions
variable AddBusInterfaces
variable PortEnablementConditions
variable PortInterfaceModes
variable InterfaceEnablementConditions
variable RemoveAutoIf
variable DriverDir
variable DriverFiles
variable XparParameters
variable ClockInputs
variable ResetInputs
variable IfClocks
variable TopEntity
variable DefaultVhdlLib
variable GuiSupportTcl
variable TtclFiles
variable RemoveFiles
variable SubCores

# Initialize IP Packaging process
#
# @param name 		Name of the IP-Core (e.g. "My new IP Core")
# @param version 	Version of the IP-Core (e.g. 1.0), pass "auto" for using the timestamp
# @param revision	Revision of the IP-Core (e.g. 12)
# @param library	Library the IP-Core is compiled into (e.g. GPAC3)
proc init {name version revision library} {
	variable IpVersion $version
	variable IpDispName $name
	variable IpName [string map {\  _} $IpDispName]
	if {$revision=="auto"} {
		variable IpRevision [clock seconds]
	} else {
		variable IpRevision $revision
	}	
	variable IpLibrary $library
	variable IpVendor "Paul Scherrer Institute"
	variable IpVendorUrl "http://www.psi.ch"
	variable IpVendorShort "psi.ch"
	variable IpVersionUnderscore [string map {. _} $version]
    variable IpDescription
    variable IpTargetLanguage "VHDL"
	variable IpTaxonomy {{"/UserIP"}}
	variable SrcRelative [list]
	variable LibRelative [list]
	variable LibCopied [list]
	variable GuiPages [list]
	variable CurrentGroup "None"
	variable GuiParameters [list]
	variable ImportInterfaceDefinitions [list]
	variable AddBusInterfaces [list]
	variable PortEnablementConditions [list]
	variable PortInterfaceModes [list]
	variable InterfaceEnablementConditions [list]
	variable RemoveAutoIf [list]
	variable IfClocks [list]
	variable Logo "None"
	variable DataSheet "None"
	variable DriverFiles [list]
	variable DriverDir "None"
	variable XparParameters [list]
	variable TopEntity "None"
	variable ClockInputs [list]
	variable ResetInputs [list]
	variable DefaultVhdlLib $IpName\_$IpVersionUnderscore
	variable GuiSupportTcl [list]
	variable TtclFiles [list]
	variable RemoveFiles [list]
    variable SubCores [list]
}
namespace export init

# Set the description of the IP-Core
#
# @param desc		Description string
proc set_description {desc} {
	variable IpDescription $desc
}
namespace export set_description

# Set the target language of the IP-Core
#
# @param lang		Target string (VHDL or Verilog)
proc set_target_language {lang} {
	variable IpTargetLanguage $lang
}
namespace export set_target_language

# Set the vendor of the IP-Core
#
# @param vendor		Vendor name
proc set_vendor {vendor} {
	variable IpVendor $vendor
}
namespace export set_vendor

# Set the vendor abbreviation of the IP-Core
#
# @param vendor		Vendor abbreviation (must contain no whitespaces)
proc set_vendor_short {vendor} {
	variable IpVendorShort $vendor
}
namespace export set_vendor_short

# Set the vendor URL of the IP-Core
#
# @param url		Vendor URL
proc set_vendor_url {url} {
	variable IpVendorUrl $url
}
namespace export set_vendor_url

# Set the taxonomy of the IP-Core
#
# @param taxonomy   List of categories
proc set_taxonomy {taxonomy} {
	variable IpTaxonomy $taxonomy
}
namespace export set_taxonomy

# Set the name of the top-entity (only required if Vivado cannot determine the top entity automatically)
#
# @param name		Name of the top entity
proc set_top_entity {name} {
	variable TopEntity $name
}
namespace export set_top_entity

# Add a logo that is added to the IP using a relative path
#
# @param logo		Path to the logo
proc set_logo_relative {logo} {
	variable Logo $logo
}
namespace export set_logo_relative

# Add a datasheet that is added to the IP using a relative path
#
# @param datasheet	Path to the datasheet (must be a PDF file)
proc set_datasheet_relative {datasheet} {
	variable DataSheet $datasheet
}
namespace export set_datasheet_relative

# Add source files that are referenced to relatively
#
# @param srcs		List containing the source file paths relative to execution director
# @param lib		VHDL library to copile files into (optional, default is <ip_name>_<ip_version>).
#					"NONE" can be used to compile the files into the default library.
# @param type		Override file type detected by vivado automatically. For VHDL, VHDL 2008 is used by default.
proc add_sources_relative {srcs {lib "NONE"} {type "NONE"}} {
	variable SrcRelative 
	variable DefaultVhdlLib
	variable srcFile [dict create]
	foreach file $srcs {
		dict set srcFile SRC_PATH $file
		if {$lib == "NONE"} {
			dict set srcFile LIBRARY $DefaultVhdlLib
		} else {
			dict set srcFile LIBRARY $lib
		}
		#Use VHDL 2008 as default for all VHDL files
		dict set srcFile TYPE $type
		if {([string match "*.vhdl" $file] || [string match "*.vhd" $file]) && ($type == "NONE")} {
			dict set srcFile TYPE "VHDL 2008"
		}
		lappend SrcRelative $srcFile
	}
}
namespace export add_sources_relative

# Add sub core reference
#
# @param cores       List containing the sub cores to be added to the project.
proc add_sub_core_reference {cores} {
	variable SubCores
	lappend SubCores $cores
}
namespace export add_sub_core_reference

# Add SW driver files that are referenced to relatively
#
# Note: The files .mdd, .tcl and Makefile are generated automatically inside the driver directory but
# they must be checked in into GIT also (required for Vivado). The reason for generating them automatically
# is that they could potentially change in future Vivado versions. This way the update can be implemented 
# automatically.
#
# The driver sources must be located in the folder *DRIVER_MAIN/src* due to limitations of Vivado. A folder 
# *DRIVER_MAIN/data* must also exist, also because Vivado expects this folder.
#
# @param dir	Driver directory (should be named according to the IP-Core)
# @param files	List of file paths for the driver source files (.c, .h) relative to *dir*
proc add_drivers_relative {dir files} {
	variable DriverDir $dir
	variable DriverFiles
	variable DriverFiles [concat $DriverFiles $files]
}
namespace export add_drivers_relative

# Add IP parameter value to xparameters.h
#
# @parameter 	Name of the parameter to add (vhdlName of gui_create_parameter or paramName of gui_create_user_parameter)
proc add_xparameters_entry {parameter} {
	variable XparParameters
	lappend XparParameters $parameter
}
namespace export add_xparameters_entry


# Add library files that are referenced to relatively
#
# @param libPath	Relative path to the common library directory of all files 
# @param files		List containing the file paths within the library
# @param lib		VHDL library to compile files into (optional, default is <ip_name>_<ip_version>)
#					"NONE" can be used to compile the files into the default library.
# @param type		Override file type detected by vivado automatically. For VHDL, VHDL 2008 is used by default.
proc add_lib_relative {libPath files {lib "NONE"} {type "NONE"}} {
	variable LibRelative
	variable DefaultVhdlLib
	foreach file $files {
		variable libFile [dict create]
		dict set libFile SRC_PATH [concat $libPath/$file]
		if {$lib == "NONE"} {
			dict set libFile LIBRARY $DefaultVhdlLib
		} else {
			dict set libFile LIBRARY $lib
		}
		#Use VHDL 2008 as default for all VHDL files
		dict set libFile TYPE $type
		if {([string match "*.vhdl" $file] || [string match "*.vhd" $file]) && ($type == "NONE")} {
			dict set libFile TYPE "VHDL 2008"
		}
		lappend LibRelative $libFile
	}
}
namespace export add_lib_relative

# Add library files that are copied into the IP-Core
#
# @param tgtPath	Relative path to the directory in the IP-Core the files shall be copied into
# @param libPath	Relative path to the common library director of all files 
# @param files		List containing the file paths within the library directory
# @param lib		VHDL library to compile files into (optional, default is <ip_name>_<ip_version>)
#					"NONE" can be used to compile the files into the default library.
# @param type		Override file type detected by vivado automatically. For VHDL, VHDL 2008 is used by default.
proc add_lib_copied {tgtPath libPath files {lib "NONE"} {type "NONE"}} {
	variable LibCopied
	variable DefaultVhdlLib
	foreach file $files {
		variable copied [dict create]
		dict set copied TGT_PATH [concat $tgtPath/$file]
		dict set copied SRC_PATH [concat $libPath/$file]
		if {$lib == "NONE"} {
			dict set copied LIBRARY $DefaultVhdlLib
		} else {
			dict set copied LIBRARY $lib
		}
		#Use VHDL 2008 as default for all VHDL files
		dict set copied TYPE $type
		if {([string match "*.vhdl" $file] || [string match "*.vhd" $file]) && ($type == "NONE")} {
			dict set copied TYPE "VHDL 2008"
		}
		lappend LibCopied $copied
	}
}
namespace export add_lib_copied

# Add TTCL VHD files. They must reside in a subfolder of the IP main directory being named "ttcl".
#
# @param files		List containing the files to add
# @param lib		VHDL library to compile files into (optional, default is <ip_name>_<ip_version>)
#					"NONE" can be used to compile the files into the default library.
proc add_ttcl_vhd {files {lib "NONE"}} {
	variable TtclFiles
	variable DefaultVhdlLib
	foreach file $files {
		variable ttclFile [dict create]
		dict set ttclFile SRC_FILE $file
		if {$lib == "NONE"} {
			dict set ttclFile LIBRARY $DefaultVhdlLib
		} else {
			dict set ttclFile LIBRARY $lib
		}
		lappend TtclFiles $ttclFile
	}
}
namespace export add_ttcl_vhd

# Add GUI support TCL script containing procedures to be used in parameter calculations
#
# @param script		Path to the GUI script (relative to the IP directory)
proc add_gui_support_tcl {script} {
	variable GuiSupportTcl
	lappend GuiSupportTcl $script
}
namespace export add_gui_support_tcl

# Add a page to the GUI
#
# @param name		Name of the new GUI page
proc gui_add_page {name} {
	variable CurrentPage $name
	variable CurrentGroup "None"
	variable GuiPages
	lappend GuiPages $name
}
namespace export gui_add_page

# Add parameter group to the GUI page
# 
# @param name       Name of the new parameter group
proc gui_add_group {name} {
    variable CurrentPage
	variable CurrentGroup $name
}
namespace export gui_add_group

# Exit the current parameter group (next parameter is outside of the group) 
proc gui_exit_group {} {
	variable CurrentGroup "None"
}
namespace export gui_exit_group


# Remove an interface that is detected by vivado automatically
#
# @param name	Name of the interface to remove (can be a list)
#               Use identifier "ALL" to remove all autogenerated interfaces.
proc remove_autodetected_interface {{name "ALL"}} {
	variable RemoveAutoIf
    foreach interface $name {
        lappend RemoveAutoIf $interface
    }
}
namespace export remove_autodetected_interface

# Remove a VHDL file that is present in the packaging project from the IP before packaging. This
# can be used if the file is generated by scripts/TTCL files during IP-Generation. A prototype of the file
# still needs to be added to make test synthesis succeeding but it shall not be packaged (because the real file is generated).
#
# @param path	Path of the file relative to the IP-main directory
proc remove_file_from_ip {path} {
	variable RemoveFiles
	lappend RemoveFiles $path
}
namespace export remove_file_from_ip

# Set the clock related to an interface. Vivado usually detects interfaces correctly
# but often messes up the clock associations.
#
# @param interface 	Name of the interface to set the associated clock for (can be a list)
#                   Use identifier "ALL" to associate all bus interfaces with the defined clock.
# @param clock 		Name of the clock interface to associate
proc set_interface_clock {interfaces clock} {
	variable IfClocks
    foreach interface $interfaces {
        dict set IfClock INTERFACE $interface
        dict set IfClock CLOCK $clock
        lappend IfClocks $IfClock
    }
}
namespace export set_interface_clock

# Create a GUI parameter that exists in VHDL. After all settings are made for the parameter, it must be
# added to the current GUI page using gui_add_parameter
#
# @param vhdlName		Name of the parameter in Vhdl
# @param displayName	Name of the parameter to be displayed in the GUI
proc gui_create_parameter {vhdlName displayName} {
	variable CurrentPage	
	variable CurrentGroup
	variable CurrentParameter [dict create]
	dict set CurrentParameter PARAM_NAME $vhdlName
	dict set CurrentParameter VHDL_NAME $vhdlName
	dict set CurrentParameter DISPLAY_NAME $displayName
	dict set CurrentParameter PAGE  $CurrentPage
	dict set CurrentParameter GROUP $CurrentGroup
	dict set CurrentParameter VALIDATION  "None"
	dict set CurrentParameter VALUES {}
	dict set CurrentParameter WIDGET "text"	
	dict set CurrentParameter EXPRESSION "None"
	dict set CurrentParameter TEXTBELOW "None"
	dict set CurrentParameter ENABLEMENTDEF "None"
	dict set CurrentParameter ENABLEMENTDEP "None"
}
namespace export gui_create_parameter

# Create a pure GUI parameter that does not exist in VHDL. After all settings are made for the parameter, it must be
# added to the current GUI page using gui_add_parameter
#
# @param paramName		Name of the parameter to be displayed in the GUI
# @param type			Type of the parameter (e.g. "bool")
# @param initialValue	Initial Value of the parameter
proc gui_create_user_parameter {paramName type initialValue {displayName "None"}} {
	variable CurrentPage	
	variable CurrentGroup
	variable CurrentParameter [dict create]
	dict set CurrentParameter VHDL_NAME "__NONE__"
	if {$displayName == "None"} {
		dict set CurrentParameter DISPLAY_NAME $paramName
	} else {
		dict set CurrentParameter DISPLAY_NAME "$displayName"
	}
	dict set CurrentParameter PARAM_NAME $paramName
	dict set CurrentParameter PAGE  $CurrentPage
	dict set CurrentParameter GROUP $CurrentGroup
	dict set CurrentParameter VALIDATION  "None"
	dict set CurrentParameter VALUES {}
	dict set CurrentParameter WIDGET "text"	
	dict set CurrentParameter TYPE $type
	dict set CurrentParameter INITIAL $initialValue
	dict set CurrentParameter EXPRESSION "None"
	dict set CurrentParameter TEXTBELOW "None"
	dict set CurrentParameter ENABLEMENTDEF "None"
	dict set CurrentParameter ENABLEMENTDEP "None"
}
namespace export gui_create_user_parameter

# Change the widget of the current parameter to a dropdown list
#
# @param values		Possible values for the parameter
proc gui_parameter_set_widget_dropdown_list {values} {
	variable CurrentParameter
	dict set CurrentParameter WIDGET "dropdown"
	dict set CurrentParameter VALIDATION "list"
	dict set CurrentParameter VALUES $values
}
namespace export gui_parameter_set_widget_dropdown_list
#Keep old naming for reverse compatibility (don't use for new scripts)
proc gui_parameter_set_widget_dropdown {values} {
	gui_parameter_set_widget_dropdown_list $values
}
namespace export gui_parameter_set_widget_dropdown

# Change the widget of the current parameter to dropdown pairs
#
# @param pairs		Possible key-value-pairs for the parameter(e.g. {"key1" 1 "key2" 2 ...})
proc gui_parameter_set_widget_dropdown_pairs {pairs} {
	variable CurrentParameter
	dict set CurrentParameter WIDGET "dropdown"
	dict set CurrentParameter VALIDATION "pairs"
	dict set CurrentParameter VALUES $pairs
}
namespace export gui_parameter_set_widget_dropdown_pairs

# Change the widget of the current parameter to a checkbox
proc gui_parameter_set_widget_checkbox {} {
	variable CurrentParameter
	dict set CurrentParameter WIDGET "checkbox"
}
namespace export gui_parameter_set_widget_checkbox

# Set a validation range for nummerical parameters that are entered using a text-field
#
# @param min		Minimum Value
# @param max		Maximum Value
proc gui_parameter_set_range {min max} {
	variable CurrentParameter
	dict set CurrentParameter VALIDATION range
	dict set CurrentParameter VALUES [list $min $max]
}
namespace export gui_parameter_set_range

# Calculate the value of a prameter from an expression (instead of user input)
#
# @param expression		Expression to use (e.g. {$Channels_g > 2"})
proc gui_parameter_set_expression {expression} {
	variable CurrentParameter
	dict set CurrentParameter EXPRESSION $expression
}
namespace export gui_parameter_set_expression

# Set enablement dependency of the user parameter
#
# @param expression	Expression (parameter is enabled if it evaluates to true) e.g. {$Channels_g > 2"}
# @param default	Default enablement of the parameter
proc gui_parameter_set_enablement {expression default} {
	variable CurrentParameter
	dict set CurrentParameter ENABLEMENTDEF $default
	dict set CurrentParameter ENABLEMENTDEP $expression
}
namespace export gui_parameter_set_enablement
	
# Add text below the current parameter
#
# @param text		Text to place below the parameter
proc gui_parameter_text_below {text} {
	variable CurrentParameter
	dict set CurrentParameter TEXTBELOW $text
}
namespace export gui_parameter_text_below

# Add the current parameter to the current gui page
proc gui_add_parameter {} {
	variable GuiParameters
	variable CurrentParameter
	lappend GuiParameters $CurrentParameter
}
namespace export gui_add_parameter


# Copy one or more user-created interface definition(s) to the current target directory.
# They can be used together with add_bus_interface.
#
# @param srcPath		Path to existing interface definitions
# @param defNames		Name of Interface Definition File (can be a list)
#                       (e.g. defNames = "Test" imports Test.xml and Test_rtl.xml)
proc import_interface_definition {srcPath defNames} {
    variable ImportInterfaceDefinitions
    foreach def $defNames {
        variable BusAbs [concat $srcPath/$def\_rtl.xml]
        variable BusDef [concat $srcPath/$def.xml]
        lappend ImportInterfaceDefinitions $BusAbs
        lappend ImportInterfaceDefinitions $BusDef
    }
}
namespace export import_interface_definition

# Map ports to an existing bus interface (user-created interfaces must be imported with import_interface_definition).
#
# @param definition		Complete VLNV identifier of a existing interface definition
#						(e.g. "xilinx.com:interface:uart:1.0") or just the name (e.g. "uart").
#						If multiple interface definitions with the same name are found,
#						the user gets an error message with a list of all interfaces that were found.
# @param name			Name of the bus interface (e.g. "UART")
# @param mode			Direction mode of the interface (master, slave, monitor, mirroredMaster, ...)
# @param description    Description to the bus interface
# @param port_maps		A list with port pairs to map abstraction ports to physical IP ports.
#						(e.g. {{"Uart_Rx" "RxD"} {"Uart_Tx" "TxD"} {...}}
proc add_bus_interface {definition name mode description port_maps} {	
    variable AddBusInterfaces
	variable CurrentBusInterface [dict create]
	dict set CurrentBusInterface DEFI  $definition
	dict set CurrentBusInterface NAME  $name
    dict set CurrentBusInterface MODE  $mode
    dict set CurrentBusInterface DESCRIPTION $description
    dict set CurrentBusInterface PORT_MAPS $port_maps
	lappend AddBusInterfaces $CurrentBusInterface
}
namespace export add_bus_interface

# Add an enablement condition for a port
#
# @param port		Port(s) to add enablement condition for (wildcards etc. allowed). Example : "Adc_*" 
# @param condition	Enablementcondition (pass Parameter Names as TCL variables). Example "\$C_ADC_CHANNELS > 3"
proc add_port_enablement_condition {port condition} {
	variable PortEnablementConditions
	variable Condition [dict create]
	dict set Condition PORT $port
	dict set Condition CONDITION $condition
	lappend PortEnablementConditions $Condition
}
namespace export add_port_enablement_condition

# Set the interface mode for an interface
#
# @param interface	Interface to set the mode for
# @param mode		Interface mode (master, slave or monitor)
proc set_interface_mode {interface mode} {
	variable PortInterfaceModes
	variable Mode [dict create]
	dict set Mode INTERFACE $interface
	dict set Mode MODE $mode
	lappend PortInterfaceModes $Mode
}
namespace export set_interface_mode

# Add an enablement condition for an interface
#
# @param interface	Interfaces to add enablement condition for (wildcards etc. allowed). Example : "Adc_*" 
# @param condition	Enablementcondition (pass Parameter Names as TCL variables). Example "\$C_ADC_CHANNELS > 3"
proc add_interface_enablement_condition {interface condition} {
	variable InterfaceEnablementConditions
	variable Condition [dict create]
	dict set Condition INTERFACE $interface
	dict set Condition CONDITION $condition
	lappend InterfaceEnablementConditions $Condition
}
namespace export add_interface_enablement_condition

# Add a clock input that was not detected by Vivado automatically 
#
# @param portname	Name of the clock port to add
proc add_clock_in_interface {portname} {
	variable ClockInputs
	lappend ClockInputs $portname
}
namespace export add_clock_in_interface

# Add a reset input that was not detected by Vivado automatically 
#
# @param portname	Name of the reset port to add
# @param polarity	Polarity of the reset port ("positive" or "negative")
proc add_reset_in_interface {portname {polarity "positive"}} {
	variable ResetInputs
    dict set resets PORTNAME $portname
	dict set resets POLARITY $polarity
	lappend ResetInputs $resets
}
namespace export add_reset_in_interface

# Package the IP-Core
#
# @param tgtDir		Target directory to package the IP into
# @param edit 		[Optional] pass True to leave the IP packager GUI open for checking results etc.
# @param synth		[Optional] pass True to run a test synthesis to verify vivado can synthesize the core
# @param part 		[Optional] Xilinx part number to do the test synthesis for (artix 7 by vivado default)
proc package {tgtDir {edit false} {synth false} {part ""}} {
	#create project, use default part defined by vivado when not specified:
	if {$part == ""} {
		create_project -force package_prj ./package_prj 
	} else {
		create_project -force package_prj ./package_prj -part $part
	}
	
	#Source GUI support TCL scripts
	variable GuiSupportTcl
	foreach script $GuiSupportTcl {
		set ::script $script
		namespace eval "::" {
			source "../$script"
		}
	}

	###############################################################
	# Project config
	###############################################################	
	
	#add source files
	variable SrcRelative
	variable LibRelative
	puts "*** Add source files to Project ***"
	if {[llength $SrcRelative] > 0} {
		foreach file $SrcRelative {
			variable thisfile [dict get $file SRC_PATH]
			puts $thisfile
			add_files -norecurse $thisfile
			set_property library [dict get $file LIBRARY] [get_files $thisfile]
			variable fileType [dict get $file TYPE]
			if {$fileType != "NONE"} {
				set_property file_type $fileType [get_files $thisfile]
			}
		}
	}
	puts "*** Add relative library files to Project ***"
	if {[llength $LibRelative] > 0} {
		foreach file $LibRelative {
			variable thisfile [dict get $file SRC_PATH]
			puts $thisfile
			add_files -norecurse $thisfile
			set_property library [dict get $file LIBRARY] [get_files $thisfile]
			variable fileType [dict get $file TYPE]
			if {$fileType != "NONE"} {
				set_property file_type $fileType [get_files $thisfile]
			}
		}		
	}
	
	#Copy copied library files
	variable LibCopied
	set copiedLib [list]
	puts "*** Add copied library files to Project***"
	if {[llength $LibCopied] > 0} {
		foreach copied $LibCopied {
			#unpack
			set srcPath [dict get $copied SRC_PATH]
			set tgtPath [dict get $copied TGT_PATH]
			puts "$srcPath > $tgtPath"
			#Copy
			file copy -force $srcPath $tgtPath
			add_files -norecurse $tgtPath
			set_property library [dict get $copied LIBRARY] [get_files $tgtPath]
			variable fileType [dict get $copied TYPE]
			if {$fileType != "NONE"} {
				set_property file_type $fileType [get_files $tgtPath]
			}
		}
	}
	
	#Set top entity
	puts "*** Select Top Entity ***"
	variable TopEntity
	if {$TopEntity != "None"} {
		set_property top $TopEntity [current_fileset]
	}
	
	#Start Packaging
	variable IpLibrary
	variable IpDescription
	variable IpVersion 
	variable IpName
	variable IpDispName
	variable IpVendor
	variable IpVendorShort
	variable IpVendorUrl
	variable IpTaxonomy
    variable IpTargetLanguage
	variable DefaultVhdlLib
	puts "*** Set IP properties ***"
	#Having unreferenced files is not allowed (leads to problems in the script). Therefore the warning is promoted to an error.
	catch {set_msg_config -id  {[IP_Flow 19-3833]} -new_severity "ERROR"}
	ipx::package_project -root_dir $tgtDir -taxonomy $IpTaxonomy
    set OldXguiFile [concat $tgtDir/xgui/[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl]
	set_property vendor $IpVendorShort [ipx::current_core]
	set_property name $IpName [ipx::current_core]
	set_property library $IpLibrary [ipx::current_core]
	set_property display_name $IpDispName [ipx::current_core]
	set_property description $IpDescription [ipx::current_core]
	set_property vendor_display_name $IpVendor [ipx::current_core]
	set_property company_url $IpVendorUrl [ipx::current_core]
	set_property version $IpVersion [ipx::current_core]
	set_property supported_families { \
                                        spartan7    Production \
                                        artix7      Production \
                                        artix7l     Production \
                                        kintex7     Production \
                                        kintex7l    Production \
                                        kintexu     Production \
                                        kintexuplus Production \
                                        virtex7     Production \
                                        virtexu     Production \
                                        virtexuplus Production \
                                        zynq        Production \
                                        zynquplus   Production \
                                        aspartan7   Production \
                                        aartix7     Production \
                                        azynq       Production \
                                        qartix7     Production \
                                        qkintex7    Production \
                                        qkintex7l   Production \
                                        qvirtex7    Production \
                                        qzynq       Production \
                                    } [ipx::current_core]
					
    #Make File Group Paths Relative
	puts "*** Convert all File Group paths to relative paths ***"
	foreach obj [ipx::get_files -of_objects [ipx::get_file_groups * -of_objects [ipx::current_core]]] {
        set file [get_property name $obj]
        if {[file pathtype $file] != "relative"} {
            # puts "ABS: $file => REL: [psi::util::path::relTo $tgtDir $file false]"
			set_property name [psi::util::path::relTo $tgtDir $file false] $obj
		}
	}

	#Add Target-Directory to IP-Location
	puts "*** Add IP Location ***"
    set_property  ip_repo_paths  $tgtDir [current_project]
    update_ip_catalog

    # Add references to sub-cores
    puts "*** Add references to sub-cores***"
    variable SubCores
    foreach core $SubCores {
        puts [string trim $core]
        ipx::add_subcore [string trim $core] [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
        ipx::add_subcore [string trim $core] [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
    }
    ipx::merge_project_changes files [ipx::current_core]
	
	#GUI Initialize (remove auto-generate stuff)
	ipgui::remove_page -component [ipx::current_core] [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]

	#Add Pages
	puts "*** Add GUI pages ***"
	variable GuiPages
	foreach page $GuiPages {
		ipgui::add_page -name "$page" -component [ipx::current_core] -display_name "$page"
	}

	#Handle Parameters
	variable GuiParameters
	puts "*** Define GUI parameters ***"
	set PrevGroup "None"
	foreach param $GuiParameters {
		#Add parameters
		set VhdlName [dict get $param VHDL_NAME]
		set DisplayName [dict get $param DISPLAY_NAME]
		set ParamName [dict get $param PARAM_NAME]
		set GroupName [dict get $param GROUP]
		puts -nonewline $ParamName
		
		#Add Page if required
		if {($GroupName != $PrevGroup) && ($GroupName != "None")} {
			ipgui::add_group -name "$GroupName" -component [ipx::current_core] -parent [ipgui::get_pagespec -name "[dict get $param PAGE]" -component [ipx::current_core] ] -display_name "$GroupName"
		}	
		set PrevGroup $GroupName
		
		#Create parameter
		if {$VhdlName == "__NONE__"} {
			puts " - User Param"
			set Type [dict get $param TYPE]
			set Initial [dict get $param INITIAL]
			ipx::add_user_parameter $ParamName [ipx::current_core]
			set_property value_resolve_type user [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_format $Type [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value $Initial [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		} else {
			puts " - Vhdl Param"
		}
		
		#Find parent
		if {[dict get $param GROUP] == "None"} {
			set Parent [ipgui::get_pagespec -name "[dict get $param PAGE]" -component [ipx::current_core]]
		} else {
			set Parent [ipgui::get_groupspec -name "[dict get $param GROUP]" -component [ipx::current_core]]
		}			
		ipgui::add_param -name $ParamName -component [ipx::current_core] -parent $Parent -display_name [dict get $param DISPLAY_NAME]

		#Widget Configuration
		set Widget [dict get $param WIDGET]
		if {$Widget == "text"} {
			set_property widget {textEdit} [ipgui::get_guiparamspec -name $ParamName -component [ipx::current_core]]
		} elseif {$Widget == "dropdown"} {
			set_property widget {comboBox} [ipgui::get_guiparamspec -name $ParamName -component [ipx::current_core]]
		} elseif {$Widget == "checkbox"} {
			set_property widget {checkBox} [ipgui::get_guiparamspec -name $ParamName -component [ipx::current_core]]
		}
		#Validation type
		set ValidationType [dict get $param VALIDATION]
		set Values [dict get $param VALUES]
		if {$ValidationType == "list"} {
			set_property value_validation_type list     [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_validation_list $Values  [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		} elseif {$ValidationType == "pairs"} {
            set_property value_validation_type pairs    [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
            set_property value_validation_pairs $Values [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		} elseif {$ValidationType == "range"} {
			set_property value_validation_range_minimum [lindex $Values 0] [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_validation_range_maximum [lindex $Values 1] [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		}
		#Enablement dependency
		set EnablementDep [dict get $param ENABLEMENTDEP]
		set EnablementDef [dict get $param ENABLEMENTDEF]
		if {$EnablementDep != "None"} {
			set_property enablement_value $EnablementDef [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property enablement_tcl_expr $EnablementDep [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		}
		#Expression
		set ParamExpr [dict get $param EXPRESSION]
		if {$ParamExpr != "None"} {
			set_property value_tcl_expr $ParamExpr [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property enablement_value false [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		}
		#Text Below
		set text [dict get $param TEXTBELOW]
		if {$text != "None"} {
			ipgui::add_static_text -name "$ParamName\_TextBelow" -component [ipx::current_core] -parent [ipgui::get_pagespec -name [dict get $param PAGE] -component [ipx::current_core] ] -text $text
		}
	}
	
	#Remove autodetected interfaces
	puts "*** Remove autodetected interfaces ***"
	variable RemoveAutoIf
	foreach ifName $RemoveAutoIf {
        if {$ifName == "ALL"} {
            foreach intf_all [get_property name [ipx::get_bus_interfaces -of_objects  [ipx::current_core]]] {
                ipx::remove_bus_interface $intf_all [ipx::current_core]
            }
        } else {
            ipx::remove_bus_interface $ifName [ipx::current_core]
        }
	}

	#Handle Interfaces not detected automatically
	puts "*** Add Clock Input Interface ***"
	variable ClockInputs
	foreach clock $ClockInputs {
		ipx::add_bus_interface $clock [ipx::current_core]
		set_property abstraction_type_vlnv xilinx.com:signal:clock_rtl:1.0 [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]
		set_property bus_type_vlnv xilinx.com:signal:clock:1.0 [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]
		set_property display_name $clock [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]
		ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]
		ipx::add_port_map CLK [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]
		set_property physical_name $clock [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces $clock -of_objects [ipx::current_core]]]
	}
	 
    puts "*** Add Reset Input Interface ***"
    variable ResetInputs
	foreach reset $ResetInputs {
        set Portname    [dict get $reset PORTNAME]
		set Polarity    [dict get $reset POLARITY]
		ipx::add_bus_interface $Portname [ipx::current_core]
		set_property abstraction_type_vlnv xilinx.com:signal:reset_rtl:1.0 [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]
		set_property bus_type_vlnv xilinx.com:signal:reset:1.0 [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]
		set_property display_name $Portname [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]
		ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]
        if {$Polarity == "positive"} {
            set_property value ACTIVE_HIGH [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]]
		} elseif {$Polarity == "negative"} {
            set_property value ACTIVE_LOW [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]]
        }
        ipx::add_port_map RST [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]
		set_property physical_name $Portname [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces $Portname -of_objects [ipx::current_core]]]
	}
    
	
    #Import Interface Definitions
    puts "*** Import Interface Definitions ***"
    variable ImportInterfaceDefinitions
    foreach def $ImportInterfaceDefinitions {
        update_ip_catalog -add_interface $def -repo_path $tgtDir
    }
    
    update_ip_catalog -rebuild -repo_path $tgtDir

    # Add Bus Interface
    puts "*** Add Bus Interface ***"
	variable AddBusInterfaces
    foreach busIf $AddBusInterfaces {      
		set IfDefinition    [dict get $busIf DEFI]
		set IfName          [dict get $busIf NAME]
		set IfMode          [dict get $busIf MODE]
		set IfDescription   [dict get $busIf DESCRIPTION]
		set IfPortMaps      [dict get $busIf PORT_MAPS]
        set LastDpPosition  [string last ":" $IfDefinition]
        set LastRtlPosition [string last "_rtl" $IfDefinition]
        set DefStringLength [string length $IfDefinition]
        if {$LastDpPosition == -1} {
            if {[expr {$DefStringLength - $LastRtlPosition - 4}] == 0} {
                set IfDefinition [string replace $IfDefinition $LastRtlPosition [expr {$DefStringLength - 1}] ""]
            }
            set IfBusDef    [ipx::get_ipfiles -type busdef *:$IfDefinition:*]
            set IfBusAbs    [ipx::get_ipfiles -type busabs *:$IfDefinition\_rtl:*]
        } else {
            if {[expr {$LastDpPosition - $LastRtlPosition - 4}] == 0} {
                set IfDefinition [string replace $IfDefinition $LastRtlPosition [expr {$LastDpPosition - 1}] ""]
                set LastDpPosition  [expr {$LastDpPosition - 4}]
            }
            set IfBusDef    [ipx::get_ipfiles -type busdef $IfDefinition]
            set IfBusAbs    [ipx::get_ipfiles -type busabs [string replace $IfDefinition $LastDpPosition $LastDpPosition "_rtl:"]]
        }
        if {[llength $IfBusDef] == 0} {
            puts "ERROR: Could not find a interface definition that contains $IfDefinition. Define a valid interface definition or use import_interface_definition if you forgot to import the definition."
            return
        } elseif {[llength $IfBusDef] != 1} {
            error "ERROR: Found multiple interface definitions that contain $IfDefinition (LIST: [get_property vlnv $IfBusDef]). Select a vlnv interface definition from the list and define the name accordingly!"
            return
        }
        set IfBusDefVlnv    [get_property vlnv [lindex $IfBusDef 0]]
		set IfBusAbsVlnv    [get_property vlnv [lindex $IfBusAbs 0]]
        set AbsPortList     [get_property name [ipx::get_bus_abstraction_ports -of_objects [lindex $IfBusAbs 0]]]     
        
        ipx::add_bus_interface $IfName                      [ipx::current_core]
        set_property abstraction_type_vlnv $IfBusAbsVlnv    [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]
        set_property bus_type_vlnv $IfBusDefVlnv            [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]
        set_property interface_mode $IfMode                 [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]
        set_property description $IfDescription             [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]

        foreach portMap $IfPortMaps {
            set PhysicalName [lindex $portMap 0]
            set AbstractionName [lindex $portMap 1]
            if {[lsearch -exact $AbsPortList $AbstractionName] == -1} { 
                error "ERROR: Found no abstraction port that is named $AbstractionName (LIST: $AbsPortList). Select a abstraction port from the list and define the name accordingly!"
                return
            }
            ipx::add_port_map $AbstractionName [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]
            set_property physical_name $PhysicalName [ipx::get_port_maps $AbstractionName -of_objects [ipx::get_bus_interfaces $IfName -of_objects [ipx::current_core]]]
        }
    }
    

	#Handle optional ports
	puts "*** Handle optional ports ***"
	variable PortEnablementConditions
	foreach cond $PortEnablementConditions {
		set_property enablement_dependency [dict get $cond CONDITION] [ipx::get_ports [dict get $cond PORT] -of_objects [ipx::current_core]]
		set_property driver_value 0 [ipx::get_ports [dict get $cond PORT] -of_objects [ipx::current_core]]
	}

	#Handle optional interfaces
	puts "*** Handle optional interfaces ***"
	variable InterfaceEnablementConditions
	foreach cond $InterfaceEnablementConditions {
		set_property enablement_dependency [dict get $cond CONDITION] [ipx::get_bus_interfaces [dict get $cond INTERFACE] -of_objects [ipx::current_core]]
	}
	
	#Handle interface modes
	puts "*** Handle interface modes ***"
	variable PortInterfaceModes
	foreach ifModes $PortInterfaceModes {
		puts "set_property interface_mode [dict get $ifModes MODE] ipx::get_ports [dict get $ifModes INTERFACE] -of_objects [ipx::current_core]"
		set_property interface_mode [dict get $ifModes MODE] [ipx::get_bus_interfaces [dict get $ifModes INTERFACE] -of_objects [ipx::current_core]]
	}
	
	#Set interface clocks
	puts "*** Set Interface Clocks ***"
	after 5
	variable IfClocks
	foreach ifClock $IfClocks {
		set intf	[dict get $ifClock INTERFACE]
		set clk		[dict get $ifClock CLOCK]
        if {$intf == "ALL"} {
            foreach intf_all [get_property name [ipx::get_bus_interfaces -of_objects  [ipx::current_core]]] {
				puts "ipx::associate_bus_interfaces -busif $intf_all -clock $clk \[ipx::current_core\]"
                ipx::associate_bus_interfaces -busif $intf_all -clock $clk [ipx::current_core]
            }
        } else {
			puts "ipx::associate_bus_interfaces -busif $intf -clock $clk \[ipx::current_core\]"
            ipx::associate_bus_interfaces -busif $intf -clock $clk [ipx::current_core]
        }
	}
	
	#Add logo if required
	variable Logo
	puts "*** Add logo ***"
	if {$Logo != "None"} {
		set LogoRelPath [psi::util::path::relTo $tgtDir $Logo false]
		ipx::add_file_group -type utility {} [ipx::current_core]
		ipx::add_file $LogoRelPath [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]
		set_property type image [ipx::get_files $LogoRelPath -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]
		set_property type LOGO [ipx::get_files $LogoRelPath -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]
	}
	
	#Add datasheet if required
	variable DataSheet
	puts "*** Add datasheet ***"
	if {$DataSheet != "None"} {
		set DatasheetRelPath [psi::util::path::relTo $tgtDir $DataSheet false]
		ipx::add_file_group -type datasheet {} [ipx::current_core]
		ipx::add_file $DatasheetRelPath [ipx::get_file_groups xilinx_datasheet -of_objects [ipx::current_core]]
		set_property type pdf [ipx::get_files $DatasheetRelPath -of_objects [ipx::get_file_groups xilinx_datasheet -of_objects [ipx::current_core]]]
	}

	#Add drivers if required
	variable DriverDir
	variable DriverFiles
	variable fileLoc
	variable XparParameters
	puts "*** Add drivers ***"
	if {$DriverDir != "None"} {
		#Initialize Driver
		ipx::add_file_group -type software_driver {} [ipx::current_core]		
		
		#Create directoreis if required
		file mkdir $DriverDir/data
		file mkdir $DriverDir/src
		
		#.MDD File
		psi::util::string::copyAndReplaceTags "$fileLoc/Snippets/driver/snippet.mdd" $DriverDir/data/$IpName\.mdd [dict create <IP_NAME> $IpName]
		set MddPathRel [psi::util::path::relTo $tgtDir $DriverDir/data/$IpName\.mdd false]
		ipx::add_file $MddPathRel [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]
		set_property type mdd [ipx::get_files $MddPathRel -of_objects [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]]
		
		#.TCL File
		set paramList ""
		foreach param $XparParameters {
			set paramList "$paramList \"$param\""
		}
		set paramList [string trim $paramList]
		psi::util::string::copyAndReplaceTags "$fileLoc/Snippets/driver/snippet.tcl" $DriverDir/data/$IpName\.tcl [dict create <IP_NAME> $IpName <PARAM_LIST> $paramList]
		set TclPathRel [psi::util::path::relTo $tgtDir $DriverDir/data/$IpName\.tcl false]
		ipx::add_file $TclPathRel [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]
		set_property type tclSource [ipx::get_files $TclPathRel -of_objects [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]]
		
		#Makefile
		psi::util::string::copyAndReplaceTags "$fileLoc/Snippets/driver/Makefile" $DriverDir/src/Makefile [dict create <IP_NAME> $IpName]
		set MakePathRel [psi::util::path::relTo $tgtDir $DriverDir/src/Makefile false]
		ipx::add_file $MakePathRel [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]
		set_property type unknown [ipx::get_files $MakePathRel -of_objects [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]]

		#Add driver files		
		foreach file $DriverFiles {
			set FilePathRel [psi::util::path::relTo $tgtDir $DriverDir/$file false]
			ipx::add_file $FilePathRel [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]
			set_property type cSource [ipx::get_files $FilePathRel -of_objects [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]]
		}
	}
	
	#Add TTCL Files
	puts "*** TTCL VHD Files ***"
	variable TtclFiles
	foreach file $TtclFiles {
		variable thisfile [dict get $file SRC_FILE]
		variable thisLib [dict get $file LIBRARY]
		puts ttcl/$thisfile
		ipx::add_file ttcl/$thisfile [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
		set_property type ttcl [ipx::get_files ttcl/$thisfile -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
		set_property LIBRARY_NAME $thisLib [ipx::get_files ttcl/$thisfile -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
	}
	
	#Remove files
	puts "*** Remove Files ***"
	variable RemoveFiles
	foreach file $RemoveFiles {
		puts $file
		ipx::remove_file $file [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
		ipx::remove_file $file [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
	}
	
	#Test synthesis if required
	puts "*** Run synthesis if enabled ***"
	if {$synth == true} {
		launch_runs synth_1 -jobs 4
		wait_on_run synth_1
		set status [get_property STATUS [get_runs synth_1]]
		if {$status != "synth_design Complete!"} {
			error "Synthesis Failed: $status - Check reports!"
		}
	}
	
	#Leave here in edit mode
	if {$edit == true} {
		puts "*** LEAVE FOR EDITING ***"
		return
	}
	
	#Finish Packaging
	puts "*** Finish packaging ***"
	variable IpRevision
	set_property core_revision $IpRevision [ipx::current_core]
	ipx::create_xgui_files [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::save_core [ipx::current_core]
					   
	ipx::check_integrity -quiet [ipx::current_core]
	
    #Delete default xgui file
	set NewXguiFile [concat $tgtDir/xgui/[get_property name [ipx::current_core]]_v[string map {. _} [get_property version [ipx::current_core]]].tcl]
    if {$NewXguiFile != $OldXguiFile} {
		puts "*** Delete Default XGUI File ***"
		file delete -force $OldXguiFile
	}
	
	update_ip_catalog -rebuild
	#close project
	close_project
	
	#Add GUI Support TCL files to generated file (there is no clean way to do this during packaging)
	variable GuiSupportTcl
	if {[llength $GuiSupportTcl] > 0} {
		#Read file
		set f [open [glob ../xgui/$IpName*.tcl] "r"]
		set content [read $f]
		close $f
		
		#Add line
		set f [open [glob ../xgui/$IpName*.tcl] "w+"]
		foreach script $GuiSupportTcl {
			puts -nonewline $f {source [file join [file dirname [file dirname [info script]]]}
			puts $f " $script]\n"
		}
		puts $f $content
		close $f		
	}
	
	puts "*** DONE ***"
}
#Wraper to prevent name clash with existing vivado command "package"
proc package_ip {tgtDir {edit false} {synth false} {part ""}} {
	package $tgtDir $edit $synth $part
}
namespace export package_ip

# Get a namespace variable. This is most likely used for debuggign only.
#
# @param Name of the variable to get
proc get_variable {name} {
	variable $name
	eval return $$name
}



