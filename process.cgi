#!/bin/bash

# Forget this header declaration at your peril!
#echo -e "Content-type: text/html\n\n";

if [ "$REQUEST_METHOD" != "GET" ]; then
        echo "<hr>Script Error:"\
             "<br>Usage error, cannot complete request, REQUEST_METHOD!=GET."\
             "<br>Check your FORM declaration and be sure to use METHOD=\"GET\".<hr>"
        exit 1
fi

# If no search arguments, exit gracefully now.

if [ -z "$QUERY_STRING" ]; then
    exit 0
else
    # No need to loop, just extract the values wanted from the query string; then compress any spaces
    ACTION=`echo "$QUERY_STRING" | sed -n 's/^.*action=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
    TARGET=`echo "$QUERY_STRING" | sed -n 's/^.*target=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

    INJECT_FLAG=""

    if [ "$ACTION" != 'stripinject' ]; then
	if [ "$ACTION" != 'strip' ]; then
             INJECT_FLAG="--inject true"
	else 
	     INJECT_FLAG="--strip true"
	fi
    else 
             INJECT_FLAG="--inject true --strip true"
    fi
    
    CMD_SCRIPT="./html-injector.sh --recursive true --verbose true --target-directory ../../www.blackhat.com/$TARGET $INJECT_FLAG"

source "display-header.sh"
echo "<title>Black Hat Includes | Exec-15 Injector</title>"
source "display-header-post.sh"
echo "<br />Start: "
echo `date`
echo "<br />Results:<br /><pre class=\"output_box\">" 
    echo "CMD_SCRIPT: " $CMD_SCRIPT 
    echo "`$CMD_SCRIPT`"
echo "</pre>"
echo "<br />Ended: "
echo `date`
source "display-footer.sh"
fi
