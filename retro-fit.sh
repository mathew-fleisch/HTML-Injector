#!/bin/bash

source "config.sh"
#globals
IFS=$'\n'
target_directory=""
target_directory_length=0
target_file=""
target_file_length=0
header_pre_path=""
header_pre_path_length=0
header_post_path=""
header_post_path_length=0
footer_path=""
footer_path_length=0
flag_verbose=false
flag_recursive=false
line_number=0


function retrofit_file
{
	flag_verbose=$1
	target_file=$2
	header_pre_path=$3
	header_post_path=$4
	footer_path=$5

	#check each path to make sure file exists, and exit if not

	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		target_file_lines=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		if [ $flag_verbose == true ]; then
			echo "$IFS   Target File Before: $target_file_size and $target_file_lines lines"
		fi
		for next in `cat $target_file`
		do	
			line_number=$((line_number+1))
			#loopy
			echo "$line_number: $next"

			#regex trigger 1 <title>

			#regex trigger 2 line 146 'class="container"'

			#regex trigger 3 'class="footer"'
		done
		#echo "$output_file" > $target_file
		#target_file_size_injected=`ls -lah "$target_file" | awk '{ print $5}'`
		#target_file_lines_injected=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		#if [ $flag_verbose == true ]; then
		#	target_file_lines_diff=`expr $target_file_lines_injected - $target_file_lines`
		#	echo "     Lines Added: $target_file_lines_diff"
		#	echo "   Target File After: $target_file_size_injected and $target_file_lines_injected lines"
		#fi
		#if [ $incs_found -gt 0 ]; then
		#	echo "---> Includes Found: $incs_found"
		#else
		#	echo "---> WARNING: No Includes processed in this file"
		#fi
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}

#Parse command line arguments
while [[ $# > 1 ]]
do
key="$1"
case $key in
	-d|--target-directory)
	target_directory="$2"
	target_directory_length=${#target_directory}
	shift
	;;
	-f|--target-file)
	target_file="$2"
	target_file_length=${#target_file}
	shift
	;;
	-e|--header-pre-path)
	header_pre_path="$2"
	header_pre_path_length=${#header_pre_path}
	shift
	;;
	-o|--header-post-path)
	header_post_path="$2"
	header_post_path_length=${#header_post_path}
	shift
	;;
	-t|--footer-path)
	footer_path="$2"
	footer_path_length=${#footer_path}
	shift
	;;
	-v|--verbose)
	flag_verbose=true
	shift
	;;
	-r|--recursive)
	flag_recursive=true
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


if [[ $target_directory_length == 0 && $target_file_length == 0 ]]; then
	echo "Must choose at least one file to procede"
else
	if [[ $target_directory_length -gt 0 && $target_file_length -gt 0 ]]; then
		echo "Must chose either one file or a directory (optional recursive). Cannot do both, in same command."
	else
		if [[ $target_directory_length -gt 0 ]]; then
			echo "Target Directory: $target_directory"
		fi

		if [[ $target_file_length -gt 0 ]]; then
			if [[ $header_pre_path_length -gt 0 && $header_post_path_length -gt 0 && $footer_path_length -gt 0 ]]; then
				echo "Target File: $target_file"
				inject_res=$( retrofit_file $flag_verbose $target_file $header_pre_path $header_post_path $footer_path )
				echo "res: $inject_res"
			else
				echo "Must have a pre/post header and footer paths defined"
				echo "Header Pre Path[$header_pre_path_length]: $header_pre_path"
				echo "Header Post Path[$header_post_path_length]: $header_post_path"
				echo "Footer path[$footer_path_length]: $footer_path"
			fi
		fi
	fi
fi




exit;
#target_found=false
#output_file=""
#incs_found=0
#
#
#
#if [[ $flag_inject == true || $flag_strip == true ]]; then
#fi
#
#		if [[ $next =~ $regex_match_include ]]; then
#			target_found=true
#
#			target_include_file=`echo "$next" | sed "s/$regex_match_include_to_filename//" | sed "s/$regex_match_first_space_to_end//"`
#			#echo "$next"
#
#			target_include_file="$include_path/$target_include_file.html"
#			if [ -f $target_include_file ]; then
#				echo "     Include File: $target_include_file(added)"	
#				incs_found=$((incs_found+1))
#				output_file="$output_file$IFS`cat $target_include_file`"
#			else 
#				echo " ** Include File does NOT Exist: '$target_include_file' ** "
#				return 1
#			fi
#		else
#			output_file="$output_file$IFS$next"
#		fi
#	done
#	#echo "$output_file" > $target_file
#	target_file_size_injected=`ls -lah "$target_file" | awk '{ print $5}'`
#	target_file_lines_injected=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
#	if [ $flag_verbose == true ]; then
#		target_file_lines_diff=`expr $target_file_lines_injected - $target_file_lines`
#		echo "     Lines Added: $target_file_lines_diff"
#		echo "   Target File After: $target_file_size_injected and $target_file_lines_injected lines"
#	fi
#	if [ $incs_found -gt 0 ]; then
#		echo "---> Includes Found: $incs_found"
#	else
#		echo "---> WARNING: No Includes processed in this file"
#	fi
#else
#	echo "$IFS ***************   FATAL ERROR!!   ***************"
#	echo "The target file you specified doesn't appear to be a file..."
#	echo "target file: $target_file"
#	exit 1
#fi
