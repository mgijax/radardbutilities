#!/bin/csh -f
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
#	File Types		(ex. GenBank, if multiple file types, "GenBank RefSeq")
#	Max File Size		in bytes, the maximum file size of files to process
#			        this parameter is optional
#				(ex. 1000000)
#
# Outputs:
#
#	List of file names to process; blank list if no files to process
#
# Usage:
#
#	getFilesToProcess.csh RDRDBSchemaPath JobStreamName "FileType1 FileType2" [MaxFileSize]
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
if  ( ${#argv} < 3 ) then
    echo "Usage: $0  RDRDBSchemaPath JobStreamName FileTypes [MaxFileSize]"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv JOBSTREAMNAME $2
    setenv FILETYPES "$3"
    setenv MAXFILESIZE $4
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

#
# if no maxfilesize is given, default to 0
#
if ( ${MAXFILESIZE} == "" ) then
	setenv MAXFILESIZE 0
endif

#
# source the Configuration file
#
source ../Configuration

#
# retrieve files to process based on Job Stream and File Types
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE, 
# JOBSTREAMNAME, FILETYPES, MAXFILESIZE env variables
#
set filesToProcess=`${PYTHON} ./getFilesToProcess.py`
echo $filesToProcess

#
# if status != 0, then exit with return code 1
#
if ( $status != 0 ) then
	exit 1
else
	exit 0
endif
