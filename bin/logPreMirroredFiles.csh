#!/bin/csh -f -x

#
# Program:
#
#	logPreMirroredFiles.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logPreMirroredFiles.py
#	which logs mirrored files that are pre-processed to RADAR
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Work File Directory
#	Output File Directory
#	Log File Type		(ex. GenBank)
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logPreMirroredFiles.csh RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType
#
# Modification History
#
# 10/30/2008 lec
#	- TR9050
#

cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#

if  ( ${#argv} != 4 ) then
    echo "Usage: $0  RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv LOGWORKDIR $2
    setenv LOGOUTPUTDIR $3
    setenv LOGFILETYPE $4
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RDR DB Schema Configuration file

source ${RDRDBSCHEMAPATH}/Configuration

# traverse thru the files given
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE, 
# LOGFILEDIR, LOGFILETYPE env variables
./logPreMirroredFiles.py

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging pre-processed mirrored files.'
	exit 1
else
	echo 'Logging pre-processed mirrored files was successful.'
	exit 0
endif
 
