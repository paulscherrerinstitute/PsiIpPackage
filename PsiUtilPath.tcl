##############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
##############################################################################

namespace eval psi::util::path {

	#Get Relative path from a given directory to a given file
	#
	# @param fromDir 			Directory the path should be relative to
	# @param toFile				File the path points to
	# @param currentFolderDot	true: use ./anyFile.bla false: use anyFile.bla
	proc relTo {fromDir toFile {currentFolderDot true}} {
	  set fromDirParts [file split [file normalize $fromDir]]
	  set toFileParts [file split [file normalize $toFile]]
	  if {![string equal [lindex $fromDirParts 0] [lindex $toFileParts 0]]} {
		  # not on *n*x then
		  return -code error "$targetfile not on same volume as $currentpath"
	  }
	  while {[string equal [lindex $fromDirParts 0] [lindex $toFileParts 0]] && [llength $fromDirParts] > 0} {
		  # discard matching components from the front
		  set fromDirParts [lreplace $fromDirParts 0 0]
		  set toFileParts [lreplace $toFileParts 0 0]
	  }
	  set prefix ""
	  if {[llength $fromDirParts] == 0} {
		  # just the file name, so targetfile is lower down (or in same place)
		  if {$currentFolderDot} {
			set prefix "."
		  } else {
			set prefix ""
		  }
	  }
	  # step up the tree
	  for {set i 0} {$i < [llength $fromDirParts]} {incr i} {
		  append prefix " .."
	  }
	  # stick it all together (the eval is to flatten the targetfile list)
	  return [eval file join $prefix $toFileParts]
	}
}