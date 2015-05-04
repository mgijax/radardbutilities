#!/usr/local/bin/python

#
# Program:
#
#    logFileToProcess.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    Log files to process into APP_FilesMirrored table in RADAR
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
#    LOGWORKFILE
#    LOGOUTPUTDIR
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
#    Note:  If there were no files to log, then 0 is returned
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
# 10/30/2008 lec
#	- TR9050
#

import sys
import os
import string
import time
import db
import mgi_utils

cdate = mgi_utils.date('%m/%d/%Y')

#
# Main
#

server = os.environ['RADAR_DBSERVER']
database = os.environ['RADAR_DBNAME']
user = os.environ['RADAR_DBUSER']
passwordFileName = os.environ['RADAR_DBPASSWORDFILE']
password = string.strip(open(passwordFileName, 'r').readline())
unixLogin = os.environ['USER']
workFile = os.environ['LOGWORKFILE']
outputDir = os.environ['LOGOUTPUTDIR']
fileType = os.environ['LOGFILETYPE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
db.useOneConnection(1)

localtime = time.localtime(os.stat(workFile)[8])
fileTimeStamp = '%s/%s/%s %s:%s' \
    % (localtime[1], localtime[2], localtime[0], localtime[3], localtime[4])

# get the file size
fileSize = os.stat(workFile)[6]

# skip if empty file
if fileSize == 0:
    # print the file that was logged
    print '%s %s %s %s' \
	% ('Skipping empty file: ', workFile, fileType, fileSize)
    sys.exit(0)

# set file size/1000
fileSize = fileSize / 1000
if fileSize == 0:
    fileSize = 1

bName = os.path.basename(workFile)
filePath = os.path.join(outputDir, bName)

# log the file to RADAR
db.sql('exec APP_logMirroredFile "%s", "%s", %s, "%s", "%s"' \
    % (fileType, filePath, fileSize, fileTimeStamp, unixLogin), None)
db.commit()

# print the file that was logged
print "%s %s %s" % (filePath, fileType, fileSize)

db.useOneConnection(0)

sys.exit(0)

