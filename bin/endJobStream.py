#!/usr/local/bin/python

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
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
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
password = string.strip(open(passwordFileName, 'r').readline())
jobStreamKey = os.environ['JOBSTREAMKEY']
jobStreamRC = os.environ['JOBSTREAMRETURNCODE']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
db.useOneConnection(1)
 
# End the Job Stream 
results = db.sql("select * from APP_endJobStream (%s, %s)" % ((jobStreamKey, jobStreamRC)), 'auto')
status = int(results[0]['app_endjobstream'])
db.commit()
db.useOneConnection(0)
sys.exit(status)

