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
#	logMirroredFiles.py
#
# Envvars:
#
#    DBSERVER
#    DBNAME
#    DBUSER
#    DBPASSWORDFILE
#    MIRRORFTPPKGFILE
#    MIRRORFTPPKG
#    LOGFILETYPE
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
pkgFileName = os.environ['MIRRORFTPPKGFILE']
pkg = os.environ['MIRRORFTPPKG']
fileType = os.environ['LOGFILETYPE']

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
	    local_dir = line[idx + len(local_dir_str):-1]
	    os.chdir(local_dir)

	    # find each file
	    for f in os.listdir(local_dir):

		# ignore files that start with a dot
		if os.path.isfile(f) and f[0] != '.':
		    localtime = time.localtime(os.stat(f)[8])
		    fileTimeStamp = '%s/%s/%s %s:%s' \
			% (localtime[1], localtime[2], localtime[0], localtime[3], localtime[4])

		    fileSize = os.stat(f)[6]
		    print f, str(fileSize)

		    # log the file to RADAR
		    db.sql('exec APP_logMirroredFile "%s", "%s", %s, "%s", "%s"' 
			% (fileType, os.path.join(local_dir, f), fileSize, fileTimeStamp, unixLogin), None)

if not foundPackage:
    print 'Could not find package: "%s"' (pkg)
    sys.exit(1)

if not foundLocalDir:
    print 'Could not find package file path: "%s"' % (local_dir_str)
    sys.exit(1)

sys.exit(0)

# $Log$
# Revision 1.4  2004/04/30 11:43:43  lec
# JSAM
#
# Revision 1.3  2004/04/29 18:14:51  lec
# JSAM
#
# Revision 1.2  2004/04/29 16:37:31  lec
# JSAM
#
# Revision 1.1  2004/04/29 15:29:22  lec
# JSAM
#
