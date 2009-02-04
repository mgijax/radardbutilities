#!/bin/csh -f -x

#
# Program:
#
#	logPreMirroredFilesByFile.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logPreMirroredFilesByFile.py
#	which logs mirrored files that are pre-processed to RADAR
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Work File File
#	Output File Directory
#	Log File Type		(ex. GenBank_preprocess)
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logPreMirroredFilesByFile.csh RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType
#
# Modification History
#
# 02/04/2009 lec
#	- TR9451/Gene Traps
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
    setenv LOGWORKFILE $2
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
# LOGWORKFILE, LOGOUTPUTDIR, LOGFILETYPE env variables
./logPreMirroredFilesByFile.py

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging pre-processed mirrored files.'
	exit 1
else
	echo 'Logging pre-processed mirrored files was successful.'
	exit 0
endif
 
