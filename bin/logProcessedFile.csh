#!/bin/csh -f -x
#
# Program:
#
#	logProcessedFile.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logProcessedFile.py
#	which logs processed files to RADAR
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Job Stream Key
#	File Name
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logProcessedFile.csh RDRDBSchemaPath JobStreamKey FileName
#
# Modification History
#
# 04/29/2004 lec
#	- JSAM; created
#

cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#

if  ( ${#argv} != 3 ) then
    echo "Usage: $0  RDRDBSchemaPath JobStreamKey FileName"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv JOBSTREAMKEY $2
    setenv FILENAME $3
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RDR DB Schema Configuration file

source ${RDRDBSCHEMAPATH}/Configuration

# uses DBSERVER, DBNAME, DBUSER, DBPASSWORDFILE, JOBSTREAMKEY, FILENAME env variables
./logProcessedFile.py

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging processed file: ' ${FILENAME}
	exit 1
else
	echo 'Logging processed file was successful:  ' ${FILENAME}
	exit 0
endif
 
