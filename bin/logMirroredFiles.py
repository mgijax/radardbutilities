#!/usr/local/bin/python

# $Header$

#
# Program:
#
#    logMirroredFiles.py
#
# Original Author:
#
#    Lori Corbani
#
# Purpose:
#
#    Log mirrored files into APP_FilesMirrored table in RADAR
#
# Requirements Satisfied by This Program:
#
# Usage:
#	logMirroredFiles.py MIRRORFTPPKGFILE MIRRORFTPPKG LOGFILETYPE
#
#	MIRRORFTPPKGFILE is the name of the mirror_ftp package file (ex. grendel.jax.org)
#	MIRRORFTPPKG is the name of the specific package within the file that
#		is downloading the files we want to log (ex. GB_NC)
#	LOGFILETYPE is the file type of the files we're logging (ex. "GenBank").
#		This value will be stored in APP_FilesMirrored.fileType.
#
# Envvars:
#
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
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
# 04/29/2004 lec
#	- JSAM; created
#

import sys
import os
import string
import time
import db

package_str = 'package='
local_dir_str = 'local_dir='

#
# Main
#

server = os.environ['DBSERVER']
database = os.environ['DBNAME']
user = os.environ['DBUSER']
passwordFileName = os.environ['DBPASSWORDFILE']
password = string.strip(open(passwordFileName, 'r').readline())
unixLogin = os.environ['USER']

pkgFileName = sys.argv[1]
pkg = sys.argv[2]
fileType = sys.argv[3]

# Initialize db.py DBMS parameters
db.set_sqlLogin(user, password, server, database)
 
# Find the MIRRORFTPPKGFILE and retrieve the local_dir name from it

try:
    pkgFile = open(pkgFileName, 'r')
except:
    print 'Could not open package file: %s' % (pkgFileName)
    sys.exit(1)

foundPackage = 0
foundLocalDir = 0
local_dir = ''

for line in pkgFile.readlines():

    if not foundPackage:
        # find the package
        idx = string.find(line[:-1], package_str + pkg)
        if idx >= 0:
	    foundPackage = 1
	continue

    elif not foundLocalDir:
        # find the local file directory
        idx = string.find(line[:-1], local_dir_str)
        if idx >= 0:
	    foundLocalDir = 1
	    local_dir = line[len(local_dir_str) + 1:-1]
	    os.chdir(local_dir)

	    # find each file
	    for f in os.listdir(local_dir):

		# ignore files that start with a dot
		if f[0] != '.':
		    localtime = time.localtime(os.stat(f)[8])
		    fileTimeStamp = '%s/%s/%s %s:%s' \
			% (localtime[1], localtime[2], localtime[0], localtime[3], localtime[4])

		    # log the file to RADAR
		    db.sql("exec APP_logMirroredFiles '%s', '%s', '%s', '%s'" 
			% (fileType, os.path.join(local_dir, f), fileTimeStamp, unixLogin), None)

if not foundPackage:
    print 'Could not find package: "%s"' (pkg)
    sys.exit(1)

if not foundLocalDir:
    print 'Could not find package file path: "%s"' % (local_dir_str)
    sys.exit(1)

sys.exit(0)

# $Log$