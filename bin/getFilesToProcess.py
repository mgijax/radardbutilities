#!/usr/local/bin/python

# $Header$

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
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
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
jobStreamName = os.environ['JOBSTREAMNAME']
fileTypes = os.environ['FILETYPES']
maxFileSize = os.environ['MAXFILESIZE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Retrieve the files
filesToProcess = []
for f in string.split(fileTypes, ' '):
    results = db.sql('exec APP_getFilesToProcess "%s", "%s", %s'  % (jobStreamName, f, maxFileSize), 'auto')
    for r in results:
	filesToProcess.append(r['fileName'])

# print to stdout so wrapper can grab it
print string.join(filesToProcess, ' ')

# $Log$
# Revision 1.1  2004/04/29 16:55:24  lec
# JSAM
#
#
