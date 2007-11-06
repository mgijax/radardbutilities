#!/bin/csh -f -x

#
# Program:
#
#	logFileToProcess.csh
#
# Original Author:
#
#	sc
#
# Purpose:
#
#	Wrapper for logFileToProcess.py
#	which logs a file to RADAR
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Full path to file to be logged
#	Log File Type		(ex. GenBank)
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logFileToProcess.csh RDRDBSchemaPath file LogFileType
#
# Modification History
#
# 11/05/2007 sc
#	- created
#

cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#

if  ( ${#argv} != 3 ) then
    echo "Usage: $0  RDRDBSchemaPath fileToLog LogFileType"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv FILETOLOG $2
    setenv LOGFILETYPE $3
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RDR DB Schema Configuration file

source ${RDRDBSCHEMAPATH}/Configuration

# log the file in radar..APP_FilesMirrored
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE, 
# FILETOLOG, LOGFILETYPE env variables
./logFileToProcess.py

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging mirrored files.'
	exit 1
else
	echo 'Logging mirrored files was successful.'
	exit 0
endif
 
