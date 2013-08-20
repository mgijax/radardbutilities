#!/bin/csh -f

#
# Program:
#
#	logFileToProcessByDir.csh
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
#	logFileToProcessByDir.csh \
#	    RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType
#
# Modification History
#
# 05/24/2011 sc
#	- Fixed bug whereby only one file in directory ever processed
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

#
# source the Configuration file
#
source ../Configuration

#
# for each file in the work directory....
#	log the file
#	check whether the logging was successful (or not)
#
foreach file ( ${LOGWORKDIR}/* )

   # check if this is an actual "file"
   # if so, log the file
   if ( -f $file ) then
      setenv LOGWORKFILE $file
      ./logFileToProcess.py

      # if status != 0, then report
      if ( $status != 0 ) then
	echo "Error logging files to process: $file"
	exit 1
      endif
   endif
end
