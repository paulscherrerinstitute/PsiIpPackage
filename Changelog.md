## 2.0.0
* First Open Source Release (older versions not kept in history)
* Changes
  * Removed *has_std_axi_if* command (too PSI specific)
  * Added TCL utilities (*PsiUtilPath* and *PsiUtilString*) in this repo instead of a dependency to a separate TCL Utilities repo

## 1.6.0
* Added Features
  * Allow setting display name in gui_create_user_parameter
* Bugfixes 
  * Change relative paths to not include "./" as required by 2019.1

## 1.5.0

* Added Features
  * Added *add\_interface\_enablement\_condition* command to enable/disable whole interfaces
* Bugfixes
  * Fixed pint message during compilation of drivers

## 1.4.1

* Added Features
  * None
* Bugfixes
  * Print propper error message for unreferenced files (led to silent crash before)
  * Fixed path calculations to also work on Linux and with AFS
  * Part number was not used in build, fixed this

## 1.4.0

* Added Features
  * Added selection of device for test synthesis
* Bugfixes
  * Added all currently known families to "supported families" (otherwise families in beta state such as MPSOC did not work)

## 1.3.0
* Added Features
  * Added the option to manually specify the top level entity
  * Added code to support Vivado 2017.4 (1.2.0 does not work for 2017.4)
* Bugfixes
  * None

## 1.2.0
* Added Features
  * Implemented the handling of software drivers
* Bugfixes
  * None

## 1.1.0
* Added Features
  * Implemeted the option to manually associate a clock with an interface (Vivado often fails to automatically detect these relationships)
* Bugfixes
  * None

## V1.01
* Added Features
  * Implemented support for copied library files (copied into IP-core instead of relative reference)
  * Implemented pure GUI parameter (parameter for GUI that does not map to a VHDL generic)
  * Implemented propper handling of TCL namespaces
* Bugfixes
  * None

## V1.00
* First release