#!/bin/csh -f -x
#
# Program:
#
# End a Job Stream
#
# Inputs:
#
#	path to RADAR DBSchema installation
#	job stream key
#	job stream return code
#
# Outputs:
#
#	status code; 0 if successful, 1 if unsuccessful
#
# Usage:
#
#   endJobStream.csh RADARDBSchemaPath JobStreamKey JobStreamReturnCode
#

setenv DBSCHEMAPATH $1
setenv JOBSTREAMKEY $2
setenv JOBSTREAMRETURNCODE $3

if ( ! -e ${DBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${DBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RADAR DB Schema Configuration file
source ${DBSCHEMAPATH}/Configuration

# end the job stream
cd `dirname $0` 
./endJobStream.py
exit $status

