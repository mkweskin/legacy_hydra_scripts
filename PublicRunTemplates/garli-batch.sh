#!/bin/sh

# Batch submission of Garli bootstraps
# Matthew Kweskin                
# 3Sep2015

# 1. Prepare your qsub and conf files
# 2. Edit the GARLICONF, QSUB and REPS varialbes
# 3. Run this script to submit the jobs

USAGE="
Usage: `basename $0` conf-file-name job-file-name reps

conf-file-name   name of your garli.conf
job-file-name    name of your job file with embedded qsub directives
reps             integer for the number of times to submit the garli job

The script will copy your job and conf file for each submission
and edit your conf file to modify  \"ofprefix\" for each rep.
"

if [[ "$#" != "3" ]]; then
	echo "$USAGE"
	exit 1
fi

GARLICONF=$1
QSUB=$2
REPS=$3

echo
echo "Confirm these settings:"
echo "  Garli conf file: \"$GARLICONF\""
echo "  Job file for qsub: \"$QSUB\""
echo "  Times to submit: $REPS"
echo
echo "IMPORANT: This script will submit your garli.conf $REPS times."
echo "If you are doing bootstraps, it's most efficient to set"
echo "\"bootstrapreps = 1\" in your .conf file."
echo

read -p "Enter \"y\" to continue. " answer
if [[ $answer != "y" && $answer != "Y" ]] ; then
	echo "Execution halted."
	exit 1
fi


#Test that the needed files are present
if [[ ! -f $GARLICONF ]]; then
	echo "ERROR: \"$GARLICONF:\" was not found. Please check that the filename is correct and retry."
	exit 1
fi

if [[ ! -f $QSUB ]]; then
	echo "ERROR: \"$QSUB:\" was not found. Please check that the filename is correct and retry."
	exit 1
fi

#Check that the garli.conf has an ofprefix line
grep --quiet ofprefix $GARLICONF
if [[ $? != 0 ]]; then
	echo "ERROR: \"$GARLICONF:\" is missing a \"ofprefix\" line. Please edit $GARLICONF and retry."
	exit 1
fi

#Check that the garli.conf has an ofprefix line
grep --quiet $GARLICONF $QSUB
if [[ $? != 0 ]]; then
	echo "ERROR: Your qsub file does not reference \"$GARLICONF\". Please edit it and retry."
	exit 1
fi


#Start for loop for each rep
for (( i = 1; i <= $REPS; i++ )); do
	echo "Starting rep $i"
	sed -e "s/\([[:space:]]*ofprefix[[:space:]]*=[[:space:]][^[:space:]]*\)/\1.run$i/" $GARLICONF > $GARLICONF.run$i
	sed -e "s/\(.*\)\($GARLICONF\)\(.*\)/\1\2.run$i\3/" $QSUB > $QSUB.run$i
	grep --quiet $GARLICONF.run$i $QSUB.run$i
	if [[ $? != 0 ]]; then
		echo "ERROR: Something is wrong with the qsub file for this run: \"$QSUB.run$i\". Expecting to find \"$GARLICONF.run$i\" in it"
		exit 1
	fi
	qsub $QSUB.run$i
done
