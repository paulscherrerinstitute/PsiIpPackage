##############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
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
variable IpLibrary
variable IpDescription
variable SrcRelative
variable LibRelative
variable LibCopied
variable GuiPages
variable CurrentPage
variable GuiParameters 
variable CurrentParameter
variable Logo
variable DataSheet
variable PortEnablementConditions
variable InterfaceEnablementConditions
variable RemoveAutoIf
variable DriverDir
variable DriverFiles
variable ClockInputs
variable DefaultVhdlLib

# Initialize IP Packaging process
#
# @param name 		Name of the ip core (e.g. bpm_pos)
# @param version 	Version of the IP-Core (e.g. 1.0), pass "auto" for using the timestamp
# @param revision	Revision of the IP-Core (e.g. 12)
# @param library	Library the IP-Core is compiled into (e.g. GPAC3)
proc init {name version revision library} {
	variable IpVersion $version
	variable IpName $name
	if {$revision=="auto"} {
		variable IpRevision [clock seconds]
	} else {
		variable IpRevision $revision
	}	
	variable IpLibrary $library
	variable IpVersionUnderscore
	regsub -all {\.} $version {_} IpVersionUnderscore; list
	variable SrcRelative [list]
	variable LibRelative [list]
	variable LibCopied [list]
	variable GuiPages [list]
	variable GuiParameters [list]
	variable PortEnablementConditions [list]
	variable InterfaceEnablementConditions [list]
	variable RemoveAutoIf [list]
	variable IfClocks [list]
	variable Logo "None"
	variable DataSheet "None"
	variable DriverFiles [list]
	variable DriverDir "None"
	variable TopEntity "None"
	variable ClockInputs [list]
	variable DefaultVhdlLib $IpName\_$IpVersionUnderscore
}
namespace export init

# Set the description of the IP-Core
#
# @param desc		Description string
proc set_description {desc} {
	variable IpDescription $desc
}
namespace export set_description

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
# @param lib		VHDL library to copile files into (optional, default is <ip_name>_<ip_version>)
proc add_sources_relative {srcs {lib "NONE"}} {
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
		lappend SrcRelative $srcFile
	}
}
namespace export add_sources_relative

# Add SW driver files that are referenced to relatively
#
# Note: The files .mdd, .tcl and Makefile are generated automatically inside the driver directory but
# they must be checked in into GIT also (required for Vivado). The reason for generating them automatically
# is that they could potentially change in future Vivado versions. This way the update can be implemented 
# automatically.
#
# The driver sources must be located in the folder *DRIVER_MAIN/src* due to Limitations of Vivado. A folder 
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

# Add library files that are referenced to relatively
#
# @param libPath	Relative path to the common library director of all files 
# @param files		List containing the file paths within the library
# @param lib		VHDL library to copile files into (optional, default is <ip_name>_<ip_version>)
proc add_lib_relative {libPath files {lib "NONE"}} {
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
		lappend LibRelative $libFile
	}
}
namespace export add_lib_relative

# Add library files that are copied into the IP-Core
#
# @param tgtPath	Relative path to the directory in the IP-Core the files shall be copied into
# @param libPath	Relative path to the common library director of all files 
# @param files		List containing the file paths within the library directory
# @param lib		VHDL library to copile files into (optional, default is <ip_name>_<ip_version>)
proc add_lib_copied {tgtPath libPath files {lib "NONE"}} {
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
		lappend LibCopied $copied
	}
}
namespace export add_lib_copied

# Add a page to the GUI
#
# @param name		Name of the new GUI page
proc gui_add_page {name} {
	variable CurrentPage $name
	variable GuiPages
	lappend GuiPages $name
}
namespace export gui_add_page

# Remove an interface that is detected by vivado automatically
#
# @param name	Name of the interface to remove
proc remove_autodetected_interface {name} {
	variable RemoveAutoIf
	lappend RemoveAutoIf $name
}
namespace export remove_autodetected_interface

# Set the clock related to an interface. Vivado usually detects interfaces correctly
# but often messes up the clock associations.
#
# @param interface 	Name of the interface to set the associated clock for
# @param clock 		Name of the clock interface to associate
proc set_interface_clock {interface clock} {
	variable IfClocks
	lappend IfClocks [list $interface $clock]
}
namespace export set_interface_clock

# Create a GUI parameter that exists in VHDL. After all settings are made for the parameter, it must be
# added to the current GUI page using gui_add_parameter
#
# @param vhdlName		Name of the parameter in Vhdl
# @param displayName	Name of the parameter to be displayed in the GUI
proc gui_create_parameter {vhdlName displayName} {
	variable CurrentPage	
	variable CurrentParameter [dict create]
	dict set CurrentParameter PARAM_NAME $vhdlName
	dict set CurrentParameter VHDL_NAME $vhdlName
	dict set CurrentParameter DISPLAY_NAME $displayName
	dict set CurrentParameter PAGE  $CurrentPage
	dict set CurrentParameter VALIDATION  "None"
	dict set CurrentParameter VALUES {}
	dict set CurrentParameter WIDGET "text"	
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
	variable CurrentParameter [dict create]
	dict set CurrentParameter VHDL_NAME "__NONE__"
	if {$displayName == "None"} {
		dict set CurrentParameter DISPLAY_NAME $paramName
	} else {
		dict set CurrentParameter DISPLAY_NAME "$displayName"
	}
	dict set CurrentParameter PARAM_NAME $paramName
	dict set CurrentParameter PAGE  $CurrentPage
	dict set CurrentParameter VALIDATION  "None"
	dict set CurrentParameter VALUES {}
	dict set CurrentParameter WIDGET "text"	
	dict set CurrentParameter TYPE $type
	dict set CurrentParameter INITIAL $initialValue
}
namespace export gui_create_user_parameter

# Change the widget of the current parameter to a dropdown list
#
# @param values		Possible values for the parameter
proc gui_parameter_set_widget_dropdown {values} {
	variable CurrentParameter
	dict set CurrentParameter WIDGET "dropdown"
	dict set CurrentParameter VALIDATION list
	dict set CurrentParameter VALUES $values
}
namespace export gui_parameter_set_widget_dropdown

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

# Add the current parameter to the current gui page
proc gui_add_parameter {} {
	variable GuiParameters
	variable CurrentParameter
	lappend GuiParameters $CurrentParameter
}
namespace export gui_add_parameter

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

# Package the IP-Core
#
# @param tgtDir		Target directory to package the IP into
# @param edit 		[Optional] pass True to leave the IP packager GUI open for checking results etc.
# @param synth		[Optional] pass True to run a test syncthesis to verify vivado can synthesize the core
# @param part 		[Optional] Xilinx part number to do the test synthesis for (artix 7 by default)
proc package {tgtDir {edit false} {synth false} {part xc7a200tsbg484-1}} {
	#create project
	create_project -force package_prj ./package_prj -part $part
	
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
		}
	}
	puts "*** Add relative library files to Project ***"
	if {[llength $LibRelative] > 0} {
		foreach file $LibRelative {
			variable thisfile [dict get $file SRC_PATH]
			puts $thisfile
			add_files -norecurse $thisfile
			set_property library [dict get $file LIBRARY] [get_files $thisfile]
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
	variable DefaultVhdlLib
	puts "*** Set IP properties ***"
	#Having unreferenced files is not allowed (leads to problems in the script). Therefore the warning is promoted to an error.
	set_msg_config -id  {[IP_Flow 19-3833]} -new_severity "ERROR"
	ipx::package_project -root_dir $tgtDir -taxonomy /UserIP
	set_property vendor "psi.ch" [ipx::current_core]
	set_property name $IpName [ipx::current_core]
	set_property library $IpLibrary [ipx::current_core]
	set_property display_name $DefaultVhdlLib [ipx::current_core]
	set_property description $IpDescription [ipx::current_core]
	set_property vendor_display_name "Paul Scherrer Institut" [ipx::current_core]
	set_property company_url "http://www.psi.ch" [ipx::current_core]
	set_property version $IpVersion [ipx::current_core]
	set_property supported_families {	artix7 Production virtex7 Beta qvirtex7 Beta kintex7 Beta kintex7l Beta qkintex7 Beta qkintex7l \
										Beta artix7 Beta artix7l Beta aartix7 Beta qartix7 Beta zynq Beta qzynq Beta azynq Beta spartan7 Beta \
										aspartan7 Beta virtexu Beta virtexuplus Beta kintexuplus Beta zynquplus Beta kintexu Beta} [ipx::current_core]	
	
	#Make Library Paths Relative
	puts "*** Convert library paths to relative paths ***"
	foreach file $LibRelative {
		variable fileName [dict get $file SRC_PATH]
		foreach fileset {xilinx_anylanguagesynthesis xilinx_anylanguagebehavioralsimulation} {
			set_property name [psi::util::path::relTo $tgtDir $fileName] [ipx::get_files */[file tail $fileName] -of_objects [ipx::get_file_groups $fileset -of_objects [ipx::current_core]]]
		}
	}
	
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
	foreach param $GuiParameters {
		#Add parameters
		set VhdlName [dict get $param VHDL_NAME]
		set DisplayName [dict get $param DISPLAY_NAME]
		set ParamName [dict get $param PARAM_NAME]
		puts $ParamName
		if {$VhdlName == "__NONE__"} {
			puts "User Param"
			set Type [dict get $param TYPE]
			set Initial [dict get $param INITIAL]
			ipx::add_user_parameter $ParamName [ipx::current_core]
			set_property value_resolve_type user [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_format $Type [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value $Initial [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		} else {
			puts "Vhdl Param"
		}
		ipgui::add_param -name $ParamName -component [ipx::current_core] -parent [ipgui::get_pagespec -name [dict get $param PAGE] -component [ipx::current_core] ] -display_name [dict get $param DISPLAY_NAME]

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
			set_property value_validation_type list [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_validation_list $Values [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		} elseif {$ValidationType == "range"} {
			set_property value_validation_range_minimum [lindex $Values 0] [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
			set_property value_validation_range_maximum [lindex $Values 1] [ipx::get_user_parameters $ParamName -of_objects [ipx::current_core]]
		}
	}
	
	#Remove autodetected interfaces
	puts "*** Remove autodetected interfaces ***"
	variable RemoveAutoIf
	foreach ifName $RemoveAutoIf {
		ipx::remove_bus_interface $ifName [ipx::current_core]
	}
	
	#Handle Interfaces not detected automatically
	puts "*** Handle Interfaces not detected automatically ***"
	puts "Clocks"
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
	
	#Set interface clocks
	puts "*** Set Interface Clocks ***"
	variable IfClocks
	foreach ifClock $IfClocks {
		set intf [lindex $ifClock 0]
		set clk [lindex $ifClock 1]
		ipx::associate_bus_interfaces -busif $intf -clock $clk [ipx::current_core]
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
	puts "*** Add drivers ***"
	if {$DriverDir != "None"} {
		#Initialize Driver
		ipx::add_file_group -type software_driver {} [ipx::current_core]		
		
		#.MDD File
		psi::util::string::copyAndReplaceTags "$fileLoc/Snippets/driver/snippet.mdd" $DriverDir/data/$IpName\.mdd [dict create <IP_NAME> $IpName]
		set MddPathRel [psi::util::path::relTo $tgtDir $DriverDir/data/$IpName\.mdd false]
		ipx::add_file $MddPathRel [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]
		set_property type mdd [ipx::get_files $MddPathRel -of_objects [ipx::get_file_groups xilinx_softwaredriver -of_objects [ipx::current_core]]]
		
		#.TCL File
		psi::util::string::copyAndReplaceTags "$fileLoc/Snippets/driver/snippet.tcl" $DriverDir/data/$IpName\.tcl [dict create <IP_NAME> $IpName]
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
	set_property  ip_repo_paths $tgtDir [current_project]
	update_ip_catalog
	ipx::check_integrity -quiet [ipx::current_core]
	
	#close project
	close_project
	
	puts "*** DONE ***"
}
#Wraper to prevent name clash with existing vivado command "package"
proc package_ip {tgtDir {edit false} {synth false} {part xc7a200tsbg484-1}} {
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



