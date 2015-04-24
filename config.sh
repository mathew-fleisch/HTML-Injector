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
#paths
include_path="../../www.blackhat.com/includes"
