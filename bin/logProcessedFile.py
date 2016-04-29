#!/usr/local/bin/python

#
# Program:
#
#    logProcessedFile.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    Log processed files into APP_FilesProcessed table in RADAR
#
# Requirements Satisfied by This Program:
#
# Usage:
#	logProcessedFile.py
#
# Envvars:
#
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
#    JOBSTREAMKEY
#    FILENAME
#    FILETYPE
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
# 04/20/2006    lec
#       - MGI 3.5; DBSERVER => RADAR_DBSERVER, DBNAME => RADAR_DBNAME,
#         DBUSER => RADAR_DBUSER, DBPASSWORDFILE => RADAR_DBPASSWORDFILE
#
# 04/29/2004 lec
#	- JSAM; created
#
# 12/06/2004 lec
#	- Added FILETYPE
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
jobStreamKey = os.environ['JOBSTREAMKEY']
fileName = os.environ['FILENAME']
fileType = os.environ['FILETYPE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
db.useOneConnection(1)
 
# Log the processed file
db.sql("select * from APP_logProcessedFile( %s, '%s', '%s')" % (jobStreamKey, fileName, fileType), None)
db.commit()
db.useOneConnection(0)
