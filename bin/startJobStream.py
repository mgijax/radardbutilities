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
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
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
# Modification History:
#
# 04/20/2006    lec
#       - MGI 3.5; DBSERVER => RADAR_DBSERVER, DBNAME => RADAR_DBNAME,
#         DBUSER => RADAR_DBUSER, DBPASSWORDFILE => RADAR_DBPASSWORDFILE
#
#

import sys
import os
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
unixLogin = os.environ['USER']

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
db.useOneConnection(1)
 
# Create the Job Stream 
results = db.sql("select * from APP_createJobStream('%s', '%s')"  % (jobStreamName, unixLogin), 'auto')
jobStreamKey = int(results[0]['app_createjobstream'])
db.commit()
db.useOneConnection(0)

# print to stdout so wrapper can grab it
print(jobStreamKey)	
