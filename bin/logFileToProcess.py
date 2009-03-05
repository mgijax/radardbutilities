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

localtime = time.localtime(os.stat(workFile)[8])
fileTimeStamp = '%s/%s/%s %s:%s' \
    % (localtime[1], localtime[2], localtime[0], localtime[3], localtime[4])

# set file size/1000
fileSize = os.stat(workFile)[6] / 1000
if fileSize == 0:
    fileSize = 1

bName = os.path.basename(workFile)
filePath = os.path.join(outputDir, bName)

# log the file to RADAR
db.sql('exec APP_logMirroredFile "%s", "%s", %s, "%s", "%s"' 
    % (fileType, filePath, fileSize, fileTimeStamp, unixLogin), None)

# only print out the files that were logged on the current date

results = db.sql('select fileName, fileSize from APP_FilesMirrored ' + \
	'where fileType = "%s" ' % (fileType) + \
	'and convert(char(10), creation_date, 101) = "%s" ' % (cdate) + \
	'order by _File_key', 'auto')
for r in results:
    print r['fileName'], `r['fileSize']`

sys.exit(0)

