#!/bin/csh -fx

#
# Program:
#
# Create a new Job Stream record in RADAR
#
# Inputs:
#
#	job stream name
#
# Outputs:
#
#	job stream key if successful, -1 if unsuccessful
#	status code; 0 if successful, 1 if unsuccessful
#
# Usage:
#
#   startJobStream.csh JobStreamName
#
# History
#
# 03/28/2006 lec
#	- TR 6340; added check of startJobStream.py status
#
cd `dirname $0`

setenv JOBSTREAMNAME "$1"

#
# source the Configuration file
#
source ../Configuration

#
# create the job stream and echo the job stream key
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE
# and JOBSTREAMNAME env variables
#
set jobStreamKey=`./startJobStream.py`

if ( $status ) then
	exit 1
endif

echo $jobStreamKey

#
# if job stream key is -1, then exit with return code 1
#
if ( $jobStreamKey == -1 ) then
	exit 1
else
	exit 0
endif
