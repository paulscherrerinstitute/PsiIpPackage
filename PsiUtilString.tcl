##############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
##############################################################################

namespace eval psi::util::string {

	#Copy a file and replace one or mor tags within a template file
	#
	# @param fromPath		Source path of the file (template)
	# @param toPath			Destination path to write the modified file to
	# @param tags			A dictonary containing tags as keys and their replacements as values
	proc copyAndReplaceTags {fromPath toPath tags} {
		#read file
		set fp [open $fromPath r]
		set content [read $fp]
		close $fp
		
		#replace tags
		foreach item [dict keys $tags] {
			set val [dict get $tags $item]
			set content [regsub -all $item $content $val]
        }
		
		#write file
		set fp [open $toPath "w+"]
		puts -nonewline $fp $content
		close $fp		
	}
}