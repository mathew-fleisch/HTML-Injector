#!/bin/bash
#clear
echo "--------- HTML Injector [START] ---------"

#Initialize variables
flag_recursive=false
flag_separate=false
flag_combine=false
flag_verbose=false
comment_flag="^.*BLACKHATINCLUDE.*inc_.*$"
include_path="../includes"

#Declare functions
function parse_inject
{
	flag_verbose=$1
	comment_flag=$2
	target_file=$3
	target_found=false
	output_file=""
	incs_found=0
	#if [ $flag_verbose == true ]; then
	#	echo "Function parse_inject(\$flag_verbose = '$flag_verbose', \$comment_flag = '$comment_flag', \$target_file = '$target_file')"
	#fi
	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		target_file_lines=`wc -l "$target_file" | sed "s/^\ *//" | sed "s/\ .*$//"`
		if [ $flag_verbose == true ]; then
			echo ""
			echo "   Target File Before: $target_file_size and $target_file_lines lines"
		fi
		IFS=$'\n'
		for next in `cat $target_file`
		do	
			if [[ $next =~ $comment_flag ]]; then
				target_found=true

				target_include_file=`echo "$next" | sed "s/^.*inc_//" | sed "s/\ .*$//"`
				#echo "$next"

				#if [ $flag_verbose == true ]; then
				#	echo "     Is this an include file: '$target_include_file.html' ??? ";
				#fi

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
		target_file_lines_injected=`wc -l "$target_file" | sed "s/^\ *//" | sed "s/\ .*$//"`
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
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}

function parse_strip
{
	flag_verbose=$1
	comment_flag=$2
	target_file=$3
	target_found=false
	output_file=""
	switch=false
	local_count=0
	incs_found=0
	#if [ $flag_verbose == true ]; then
	#	echo "Function parse_strip(\$flag_verbose = '$flag_verbose', \$comment_flag = '$comment_flag', \$target_file = '$target_file')"
	#fi
	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		if [ $flag_verbose == true ]; then
			echo ""
			echo "   Target File Before: $target_file_size"
		fi
		IFS=$'\n'
		for next in `cat $target_file`
		do	
			if [[ $next =~ ^.*sourceStart.*$ ]]; then
				switch=true
				incs_found=$((incs_found+1))
			else
				if [[ $next =~ ^.*sourceEnd.*$ ]]; then
					switch=false
					temp=`echo "$next" | sed "s/^.*sourceEnd_//" | sed "s/\ .*$//"`
					next="<!-- BLACKHATINCLUDE | inc_$temp -->"
					echo "     Include File: $include_path/$temp.html(stripped)"
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
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}

function parse_directory
{
	flag_verbose=$1
	comment_flag=$2
	recursive=$3
	target_directory=$4
	target_found=false
	output_file=""
	incs_found=0
	#if [ $flag_verbose == true ]; then
	#	echo "Function parse_directory(\$flag_verbose = '$flag_verbose', \$comment_flag = '$comment_flag', \$recursive = '$recursive', \$target_directory = '$target_directory')"
	#fi
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
				inject_res=$( parse_inject $flag_verbose $comment_flag $target_file )
				echo "Inject response: $inject_res"
			fi
			echo ""
			echo "    <>------------<          >------------<>"
			echo ""
		done
	else
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "The target directory you specified doesn't appear to be a directory..."
		echo "target directory: $target_directory"
		exit 1
	fi

}

function strip_directory
{
	flag_verbose=$1
	comment_flag=$2
	recursive=$3
	target_directory=$4
	target_found=false
	output_file=""
	incs_found=0
	#if [ $flag_verbose == true ]; then
	#	echo "Function strip_directory(\$flag_verbose = '$flag_verbose', \$comment_flag = '$comment_flag', \$recursive = '$recursive', \$target_directory = '$target_directory')"
	#fi
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
				strip_res=$( parse_strip $flag_verbose $comment_flag $target_file )
				echo "Strip response[$target_file]: $strip_res"
			fi
			echo ""
			echo "    <>------------<          >------------<>"
			echo ""
		done
	else
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
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
	-c|--combine)
	flag_combine=true
	shift
	;;
	-s|--separate)
	flag_separate=true
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

if [[ $flag_combine == true || $flag_separate == true ]]; then
	if [ $flag_verbose == true ]; then
		echo "   >---------- PARAMETERS ----------<"
		echo "Combine(true/false):   <------------->   $flag_combine"
		echo "Separate(true/false):   <------------>   $flag_separate"
		echo "Recursive(true/false):   <----------->   $flag_recursive"
		echo "Target Directory(path):   <---------->   $target_directory"
		echo "Target File(path):   <--------------->   $target_file"
	fi

	#Error out if both combine and separate flags are detected
	if [[ $flag_combine == true && $flag_separate == true ]]; then
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "You must choose only one (combine or separate, not both)..." 1>&2
		exit 1
	fi
	
	#Error out if both a target directory and target file have been defined
	target_directory_length=${#target_directory}
	target_file_length=${#target_file}
	if [ $flag_verbose == true ]; then
		echo "File Length: $target_file_length       Directory Length: $target_directory_length"
	fi
	if [[ $target_file_length -gt 0 && $target_directory_length -gt 0 ]]; then
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "You must either choose to modify a single file or an entire directory, not both." 1>&2
		exit 1
	fi

	#Error out if no target file or directory has been defined
	if [[ $target_file_length == 0 && $target_directory_length == 0 ]]; then
		echo ""
		echo " ***************   FATAL ERROR!!   ***************"
		echo "You must either choose to modify a single file or an entire directory." 1>&2
		exit 1
	fi

	#Passed all logic traps
	echo "   <>---------- Run Script! ----------<>"

	#Combine/merge include files 
	if [ $flag_combine == true ]; then
		
		#Run combine on a single file
		if [ $target_file_length -gt 0 ]; then
			inject_res=$( parse_inject $flag_verbose $comment_flag $target_file )
			echo "Inject includes here: $target_file"
			echo "Inject response: $inject_res"
		fi

		
		#Run combine on a directory 
		if [ $target_directory_length -gt 0 ]; then
			inject_res=$( parse_directory $flag_verbose $comment_flag $flag_recursive $target_directory )
			echo "Inject includes here: $target_directory"
			echo "Inject response: $inject_res"
		fi

	fi

	#Separate include files
	if [ $flag_separate == true ]; then

		#Run separate on a single file
		if [ $target_file_length -gt 0 ]; then
			strip_res=$( parse_strip $flag_verbose $comment_flag $target_file )
			echo "Strip includes here: $target_file"
			echo "Strip response: $strip_res"
		fi
		
		#Run separate on a directory 
		if [ $target_directory_length -gt 0 ]; then
			strip_res=$( strip_directory $flag_verbose $comment_flag $flag_recursive $target_directory )
			echo "Strip includes here: $target_directory"
			echo "Strip response: $strip_res"
		fi

	fi
	echo "   <>---------- Script Complete! ----------<>"
else
	echo "You must choose either to combine or separate files and define a file before this script can run..."
	echo ""
	echo "-c --combine   <--------------->   This flag is false by default and causes the "
	echo "                                   includes to be merged with the target file(s)"
	echo ""
	echo "-s --separate   <-------------->   This flag is false by default and causes the "
	echo "                                   include files to be stripped from the target "
	echo "                                   file(s)"
	echo ""
	echo "-r --recursive   <------------->   This flag is false by default and causes the "
	echo "                                   combine/separate action to be applied to all "
	echo "                                   children files starting in the target directory"
	echo ""
	echo "-d --target-directory  <------->   This parameter will set a secific directory to "
	echo "                                   either combine or separate. Note: The recursive"
	echo "                                   flag is false by default."
	echo "-f --target-file   <----------->   This parameter will combine or separate include"
	echo "                                   files into one file"
	echo ""
	echo "-v --verbose   <--------------->   Show more information about what is happening "
	echo "                                   during script execution"
	echo ""
	echo ""
	echo "Example Scenario: Social icons get separated out into a file named 'social.html'"
	echo " --> Within social.html two html comments will be appended to the very first and "
	echo "     last lines that look like this:"
	echo "              <!-- BLACKHATINCLUDE | sourceStart_social -->"
	echo "               <!-- BLACKHATINCLUDE | sourceEnd_social -->"
	echo "        -> 'BLACKHATINCLUDE' indicates to this script where to combine to or separate from"
	echo "        -> 'sourceStart_' indicates the start of a template file so that it can be stripped out later"
	echo "        -> 'sourceEnd_' indicates the end of a template file so that it can be stripped otu later"
	echo "        -> 'social' will reference the filename of social.html"
	echo " --> Within the target file(s) (where social.html will be injected into) another "
	echo "     html comment takes the place of the once static content:"
	echo "              <!-- BLACKHATINCLUDE | inc_social -->"
	echo "        -> 'BLACKHATINCLUDE' indicates to this script where to combine to or separate from"
	echo "        -> 'inc_' indicates the location of an inject point"
	echo "        -> 'social' will reference the filename of social.html"
fi
echo ""
echo "--------- HTML Injector [START] ---------"
