#
# Program:
#
#    getFilesToProcess.py
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
#	getFilesToProcess.py
#
# Envvars:
#
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
#    JOBSTREAMNAME
#    FILETYPES
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
# 04/20/2006    lec
#       - MGI 3.5; DBSERVER => RADAR_DBSERVER, DBNAME => RADAR_DBNAME,
#         DBUSER => RADAR_DBUSER, DBPASSWORDFILE => RADAR_DBPASSWORDFILE
#

import sys
import os
import string
import db

#
# Main
#

server = os.environ['RADAR_DBSERVER']
database = os.environ['RADAR_DBNAME']
user = os.environ['RADAR_DBUSER']
passwordFileName = os.environ['RADAR_DBPASSWORDFILE']
password = str.strip(open(passwordFileName, 'r').readline())
jobStreamName = os.environ['JOBSTREAMNAME']
fileTypes = os.environ['FILETYPES']
maxFileSize = os.environ['MAXFILESIZE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Retrieve the files
filesToProcess = []
for f in str.split(fileTypes, ' '):
    results = db.sql("select * from APP_getFilesToProcess( '%s', '%s', %s)"  % (jobStreamName, f, maxFileSize), 'auto')
    for r in results:
        filesToProcess.append(r['filename'])

# print to stdout so wrapper can grab it
print(str.join(filesToProcess, ' '))
