#!/bin/csh -f -x
#
# Program:
#
#	getFilesToProcess.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for getFilesToProcess.py
#	which retrieves mirrored files for processing
#
# Inputs:
#
#	RADAR DB Schema Path	(ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Job Stream Name 	(ex. genbank_load)
#	File Types		(ex. GenBank)
#
# Outputs:
#
#	List of file names to process; blank list if no files to process
#
# Usage:
#
#	getFilesToProcess.csh RDRDBSchemaPath JobStreamName "FileType1 FileType2"...
#
# Modification History
#
# 04/29/2004 lec
#	- JSAM; created
#

#
#  Verify the argument(s) to the shell script.
#

if  ( ${#argv} < 3 ) then
    echo "Usage: $0  RDRDBSchemaPath JobStreamName FileType1
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv JOBSTREAMNAME $2
    setenv FILETYPES "$3"
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RDR DB Schema Configuration file

source ${RDRDBSCHEMAPATH}/Configuration

# retrieve files to process based on Job Stream and File Types
# uses DBSERVER, DBNAME, DBUSER, DBPASSWORDFILE, JOBSTREAMNAME, FILETYPES env variables
cd `dirname $0`
set filesToProcess=`./getFilesToProcess.py`
echo $filesToProcess

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	exit 1
else
	exit 0
endif
 
