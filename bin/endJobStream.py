#!/usr/local/bin/python

# $Header$
# $Name$

#
# Program:
#
#    endJobStream.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    End a Job Stream record in RADAR
#
# Requirements Satisfied by This Program:
#
# Usage:
#	endJobStream.py
#
# Envvars:
#
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
#    JOBSTREAMKEY
#    JOBSTREAMRETURNCODE
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
#    0 if Job Stream is successfully ended, else 1
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
jobStreamKey = os.environ['JOBSTREAMKEY']
jobStreamRC = os.environ['JOBSTREAMRETURNCODE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# End the Job Stream 
cmds = []
cmds.append('declare @status int')
cmds.append('exec @status = APP_endJobStream %s, %s'  % (jobStreamKey, jobStreamRC))
cmds.append('select @status')
results = db.sql(cmds, 'auto')
status = int(results[0][0][''])
sys.exit(status)

# $Log$
# Revision 1.1  2004/04/07 19:00:02  lec
# JSAM; moved over from mgidbutilities
#
# Revision 1.1  2003/08/08 15:17:34  lec
# JSAM
#
#
