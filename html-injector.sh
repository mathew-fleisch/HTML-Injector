#!/bin/bash
#clear
echo "--------- HTML Injector [START] ---------"
source "config.sh"

#Initialize variables
IFS=$'\n'
flag_recursive=false
flag_strip=false
flag_inject=false
flag_verbose=false

#Declare functions
function parse_inject_file
{
	flag_verbose=$1
	regex_match_include=$2
	target_file=$3
	target_found=false
	output_file=""
	incs_found=0
	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		target_file_lines=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		if [ $flag_verbose == true ]; then
			echo "$IFS   Target File Before: $target_file_size and $target_file_lines lines"
		fi
		for next in `cat $target_file`
		do	
			if [[ $next =~ $regex_match_include ]]; then
				target_found=true

				target_include_file=`echo "$next" | sed "s/$regex_match_include_to_filename//" | sed "s/$regex_match_first_space_to_end//"`
				#echo "$next"

				target_include_file="$include_path/$target_include_file.html"
				if [ -f $target_include_file ]; then
					echo "     Include File: $target_include_file(added)"	
					incs_found=$((incs_found+1))
					output_file="$output_file$IFS`cat $target_include_file`"
				else 
					echo " ** Include File does NOT Exist: '$target_include_file' ** "
					return 1
				fi
			else
				output_file="$output_file$IFS$next"
			fi
		done
		echo "$output_file" > $target_file
		target_file_size_injected=`ls -lah "$target_file" | awk '{ print $5}'`
		target_file_lines_injected=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		if [ $flag_verbose == true ]; then
			target_file_lines_diff=`expr $target_file_lines_injected - $target_file_lines`
			echo "     Lines Added: $target_file_lines_diff"
			echo "   Target File After: $target_file_size_injected and $target_file_lines_injected lines"
		fi
		if [ $incs_found -gt 0 ]; then
			echo "---> Includes Found: $incs_found"
		else
			echo "---> WARNING: No Includes processed in this file"
		fi
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}

function parse_strip_file
{
	flag_verbose=$1
	regex_match_include=$2
	target_file=$3
	target_found=false
	output_file=""
	switch=false
	local_count=0
	incs_found=0
	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		if [ $flag_verbose == true ]; then
			echo "$IFS   Target File Before: $target_file_size"
		fi
		for next in `cat $target_file`
		do	
			if [[ $next =~ $regex_match_inc_start ]]; then
				switch=true
				incs_found=$((incs_found+1))
			else
				if [[ $next =~ $regex_match_inc_end ]]; then
					switch=false
					temp_filename=`echo "$next" | sed "s/$regex_match_inc_end_to_filename//" | sed "s/$regex_match_first_space_to_end//"`
					next="<!-- $inc_flag | $inc_filename$temp_filename -->"
					echo "     Include File: $include_path/$temp_filename.html(stripped)"
				fi

				if [ $switch == false ];then
					output_file="$output_file$IFS$next"
				fi
			fi
			if [ $switch == true ]; then
				local_count=$((local_count+1))
			fi
		done
		#echo "$output_file"
		echo "$output_file" > $target_file
		target_file_size_stripped=`ls -lah "$target_file" | awk '{ print $5}'`
		if [ $flag_verbose == true ]; then
			echo "     Lines Removed: $local_count"
			echo "   Target File After: $target_file_size_stripped"
		fi
		if [ $incs_found -gt 0 ]; then
			echo "---> Includes Found: $incs_found"
		else
			echo "---> WARNING: No Includes processed in this file"
		fi
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}

function parse_inject_directory
{
	flag_verbose=$1
	regex_match_include=$2
	recursive=$3
	target_directory=$4
	target_found=false
	output_file=""
	incs_found=0
	if [ -d $target_directory ]; then
		echo "Target directory was found: $target_directory"
		#if [ $target_directory =~ ^/.*$ ]; then
		#echo "$(cd $target_directory; pwd)/."
		#fi
		echo "    <>------------<          >------------<>"
		cmd_inc=""
		if [ $recursive == false ]; then 
			cmd_inc="-maxdepth 1"
		fi
		for target_file in `find "$target_directory" -name '*.html' $cmd_inc`
		do
			echo "File Found: $target_file"	
			#echo "Inject includes here: $target_file"
			#echo "Includes Path: $include_path"
			tmp_inc_found=false
			for test_include in `find "$include_path" -name '*.html'`
			do
				if [ $target_file == $test_include ]; then
					echo "Skip stripping source include: $target_file"
					tmp_inc_found=true
				fi
			done
			if [ $tmp_inc_found == false ]; then
				inject_res=$( parse_inject_file $flag_verbose $regex_match_include $target_file )
				echo "Inject response: $inject_res"
			fi
			echo "$IFS    <>------------<          >------------<>$IFS"
		done
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target directory you specified doesn't appear to be a directory..."
		echo "target directory: $target_directory"
		exit 1
	fi

}

function parse_strip_directory
{
	flag_verbose=$1
	regex_match_include=$2
	recursive=$3
	target_directory=$4
	target_found=false
	output_file=""
	incs_found=0
	if [ -d $target_directory ]; then
		echo "Target directory was found: $target_directory"
		#if [ $target_directory =~ ^/.*$ ]; then
		#echo "$(cd $target_directory; pwd)/."
		#fi
		echo "    <>------------<          >------------<>"
		cmd_inc=""
		if [ $recursive == false ]; then 
			cmd_inc="-maxdepth 1"
		fi
		for target_file in `find "$target_directory" -name '*.html' $cmd_inc`
		do
			echo "File Found: $target_file"	
			#echo "Strip includes here: $target_file"
			tmp_inc_found=false
			for test_include in `find "$include_path" -name '*.html'`
			do
				if [ $target_file == $test_include ]; then
					echo "Skip stripping source include: $target_file"
					tmp_inc_found=true
				fi
			done
			if [ $tmp_inc_found == false ]; then
				strip_res=$( parse_strip_file $flag_verbose $regex_match_include $target_file )
				echo "Strip response[$target_file]: $strip_res"
			fi
			echo "$IFS    <>------------<          >------------<>$IFS"
		done
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target directory you specified doesn't appear to be a directory..."
		echo "target directory: $target_directory"
		exit 1
	fi

}


#Parse command line arguments
while [[ $# > 1 ]]
do
key="$1"
case $key in
	-i|--inject)
	flag_inject=true
	shift
	;;
	-s|--strip)
	flag_strip=true
	shift
	;;
	-r|--recursive)
	flag_recursive=true
	shift
	;;
	-d|--target-directory)
	target_directory="$2"
	shift
	;;
	-f|--target-file)
	target_file="$2"
	shift
	;;
	-v|--verbose)
	flag_verbose=true
	shift
	;;
	--default)
	DEFAULT=YES
	shift
	;;
	*)
	# unknown option
	;;
esac
shift
done

if [[ $flag_inject == true || $flag_strip == true ]]; then
	if [ $flag_verbose == true ]; then
		echo "   >---------- PARAMETERS ----------<"
		echo "Inject(true/false):   <------------->   $flag_inject"
		echo "Strip(true/false):   <------------>   $flag_strip"
		echo "Recursive(true/false):   <----------->   $flag_recursive"
		echo "Target Directory(path):   <---------->   $target_directory"
		echo "Target File(path):   <--------------->   $target_file"
	fi

	#Error out if both inject and strip flags are detected
	if [[ $flag_inject == true && $flag_strip == true ]]; then
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "You must choose only one (inject or strip, not both)..." 1>&2
		exit 1
	fi
	
	#Error out if both a target directory and target file have been defined
	target_directory_length=${#target_directory}
	target_file_length=${#target_file}
	if [ $flag_verbose == true ]; then
		echo "File Length: $target_file_length       Directory Length: $target_directory_length"
	fi
	if [[ $target_file_length -gt 0 && $target_directory_length -gt 0 ]]; then
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "You must either choose to modify a single file or an entire directory, not both." 1>&2
		exit 1
	fi

	#Error out if no target file or directory has been defined
	if [[ $target_file_length == 0 && $target_directory_length == 0 ]]; then
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "You must either choose to modify a single file or an entire directory." 1>&2
		exit 1
	fi

	#Passed all logic traps
	echo "   <>---------- Run Script! ----------<>"

	#Inject/merge include files 
	if [ $flag_inject == true ]; then
		
		#Run inject on a single file
		if [ $target_file_length -gt 0 ]; then
			inject_res=$( parse_inject_file $flag_verbose $regex_match_include $target_file )
			echo "Inject includes here: $target_file"
			echo "Inject response: $inject_res"
		fi

		
		#Run inject on a directory 
		if [ $target_directory_length -gt 0 ]; then
			inject_res=$( parse_inject_directory $flag_verbose $regex_match_include $flag_recursive $target_directory )
			echo "Inject includes here: $target_directory"
			echo "Inject response: $inject_res"
		fi

	fi

	#Strip include files
	if [ $flag_strip == true ]; then

		#Run strip on a single file
		if [ $target_file_length -gt 0 ]; then
			strip_res=$( parse_strip_file $flag_verbose $regex_match_include $target_file )
			echo "Strip includes here: $target_file"
			echo "Strip response: $strip_res"
		fi
		
		#Run strip on a directory 
		if [ $target_directory_length -gt 0 ]; then
			strip_res=$( parse_strip_directory $flag_verbose $regex_match_include $flag_recursive $target_directory )
			echo "Strip includes here: $target_directory"
			echo "Strip response: $strip_res"
		fi

	fi
	echo "   <>---------- Script Complete! ----------<>"
else
	echo "You must choose either to inject or strip files and define a file before this script can run..."
	echo ""
	echo "-i --inject   <--------------->   This flag is false by default and causes the "
	echo "                                   includes to be merged with the target file(s)"
	echo ""
	echo "-s --strip   <-------------->   This flag is false by default and causes the "
	echo "                                   include files to be stripped from the target "
	echo "                                   file(s)"
	echo ""
	echo "-r --recursive   <------------->   This flag is false by default and causes the "
	echo "                                   inject/strip action to be applied to all "
	echo "                                   children files starting in the target directory"
	echo ""
	echo "-d --target-directory  <------->   This parameter will set a secific directory to "
	echo "                                   either inject or strip. Note: The recursive"
	echo "                                   flag is false by default."
	echo "-f --target-file   <----------->   This parameter will inject or strip include"
	echo "                                   files into one file"
	echo ""
	echo "-v --verbose   <--------------->   Show more information about what is happening "
	echo "                                   during script execution"
	echo "$IFS"
	echo "Example Scenario: Social icons get stripped out into a file named 'social.html'"
	echo " --> Within social.html two html comments will be appended to the very first and "
	echo "     last lines that look like this:"
	echo "              <!-- BLACKHATINCLUDE | sourceStart_social -->"
	echo "               <!-- BLACKHATINCLUDE | sourceEnd_social -->"
	echo "        -> 'BLACKHATINCLUDE' indicates to this script where to inject to or strip from"
	echo "        -> 'sourceStart_' indicates the start of a template file so that it can be stripped out later"
	echo "        -> 'sourceEnd_' indicates the end of a template file so that it can be stripped otu later"
	echo "        -> 'social' will reference the filename of social.html"
	echo " --> Within the target file(s) (where social.html will be injected into) another "
	echo "     html comment takes the place of the once static content:"
	echo "              <!-- BLACKHATINCLUDE | inc_social -->"
	echo "        -> 'BLACKHATINCLUDE' indicates to this script where to inject to or strip from"
	echo "        -> 'inc_' indicates the location of an inject point"
	echo "        -> 'social' will reference the filename of social.html"
fi
echo "$IFS--------- HTML Injector [END] ---------$IFS"
