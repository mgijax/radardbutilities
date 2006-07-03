#!/bin/csh -f -x

#
# Program:
#
#	logMirroredFiles.csh
#
# Original Author:
#
#	Lori Corbani
#
# Purpose:
#
#	Wrapper for logMirroredFiles.py
#	which logs mirrored files (see mirror_ftp) to RADAR
#
# Inputs:
#
#	RADAR DB Schema Path (ex. /usr/local/mgi/dbutils/radar/radardbschema)
#	Mirror FTP Package file (ex. /usr/local/mgi/mirror_ftp/grendel.jax.org)
#	Mirror FTP Package	(ex. GB_NC; from "package=" line in previous file)
#	Log File Type		(ex. GenBank)
#
# Outputs:
#
#	Exit status 1 if unsuccessful
#	Exit status 0 if successful
#
# Usage:
#
#	logMirroredFiles.csh RDRDBSchemaPath MirrorFTPPackageFile MirrorFTPPackage LogFileType
#
#	should be piggybacked after call to:
#		runmirror MirrorFTPPackageFile MirrorFTPPackageFile.log
#
#	for example, cron entry to log GenBank non-cummulative update files:
#
#		/usr/local/mgi/mirror_ftp/runmirror grendel.jax.org grendel.jax.org.log;
#		/usr/local/mgi/dbutils/radardbutilities/bin/logMirroredFiles.csh
#		/usr/local/mgi/dbutils/radar/radardbschema 
#		/usr/local/mgi/mirror_ftp/grendel.jax.org
#		GB_NC
#		GenBank
#
# Modification History
#
# 04/29/2004 lec
#	- JSAM; created
#

cd `dirname $0`

#
#  Verify the argument(s) to the shell script.
#

if  ( ${#argv} != 4 ) then
    echo "Usage: $0  RDRDBSchemaPath MirrorFTPPackageFile MirrorFTPPackage LogFileType"
    exit 1
else
    setenv RDRDBSCHEMAPATH $1
    setenv MIRRORFTPPKGFILE $2
    setenv MIRRORFTPPKG $3
    setenv LOGFILETYPE $4
endif

if ( ! -e ${RDRDBSCHEMAPATH}/Configuration ) then
	echo "Cannot locate ${RDRDBSCHEMAPATH}/Configuration file"
	exit 1
endif

# source the RDR DB Schema Configuration file

source ${RDRDBSCHEMAPATH}/Configuration

# traverse thru the files in the MirrorFTPPackage local_dir and log new ones in RADAR
# uses RADAR_DBSERVER, RADAR_DBNAME, RADAR_DBUSER, RADAR_DBPASSWORDFILE, 
# MIRRORFTPPKGFILE, MIRRORFTPPKG, LOGFILETYPE env variables
./logMirroredFiles.py

# if status != 0, then exit with return code 1

if ( $status != 0 ) then
	echo 'Error logging mirrored files.'
	exit 1
else
	echo 'Logging mirrored files was successful.'
	exit 0
endif
 
