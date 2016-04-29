#!/usr/local/bin/python

#
# Program:
#
#    getFilesToProcess2.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    Retrieve Files which require processing
#
# Requirements Satisfied by This Program:
#
# Usage:
#	getFilesToProcess2.py
#
# Envvars:
#
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
#    JOBSTREAMNAME1
#    JOBSTREAMNAME2
#    FILETYPE1
#    FILETYPE2
#    MAXFILESIZE
#
# Inputs:
#
#    None
#
# Outputs:
#
#    List of files to process; blank list if no files
#
# Exit Codes:
#
#    None
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
# 01/29/2009    lec
#         - TR9451, Gene Traps
#

import sys
import os
import string
import db

db.setAutoTranslate(False)
db.setAutoTranslateBE(False)

#
# Main
#

server = os.environ['RADAR_DBSERVER']
database = os.environ['RADAR_DBNAME']
user = os.environ['RADAR_DBUSER']
passwordFileName = os.environ['RADAR_DBPASSWORDFILE']
password = string.strip(open(passwordFileName, 'r').readline())
jobStreamName1 = os.environ['JOBSTREAMNAME1']
jobStreamName2 = os.environ['JOBSTREAMNAME2']
fileType1 = os.environ['FILETYPE1']
fileType2 = os.environ['FILETYPE2']
maxFileSize = os.environ['MAXFILESIZE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Retrieve the files
filesToProcess = []
results = db.sql("select * from APP_getFilesToProcess_2( '%s', '%s', '%s', '%s', %s)"  \
	% (jobStreamName1, jobStreamName2, fileType1, fileType2, maxFileSize), 'auto')
for r in results:
	filesToProcess.append(r['fileName'])

# print to stdout so wrapper can grab it
print string.join(filesToProcess, ' ')

