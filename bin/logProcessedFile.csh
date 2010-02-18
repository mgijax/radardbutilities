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
#	File Type
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logProcessedFile.csh RDRDBSchemaPath JobStreamKey FileName FileType
#
# Modification History
#
# 04/29/2004 lec
#	- JSAM; created
#
# 12/06/2004 dbm
#	- Added FileType
#
cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#
if  ( ${#argv} != 4 ) then
    echo "Usage: $0  RDRDBSchemaPath JobStreamKey FileName FileType"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv JOBSTREAMKEY $2
    setenv FILENAME $3
    setenv FILETYPE $4
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

#
# source the Configuration file
#
source ../Configuration

#
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE,
# JOBSTREAMKEY, FILENAME and FILETYPE env variables
#
./logProcessedFile.py

#
# if status != 0, then exit with return code 1
#
if ( $status != 0 ) then
	echo 'Error logging processed file: ' ${FILENAME}
	exit 1
else
	echo 'Logging processed file was successful:  ' ${FILENAME}
	exit 0
endif
