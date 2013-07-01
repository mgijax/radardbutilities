#!/bin/csh -fx
#
# Program:
#
#	getFilesToProcess2.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for getFilesToProcess2.py
#	which retrieves mirrored files for processing
#
# Inputs:
#
#	RADAR DB Schema Path	(ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Job Stream Name 1	(ex. genbank_load)
#	Job Stream Name 2	(ex. gbgtfilter)
#	File Types 1		(ex. GenBank)
#	File Types 2		(ex. GenBank_GTfilter)
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
#	getFilesToProcess2.csh RDRDBSchemaPath JobStreamName FileType1 FileType2 [MaxFileSize]
#
# Modification History
#
# 01/29/2009 lec
#	- TR9451, Gene Traps
#
cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#
if  ( ${#argv} < 4 ) then
    echo "Usage: $0  RDRDBSchemaPath JobStreamName FileType1 FileType2 [MaxFileSize]"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv JOBSTREAMNAME1 $2
    setenv JOBSTREAMNAME2 $3
    setenv FILETYPE1 $4
    setenv FILETYPE2 $5
    setenv MAXFILESIZE $6
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
# JOBSTREAMNAME1, JOBSTREAMNAME2, FILETYPE1, FILETYPE2, MAXFILESIZE
# env variables
#
set filesToProcess=`./getFilesToProcess2.py`
echo $filesToProcess

#
# if status != 0, then exit with return code 1
#
if ( $status != 0 ) then
	exit 1
else
	exit 0
endif
