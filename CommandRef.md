# Command Reference
**All commands are in the namespace psi::ip_package::[VivadoVersion]::**, so either a fully qualified name (psi::ip_package::2017_2_1<my command>) must 
be used to access them or the namespace psi::ip_package::<VivadoVersion>:: must be imported (see example in [README](README.md)).

To use the implementation for the latest Vivado version, "latest" can be passed as Vivado version.

Befoe using the commands, type the following line in Vivado to import the commands into the global workspace:
```
namespace import psi::ip_package::latest::*
```


# Command Links
* General Commands
 * [init](#init)  
* Configuration Commands
 * [set_description](#set_description) 
 * [set_vendor](#set_vendor) 
 * [set_vendor_short](#set_vendor_short)
 * [set_vendor_url](#set_vendor_url)
 * [set_logo_relative](#set_logo_relative) 
 * [set_datasheet_relative](#set_datasheet_relative)
 * [set_top_entity](#set_top_entity)
 * [add_sources_relative](#add_sources_relative) 
 * [add_lib_relative](#add_lib_relative) 
 * [add_lib_copied](add_lib_copied) 
 * [gui_add_page](#gui_add_page) 
 * [add_gui_support_tcl](#add_gui_support_tcl)
 * [gui_create_parameter](#gui_create_parameter) 
 * [gui_create_user_parameter](#gui_create_user_parameter) 
 * [gui_parameter_set_widget_dropdown](#gui_parameter_set_widget_dropdown) 
 * [gui_parameter_set_widget_checkbox](#gui_parameter_set_widget_checkbox) 
 * [gui_parameter_set_range](#gui_parameter_set_range) 
 * [gui_parameter_set_expression](#gui_parameter_set_expression)
 * [gui_parameter_set_enablement](#gui_parameter_set_enablement)
 * [gui_parameter_text_below](#gui_parameter_text_below)
 * [gui_add_parameter](#gui_add_parameter) 
 * [add_port_enablement_condition](#add_port_enablement_condition) 
 * [add_interface_enablement_condition](#add_interface_enablement_condition)
 * [remove_autodetected_interface](#remove_autodetected_interface) 
 * [add_clock_in_interface](#add_clock_in_interface)
 * [set_interface_clock](#set_interface_clock)
 * [add_drivers_relative](#add_drivers_relative)
 * [set_interface_mode](#set_interface_mode)
* Run Commands
 * [package_ip](#package_ip) 
 
## General Commands
 
### init
**Usage**

```
init <name> <version> <revision> <library>
```
 
**Description**

This command initializes the PSI IP packaging module. It must be called as first command from this library
in every packaging script.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> name </td>
      <td> No </td>
      <td> Name of the IP Core. The name cannot contain whitespaces or special characters. </td>
    </tr>
    <tr>
      <td> version </td>
      <td> No </td>
      <td> Version of the IP-Core in the form "1.2" </td>
    </tr>	
    <tr>
      <td> revision </td>
      <td> No </td>
      <td> Revision of the IP-core. Alternative to passing a number, the string "auto" can be passed. In this
           case the UNIX timestamp of the build time is taken as revision which results in an automatically
           updated and unique revision number. As a result, Vivado detects a new revision every time time
		   IP core is packaged. </td>
    </tr>		
</table>

## Configuration Commands

### set_description
**Usage**

```
set_description <desc>
```

**Description**

Set the description of the IP-Core that is shown in Vivado.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> desc </td>
      <td> No </td>
      <td> Description of the IP-Core </td>
    </tr>
</table>

### set_vendor
**Usage**

```
set_vendor <vendor>
```

**Description**

Set the vendor of the IP-Core that is shown in Vivado.

This command is optional. If it is not used, the vendor name is set to \"Paul Scherrer Institute\". This is chosen this way to make the code
fully reverse compatible.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> vendor </td>
      <td> No </td>
      <td> Vendor of the IP-Core </td>
    </tr>
</table>

### set_vendor_short
**Usage**

```
set_vendor_short <vendor>
```

**Description**

Set the vendor abbreviation of the IP-Core that is shown in Vivado. Note that hte vendor abbreviation is not allowed to contain any whitespaces.

This command is optional. If it is not used, the vendor abbreviation is set to \"psi.ch\". This is chosen this way to make the code
fully reverse compatible.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> vendor </td>
      <td> No </td>
      <td> Vendor abbreviation (no whitespaces allowed) </td>
    </tr>
</table>

### set_vendor_url
**Usage**

```
set_vendor_url <url>
```

**Description**

Set the vendor URL of the IP-Core that is shown in Vivado.

This command is optional. If it is not used, the vendor url is set to \"www.psi.ch\". This is chosen this way to make the code
fully reverse compatible.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> url </td>
      <td> No </td>
      <td> Vendor URL of the IP-Core </td>
    </tr>
</table>

### set_logo_relative
**Usage**

```
set_logo_relative <logo>
```

**Description**

Add a logo to the IP-Core. The logo is not copied into the IP-Core but referenced relatively.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> logo </td>
      <td> No </td>
      <td> Path to the logo. </td>
    </tr>
</table>

### set_datasheet_relative
**Usage**

```
set_datasheet_relative <datasheet>
```

**Description**

Add a Datasheet to the IP-Core. The datasheet is not copied into the IP-Core but referenced relatively.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> datasheet </td>
      <td> No </td>
      <td> Path to the datasheet. </td>
    </tr>
</table>

### set_top_entity
**Usage**

```
set_top_entity <entity_name>
```

**Description**

Usually Vivado automatically detects the top entity name. If this works, the command *set_top_entity* can be omitted. Otherwise it can be used to specify the top level entity.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> entity_name </td>
      <td> No </td>
      <td> Name of the top level entity</td>
    </tr>
</table>

### add_sources_relative
**Usage**

```
add_sources_relative <srcs> <lib> <type>
```

**Description**

Add one or more source files to the IP-Core. Note that the source files are not copied into the IP-Core but
referenced relatively because usually IP-Cores are delivered as GIT repository and already contain the sources.

By default all files are compiled into a library named accoding to the IP-Core name and version but the user can optionally choose a different library using the *lib* parameter. 

By default the file type is determined by Vivado automatically but the auto detected type can be overwritten manually. For VHDL, VHDL 2008 is used by default.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> srcs </td>
      <td> No </td>
      <td> Path to one or more source files. If multiple source files should be added, a list of paths must be passed. </td>
    </tr>
    <tr>
      <td> lib </td>
      <td> Yes </td>
      <td> VHDL library to compile the files into, default*<ip_name>_<ip_version>* if ths parameter is omitted or "NONE" is passed. </td>
    </tr>
    <tr>
      <td> type </td>
      <td> Yes </td>
      <td> Vivado file type. By default, the file type is detected automatically. Automatic detection can also be achieved by passing "NONE". </td>
    </tr>
</table>

### add_lib_relative
**Usage**

```
add_lib_relative <libPath> <files> <lib> <type>
```

**Description**

Add one or more library files to the IP-Core. This command does not copy the library files into the IP-Core but
just links them using relative paths. As a result, in every project its own version of the library could be used. To
copy the library files into the IP-Core, use [add_lib_copied](add_lib_copied) .

By default all files are compiled into a library named accoding to the IP-Core name and version but the user can optionally choose a different library using the *lib* parameter.

By default the file type is determined by Vivado automatically but the auto detected type can be overwritten manually. For VHDL, VHDL 2008 is used by default.

**Parameters**

<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> libPath </td>
      <td> No </td>
      <td> Path of the library (directory containing the files) </td>
    </tr>
    <tr>
      <td> files </td>
      <td> No </td>
      <td> List of files to add to the IP-Core </td>
    </tr>	
    <tr>
      <td> lib </td>
      <td> Yes </td>
      <td> VHDL library to compile the files into, default*<ip_name>_<ip_version>* if ths parameter is omitted or "NONE" is passed. </td>
    </tr>
    <tr>
      <td> type </td>
      <td> Yes </td>
      <td> Vivado file type. By default, the file type is detected automatically. Automatic detection can also be achieved by passing "NONE". </td>
    </tr>
</table>

### add_lib_copied
**Usage**

```
add_lib_copied <tgtPath> <libPath> <files> <lib> <type>
```

**Description**

Add one or more library files to the IP-Core. The library files are copied into the IP-Core automatically. As a result, the 
same library files are used independently of the environment of the IP-Core. The drawback of this approach is that the library
files are delivered as part of the IP-Core and it is not possible to easily find out which version (commit) of the library
they represent.

By default all files are compiled into a library named accoding to the IP-Core name and version but the user can optionally choose a different library using the *lib* parameter.

By default the file type is determined by Vivado automatically but the auto detected type can be overwritten manually. For VHDL, VHDL 2008 is used by default.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> tgtPath </td>
      <td> No </td>
      <td> Relative path to the directory the files shall be copied to </td>
    </tr>	
    <tr>
      <td> libPath </td>
      <td> No </td>
      <td> Path of the library (directory containing the files) </td>
    </tr>
    <tr>
      <td> files </td>
      <td> No </td>
      <td> List of files to add to the IP-Core </td>
    </tr>	
    <tr>
      <td> lib </td>
      <td> Yes </td>
      <td> VHDL library to compile the files into, default*<ip_name>_<ip_version>* if ths parameter is omitted or "NONE" is passed. </td>
    </tr>
    <tr>
      <td> type </td>
      <td> Yes </td>
      <td> Vivado file type. By default, the file type is detected automatically. Automatic detection can also be achieved by passing "NONE". </td>
    </tr>
</table>

### add_gui_support_tcl

**Usage**
```
add_gui_support_tcl <script> 
```

**Description**
Somtimes it is useful being able to use custom TCL procedures in parameter calculations within the IP customization GUI. To do so, you can add a script containing these procedures using this command.

Be aware that some quirks of the Vivado GUI lead to the situation that the custom TCL procedures work with the packaged IP but they report errors in the preview within the IP packager.

**Parameters**

<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> script </td>
      <td> No </td>
      <td> Path of the script to source (relative to the IP-main directory) </td>
    </tr>		
</table>

### gui_parameter_set_expression

**Usage**
```
gui_parameter_set_expression <expression> 
```

**Description**
Instead of letting the user set a parameter, this command forces the parameter to be calculated basedon an expression. It is alos possible to reference otehr parameters (e.g. using the expression *{$Channels_g > 3}*).

Note that the expression must be passed in curly braces.

If you want to use more complex expressions, have a look at the command [add_gui_support_tcl](#add_gui_support_tcl) 

**Parameters**

<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> expression </td>
      <td> No </td>
      <td> Expression to calculate the paramter </td>
    </tr>		
</table>

### gui_add_page
**Usage**

```
gui_add_page <name> 
```

**Description**  
Add a page to the IP-Configuration GUI that can be displayed in Vivado.

**Parameters**

<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> name </td>
      <td> No </td>
      <td> Name resp. title of the GUI page to add </td>
    </tr>		
</table>

### gui_create_parameter
**Usage**

```
gui_create_parameter <vhdlName> <displayName> 
```

**Description**

Make a HDL parameter (generic) visible in the IP-Configuration GUI. After all settings are made to the 
parameter (e.g. choose what widget to use for it, set its valid range), it must be added to the GUI using
[gui_add_parameter](#gui_add_parameter) .

By default parameters are shown as textboxes.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> vhdlName </td>
      <td> No </td>
      <td> Name of the HDL parameter that should be visible in the GUI. </td>
    </tr>	
    <tr>
      <td> displayName </td>
      <td> No </td>
      <td> Name to display in the GUI. </td>
    </tr>	
</table>

### gui_create_user_parameter
**Usage**

```
gui_create_user_parameter <paramName> <type> <initialValue> <displayName>
```

**Description**

Create a GUI parameter that is not related to a HDL parameter. Such GUI parameters can for example be used
to show/hide ports depending on the settings of a parameter. After all settings are made to the 
parameter (e.g. choose what widget to use for it, set its valid range), it must be added to the GUI using
[gui_add_parameter](#gui_add_parameter) .

By default parameters are shown as textboxes.

**Parameters**

<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> paramName </td>
      <td> No </td>
      <td> Name of the parameter. This name is also displayed in the GUI. </td>
    </tr>	
    <tr>
      <td> type </td>
      <td> No </td>
      <td> Type of the parameter (e.g. "bool"). </td>
    </tr>	
    <tr>
      <td> type </td>
      <td> No </td>
      <td> Type of the parameter. Possible values are: long, float, bool, bitString, String. </td>
    </tr>		
    <tr>
      <td> displayName </td>
      <td> Yes </td>
      <td> Text to display for the parameter in the GUI </td>
    </tr>	
</table>

### gui_parameter_set_widget_dropdown
**Usage**

```
gui_parameter_set_widget_dropdown <values> 
```

**Description**

This command must be called between [gui_create_parameter](#gui_create_parameter)/[gui_create_user_parameter](#gui_create_user_parameter) 
and [gui_add_parameter](#gui_add_parameter) for a given parameter. It configures the parameter to be shown in the GUI as dropdown menu.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> values </td>
      <td> No </td>
      <td> List of possible values to show in the dropdown menu. </td>
    </tr>		
</table>

### gui_parameter_set_widget_checkbox
**Usage**

```
gui_parameter_set_widget_checkbox 
```

**Description**

This command must be called between [gui_create_parameter](#gui_create_parameter)/[gui_create_user_parameter](#gui_create_user_parameter) 
and [gui_add_parameter](#gui_add_parameter) for a given parameter. It configures the parameter to be shown in the GUI as checkbox. 

Checkboxes are only available for "bool" parameters.

**Parameters**  
None

### gui_parameter_set_range
**Usage**

```
gui_parameter_set_range <min> <max> 
```

**Description**

This command must be called between [gui_create_parameter](#gui_create_parameter)/[gui_create_user_parameter](#gui_create_user_parameter) 
and [gui_add_parameter](#gui_add_parameter) for a given parameter. It configures the valid range for a numeric parameter. 

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> min </td>
      <td> No </td>
      <td> Lower bound of the valid range </td>
    </tr>	
    <tr>
      <td> max </td>
      <td> No </td>
      <td> Upper bound of the valid range </td>
    </tr>		
</table>

### gui_parameter_set_enablement
**Usage**

```
gui_parameter_set_enablement <expr> <defauult> 
```

**Description**

This command allows setting the enablement behavior of a parameter. Disabled parameters are greyed out and not editable.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> expr </td>
      <td> No </td>
      <td> Expression in curly braces (e.g. *{Channels_g>3}*) </td>
    </tr>	
    <tr>
      <td> default </td>
      <td> No </td>
      <td> Default state of parameter enablement </td>
    </tr>		
</table>

### gui_parameter_text_below
**Usage**

```
gui_parameter_text_below <text>
```

**Description**

Add an explanatory text below a parameter.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> text </td>
      <td> No </td>
      <td> Text to place below the parameter </td>
    </tr>		
</table>

### gui_add_parameter
**Usage**

```
gui_add_parameter
```

**Description**

Add the current paramter (the last one created) to the current page of the GUI (last page created).

**Parameters**  
None

### add_port_enablement_condition
**Usage**

```
add_port_enablement_condition <port> <condition> 
```

**Description**

The port specified is only visible in the GUI if the given condition is valid.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> port </td>
      <td> No </td>
      <td> Port that depends on enablement condition. Note that wildcards are allowed (e.g. "Adc_*")</td>
    </tr>	
    <tr>
      <td> condition </td>
      <td> No </td>
      <td> Condition that must be true to enable the port. Parameters to be evaluate must be passed as 
	       TCL variables. An example for the enablement condition is "\$C_ADC_CHANNELS > 3". The Backslash
		   before the dolar sign is required to prevent TCL from evaluating the parameter-variable in your script. </td>
    </tr>		
</table>

### add_interface_enablement_condition
**Usage**

```
add_interface_enablement_condition <interface> <condition> 
```

**Description**

The interface specified is only visible in the GUI if the given condition is valid. 

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> interfae </td>
      <td> No </td>
      <td> Interface that depends on enablement condition. Note that wildcards are allowed (e.g. "Adc_*")</td>
    </tr>	
    <tr>
      <td> condition </td>
      <td> No </td>
      <td> Condition that must be true to enable the interface. Parameters to be evaluate must be passed as 
	       TCL variables. An example for the enablement condition is "\$C_ADC_CHANNELS > 3". The Backslash
		   before the dolar sign is required to prevent TCL from evaluating the parameter-variable in your script. </td>
    </tr>		
</table>

### remove_autodetected_interface
**Usage**

```
remove_autodetected_interface <name> 
```

**Description**

Vivado always tries to parse the interfaces automatically from the HDL code. However, sometimes it does this wrongly (e.g.
reset polarity is wrong). If Vivado messes up an interface, the automatically parsed interface can be removed by using this command.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> name </td>
      <td> No </td>
      <td> Name of the interface to remove </td>
    </tr>		
</table>

### add_clock_in_interface
**Usage**

```
add_clock_in_interface <portname> 
```

**Description**

Vivado does only recognize clock inputs is they have a *_clk* suffix. If a clock port is named differently, it is not recognized as clock and hence it can also not be used as clock for an interface (see [set_interface_clock](#set_interface_clock)). In this case, the *add_clock_in_interface* can be used to let Vivado know that a port is a clock input independently of its name.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> portname </td>
      <td> No </td>
      <td> Name of the clock input purt </td>
    </tr>		
</table>

### set_interface_clock
**Usage**

```
set_interface_clock "S00_AXIS" "AXI_ACLK"
```

**Description**

Set the clock related to an interface. Vivado usually detects interfaces correctly but often messes up the clock associations. Having no clock associated can lead to errors during the generation of a block design. Therefore it is recommended to do do the clock-interface associations manually using *set_interface_clock*.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> interface </td>
      <td> No </td>
      <td> Name of the interface to set the associated clock for </td>
    </tr>
    <tr>
      <td> clock </td>
      <td> No </td>
      <td> Name of the clock interface to associate to the interface </td>
    </tr>
</table>


### add_drivers_relative
**Usage**

```
add_drivers_relative <dir> <files>
```

**Description**

This command adds one or more driver files (.c/.h) to the IP-Core. The files paths are given relatively to the driver main directory *dir*. 

The files .mdd, .tcl and Makefile are generated automatically inside the driver directory but they must be checked into GIT anyway. These files are required by Vivado/SDK when using the IP-Core but they can be generated when creating the IP. The reason for generating them is that they could potentially change in future. In this case they can easily be re-generated for future vivado versions.

The driver sources must be located in the folder *DRIVER_MAIN/src* due to Limitations of Vivado. A folder *DRIVER_MAIN/data* must also exist, also because Vivado expects this folder.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> dir </td>
      <td> No </td>
      <td> Driver main directory (must be named according to IP-Core) </td>
    </tr>
    <tr>
      <td> files </td>
      <td> No </td>
      <td> List of driver source files (relative to *dir*) </td>
    </tr>
</table>

### set_interface_mode
**Usage**

```
set_interface_mode <interface> <mode>
```

**Description**

Set the mode of an interface. Usually the mode is automatically detected by Vivado but in some cases (e.g. monitor interfaces) this does not always work reliably.

**Parameters**  
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> interface </td>
      <td> No </td>
      <td> Name of the interface to set the mode for</td>
    </tr>
    <tr>
      <td> mode </td>
      <td> No </td>
      <td> Interface mode to use (*master*, *slave* or *monitor*) </td>
    </tr>
</table>


## Run Commands

### package_ip
**Usage**

```
package_ip <tgtDir> <edit> <synth> <part>
```

**Description**

This command packages the IP-core described with the other commands. It is therefore always called at the end of a packaging script.
Additionally a test-synthesis can be ran to check if all files required are added to the IP-core.

**Parameters**
<table>
    <tr>
      <th width="200"><b>Parameter</b></th>
      <th align="center" width="80"><b>Optional</b></th>
      <th align="right"><b>Description</b></th>
    </tr>
    <tr>
      <td> tgtDir </td>
      <td> No </td>
      <td> Directory to store the IP-Core defintion in </td>
    </tr>
    <tr>
      <td> edit </td>
      <td> Yes </td>
      <td> If this parameter is set to "true", the IP-packager is left open. This allows manually checking all entries for debugging reasons. </td>
    </tr>
    <tr>
      <td> synth </td>
      <td> Yes </td>
      <td> If this parameter is set to "true", the IP-Core is synthesized after packaging to check if all files required are present. </td>
    </tr>
    <tr>
      <td> part </td>
      <td> Yes </td>
      <td> Xilinx part number to use for the test-synthesis. By default Vivado chooses an available part. </td>
    </tr> 
</table>

