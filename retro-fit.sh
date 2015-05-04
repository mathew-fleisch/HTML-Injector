#!/bin/bash

source "config.sh"
#globals
IFS=$'\n'
TAB=$'\t'
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


title_before=10
container_location_before=210

source "functions.sh"

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
	echo ""
	echo "-e --header-pre-path   <------->   This parameter will set a specific file to override"
	echo "                                   the header (up to <title> tag) to the target file/"
	echo "                                   directory."
	echo ""
	echo "-o --header-post-path   <------>   This parameter will set a specific file to override"
	echo "                                   the html from just after <title> tag to first "
	echo "                                   occurrence of the css class=\"container\""
	echo "                                   "
	echo ""
	echo "-t --footer-path   <----------->   This parameter will set a specific file to override"
	echo "                                   the html from the css class=\"footer\" to the EOF"
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
else
	if [[ $target_directory_length -gt 0 && $target_file_length -gt 0 ]]; then
		echo "Must chose either one file or a directory (optional recursive). Cannot do both, in same command."
	else
		if [[ $target_directory_length -gt 0 ]]; then
			if [[ $header_pre_path_length -gt 0 && $header_post_path_length -gt 0 && $footer_path_length -gt 0 ]]; then
				echo "Target Directory: $target_directory"
				retrofit_res=$( retrofit_directory $flag_verbose $target_directory $header_pre_path $header_post_path $footer_path $flag_recursive )
				echo "res: $retrofit_res"
			else
				echo "Must have a pre/post header and footer paths defined"
				echo "Header Pre Path[$header_pre_path_length]: $header_pre_path"
				echo "Header Post Path[$header_post_path_length]: $header_post_path"
				echo "Footer path[$footer_path_length]: $footer_path"
			fi
		fi

		if [[ $target_file_length -gt 0 ]]; then
			if [[ $header_pre_path_length -gt 0 && $header_post_path_length -gt 0 && $footer_path_length -gt 0 ]]; then
				echo "Target File: $target_file"
				retrofit_res=$( retrofit_file $flag_verbose $target_file $header_pre_path $header_post_path $footer_path )
				echo "res: $retrofit_res"
			else
				echo "Must have a pre/post header and footer paths defined"
				echo "Header Pre Path[$header_pre_path_length]: $header_pre_path"
				echo "Header Post Path[$header_post_path_length]: $header_post_path"
				echo "Footer path[$footer_path_length]: $footer_path"
			fi
		fi
	fi
fi

