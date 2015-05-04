#!/bin/bash
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

		if [[ $target_file_source =~ $regex_match_include ]]; then
			echo "   Inc Flag Found. Retrofitting..."
		else
			echo "   Inc Flag Not Found... Skipping"
			exit 1
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

		if [[ $target_file_source =~ $regex_match_inc_start ]]; then
			echo "   sourceStart Flag Found. Retrofitting..."
		else
			echo "   sourceStart Flag Not Found... Skipping"
			exit 1
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



function retrofit_file
{
	flag_verbose=$1
	target_file=$2
	header_pre_path=$3
	header_post_path=$4
	footer_path=$5
	main_content=""
	content_toggle=false


	#Check that all template files exist
	all_found=true
	if [ -f $header_pre_path ]; then
		#echo "Header(1) exits..."
		header_pre_contents=`cat $header_pre_path`
	else
		echo "Header(1) not found..."
		all_found=false
	fi

	if [ -f $header_post_path ]; then
		#echo "Header(2) exits..."
		header_post_contents=`cat $header_post_path`
	else
		echo "Header(2) not found..."
		all_found=false
	fi

	if [ -f $footer_path ]; then
		#echo "Footer exits..."
		footer_contents=`cat $footer_path`
	else
		echo "Footer not found..."
		all_found=false
	fi

	if [ $all_found = true ]; then
		#echo "Template Files exist! Procede..."
		new_file_contents="$header_pre_contents"
	else 
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "Missing themplate file!"
		exit 1
	fi

	if [ -f $target_file ]; then
		target_file_source=`cat $target_file`
		target_file_size=`ls -lah "$target_file" | awk '{ print $5}'` 
		target_file_lines=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		if [ $flag_verbose == true ]; then
			echo "$IFS   Target File Before: $target_file_size and $target_file_lines lines"
		fi
	
		if [[ $target_file_source =~ $regex_match_dwt_file ]]; then
			echo "   Dreamweaver Template Found. Retrofitting..."
		else
			echo "   Dreamweaver Template Not Found... Skipping"
			exit 1
		fi

		for next in `cat $target_file`
		do	
			line_number=$((line_number+1))
			#loopy
			#echo "$line_number: $next"

			#regex trigger 1 <title>
			if [[ $next =~ $regex_html_title_pre && $line_number -lt $title_before ]]; then
				title=`echo "$next" | sed "s/$regex_html_title_pre//" | sed "s/$regex_html_title_post//"`
				#echo "Title Found: $title"
				new_file_contents="$new_file_contents$IFS$TAB<title>$title</title>$IFS$header_post_contents"
			fi

			#regex trigger 2 line 146 'class="container"'
			if [[ $next =~ $regex_html_container && $line_number -lt $container_location_before ]]; then
				content_toggle=true
			fi

			#regex trigger 3 'class="footer"' or 'class="span-6 last right-col"'
			if [[ $next =~ $regex_html_footer || $next =~ $regex_html_right_col ]]; then
				content_toggle=false
				new_file_contents="$new_file_contents$IFS$footer_contents"
				break 
			fi

			if [ $content_toggle == true ]; then
				new_file_contents="$new_file_contents$IFS$next"
			fi


		done

		#echo "$IFS$IFS **************** FILE RETROFIT: ****************$IFS$new_file_contents"
		echo "$new_file_contents" > $target_file
		target_file_size_new=`ls -lah "$target_file" | awk '{ print $5}'`
		target_file_lines_new=`wc -l "$target_file" | sed "s/$regex_match_leading_spaces//" | sed "s/$regex_match_first_space_to_end//"`
		if [ $flag_verbose == true ]; then
			target_file_lines_diff=`expr $target_file_lines_new - $target_file_lines`
			echo "     Number of Lines Difference: $target_file_lines_diff"
			echo "   Target File After: $target_file_size_new and $target_file_lines_new lines"
		fi
	else
		echo "$IFS ***************   FATAL ERROR!!   ***************"
		echo "The target file you specified doesn't appear to be a file..."
		echo "target file: $target_file"
		exit 1
	fi
}



function retrofit_directory
{
	flag_verbose=$1
	target_directory=$2
	header_pre_path=$3
	header_post_path=$4
	footer_path=$5
	recursive=$6
	main_content=""
	content_toggle=false

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
				retrofit_res=$( retrofit_file $flag_verbose $target_file $header_pre_path $header_post_path $footer_path )
				echo "res: $retrofit_res"
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
