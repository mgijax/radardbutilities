#!/usr/local/bin/python

# $Header$

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
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
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

#
# Main
#

server = os.environ['DBSERVER']
database = os.environ['DBNAME']
user = os.environ['DBUSER']
passwordFileName = os.environ['DBPASSWORDFILE']
password = string.strip(open(passwordFileName, 'r').readline())
jobStreamKey = os.environ['JOBSTREAMKEY']
fileName = os.environ['FILENAME']
fileType = os.environ['FILETYPE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Log the processed file
db.sql('exec APP_logProcessedFile %s, "%s", "%s"' % (jobStreamKey,
       fileName, fileType), None)

# $Log$
# Revision 1.2  2004/04/29 18:47:43  lec
# JSAM
#
# Revision 1.1  2004/04/29 18:34:38  lec
# JSAM
#
#
