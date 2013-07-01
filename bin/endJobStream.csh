#!/bin/csh -fx
#
# Program:
#
# End a Job Stream
#
# Inputs:
#
#	job stream key
#	job stream return code
#
# Outputs:
#
#	status code; 0 if successful, 1 if unsuccessful
#
# Usage:
#
#   endJobStream.csh JobStreamKey JobStreamReturnCode
#
cd `dirname $0` 

setenv JOBSTREAMKEY $1
setenv JOBSTREAMRETURNCODE $2

#
# source the Configuration file
#
source ../Configuration

#
# end the job stream
#
./endJobStream.py

exit $status
