#!/usr/local/bin/python

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
#    RADAR_DBSERVER
#    RADAR_DBNAME
#    RADAR_DBUSER
#    RADAR_DBPASSWORDFILE
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
# 04/20/2006	lec
#	- MGI 3.5; DBSERVER => RADAR_DBSERVER, DBNAME => RADAR_DBNAME,
#         DBUSER => RADAR_DBUSER, DBPASSWORDFILE => RADAR_DBPASSWORDFILE
#
# 04/29/2004 lec
#	- JSAM; created
#

import sys
import os
import string
import time
import db
import mgi_utils

package_str = 'package='
local_dir_str = 'local_dir='
cdate = mgi_utils.date('%m/%d/%Y')

#
# Main
#

server = os.environ['RADAR_DBSERVER']
database = os.environ['RADAR_DBNAME']
user = os.environ['RADAR_DBUSER']
passwordFileName = os.environ['RADAR_DBPASSWORDFILE']
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

		    fileSize = os.stat(f)[6] / 1000
		    if fileSize == 0:
			fileSize = 1

		    # don't log lock files or dummy files

		    if string.find(f, "lock") >= 0 or string.find(f, "ncdummy") >= 0:
		      continue

		    # log the file to RADAR
		    db.sql('exec APP_logMirroredFile "%s", "%s", %s, "%s", "%s"' 
			% (fileType, os.path.join(local_dir, f), fileSize, fileTimeStamp, unixLogin), None)
		    db.commit()

if not foundPackage:
    print 'Could not find package: "%s"' % (pkg)
    sys.exit(1)

if not foundLocalDir:
    print 'Could not find package file path: "%s"' % (local_dir_str)
    sys.exit(1)

# only print out the files that were logged on the current date

results = db.sql('select fileName, fileSize from APP_FilesMirrored ' + \
	'where fileType = "%s" ' % (fileType) + \
	'and convert(char(10), creation_date, 101) = "%s" ' % (cdate) + \
	'order by _File_key', 'auto')
for r in results:
    print r['fileName'], `r['fileSize']`

sys.exit(0)

