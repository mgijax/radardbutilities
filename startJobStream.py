#!/usr/local/bin/python

# $Header$
# $Name$

#
# Program:
#
#    startJobStream.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    Create a Job Stream record in RADAR and return a Job Stream Key
#
# Requirements Satisfied by This Program:
#
# Usage:
#	startJobStream.py
#
# Envvars:
#
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
#    JOBSTREAMNAME
#    USER
#
# Inputs:
#
#    None
#
# Outputs:
#
#    Job Stream Key, -1 if Job Stream cannot be created
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
unixLogin = os.environ['USER']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Create the Job Stream 
results = db.sql('exec APP_createJobStream "%s", "%s"'  % (jobStreamName, unixLogin), 'auto')
jobStreamKey = int(results[0][''])

# print to stdout so wrapper can grab it
print jobStreamKey	

# $Log$
# Revision 1.3  2003/10/27 13:21:33  lec
# JSAM
#
# Revision 1.2  2003/08/08 12:17:03  lec
# JSAM
#
# Revision 1.1  2003/08/07 15:45:25  lec
# JSAM
#
