#!/bin/csh -f -x

#
# Program:
#
#	logFileToProcess.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logFileToProcess.py
#	which logs files to process into RADAR..APP_FilesMirrored
#
# Inputs:
#
#	RADAR DB Schema Path    (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Work File               
#	(ex. /data/loads/genbank/genbank_gbpreprocessor/work/GenBank.008.001.gz)
#	Output File Directory   
#       (ex. /data/downloads/ftp.ncbi.nih.gov/genbank_gbpreprocessor/output)
#	Log File Type		(ex. GenBank, i.e. this file is being logged
#				for use by gbseqload)
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logFileToProcess.csh RDRDBSchemaPath WorkFile OutputFileDir LogFileType
#
# Modification History
#
# 02/10/2009 lec
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

#
# source the Configuration file
#
source ../Configuration

#
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE, 
# LOGWORKFILE, LOGOUTPUTDIR, LOGFILETYPE env variables
#
./logFileToProcess.py

#
# if status != 0, then exit with return code 1
#
if ( $status != 0 ) then
	echo 'Error logging files to process.'
	exit 1
else
	echo 'Logging files to process was successful.'
	exit 0
endif
