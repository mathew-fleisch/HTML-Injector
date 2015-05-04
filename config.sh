#!/bin/bash
inc_flag="BLACKHATINCLUDE"
inc_filename="inc_"
#Regex's
regex_match_include="^.*BLACKHATINCLUDE.*inc_.*$"
regex_match_include_to_filename="^.*inc_"
regex_match_leading_spaces="^\ *"
regex_match_first_space_to_end="\ .*$"
regex_match_inc_start="^.*sourceStart.*$"
regex_match_inc_start_to_filename="^.*sourceStart_"
regex_match_inc_end="^.*sourceEnd.*$"
regex_match_inc_end_to_filename="^.*sourceEnd_"
regex_html_title_pre="^.*<title>"
regex_html_title_post="<\/title>.*$"
regex_html_container="^.*class=\"container\".*$"
regex_html_right_col="^.*class=\"span-6\ last\ right-col.*$"
regex_html_footer="^.*class=\"footer.*$"
#paths
include_path="../../www.blackhat.com/includes"
