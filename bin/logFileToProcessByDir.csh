#!/bin/csh -f -x

#
# Program:
#
#	logFilesToProcessByDir.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logFileToProcess.py
#	which logs files to processed to RADAR
#	by directory name
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Work File Directory
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
#	logFilesToProcessByDir.csh RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType
#
# Modification History
#
# 02/10/2009 lec
#	- TR9451, TR9050
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

#
# for each file in the work directory....
#
foreach file (${LOGWORKDIR})
    setenv LOGWORKFILE $file
    echo ./logFilesToProcess.py
end

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging files to process.'
	exit 1
else
	echo 'Logging files to process was successful.'
	exit 0
endif
 
