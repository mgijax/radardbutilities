#!/bin/csh -f -x
#
# Program:
#
# Create a new Job Stream record in RADAR
#
# Inputs:
#
#	path to RADAR DBSchema installation
#	job stream name
#
# Outputs:
#
#	job stream key if successful, -1 if unsuccessful
#	status code; 0 if successful, 1 if unsuccessful
#
# Usage:
#
#   startJobStream.csh RADARDBSchemaPath JobStreamName
#
# History
#
# 03/28/2006 lec
#	- TR 6340; added check of startJobStream.py status
#

setenv DBSCHEMAPATH $1
setenv JOBSTREAMNAME "$2"

if ( ! -e ${DBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${DBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RADAR DB Schema Configuration file

source ${DBSCHEMAPATH}/Configuration

# create the job stream and echo the job stream key
# uses DBSERVER, DBNAME, DBUSER, DBPASSWORDFILE and JOBSTREAMNAME env variables

cd `dirname $0`
set jobStreamKey=`./startJobStream.py`

if ( $status ) then
	exit 1
endif

echo $jobStreamKey

# if job stream key is -1, then exit with return code 1

if ( $jobStreamKey == -1 ) then
	exit 1
else
	exit 0
endif
 
