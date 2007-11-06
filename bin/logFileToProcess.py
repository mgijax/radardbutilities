#!/usr/local/bin/python

#
# Program:
#
#    logFileToProcess.py
#
# Original Author:
#
#    sc
#
# Purpose:
#
#    Log a file into APP_FilesMirrored table in RADAR
#
# Requirements Satisfied by This Program:
#
# Usage:
#	logFileToProcess.py
#
# Envvars:
#
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
#    FILETOLOG
#    LOGFILETYPE
#    USER (unix login)
#
# Inputs:
#
#    None
#
# Outputs:
#
#    None
#
# Exit Codes:
#
#    0 if files were successfully logged
#    1 if file logging failed
#
#
# Assumes:
#
#    Envvars are set
#
# Bugs:
#
# Implementation:
#
# Modification History:
#
# 11/05/2007 
#	-  created
#

import sys
import os
import string
import time
import db
import mgi_utils

# current date
cdate = mgi_utils.date('%m/%d/%Y')

#
# Main
#

# get database settings from the environment
server = os.environ['RADAR_DBSERVER']
database = os.environ['RADAR_DBNAME']
user = os.environ['RADAR_DBUSER']
passwordFileName = os.environ['RADAR_DBPASSWORDFILE']
password = string.strip(open(passwordFileName, 'r').readline())

# get the unix login of user running this process
unixLogin = os.environ['USER']

# get the file we are logging
fileToLog = os.environ['FILETOLOG']

# get the file type we are logging
fileType = os.environ['LOGFILETYPE']

# if we don't have a valid file, exit(1)
if not os.path.isfile(fileToLog):
    sys.exit('%s is not a valid file' % fileToLog)

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)

# create a timestamp to log
localtime = time.localtime(os.stat(fileToLog)[8])
fileTimeStamp = '%s/%s/%s %s:%s' \
    % (localtime[1], localtime[2], localtime[0], localtime[3], localtime[4])

# get the file size to log
fileSize = os.stat(fileToLog)[6]

# log the file to RADAR
db.sql('exec APP_logMirroredFile "%s", "%s", %s, "%s", "%s"' 
    % (fileType, fileToLog, fileSize, fileTimeStamp, unixLogin), None)

sys.exit(0)

