#!/bin/csh -f -x

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
#	logFileToProcessByDir.csh RDRDBSchemaPath WorkFileDir OutputFileDir LogFileType
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

#
# source the Configuration file
#
source ../Configuration

#
# for each file in the work directory....
#	log the file
#	check whether the logging was successful (or not)
#
foreach file (${LOGWORKDIR}/*)

   # check if this is an actual "file"
   # if so, log the file

   if ( -f $file) then
      echo $file
      setenv LOGWORKFILE $file
      ./logFileToProcess.py

      # if status != 0, then exit with return code 1

      if ( $status != 0 ) then
	echo 'Error logging files to process.'
	exit 1
      else
	echo 'Logging files to process was successful.'
	exit 0
      endif
   else
	echo 'No work files exist to process.'
	exit 0
   endif
end
