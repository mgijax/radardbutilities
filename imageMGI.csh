#!/bin/csh -f

# $Header$
# $Name$

#
# Program: imageMGI.csh
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	Loads data/IMG_MGI_IMAGE.txt file into radar..IMG_MGI_IMAGE
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	imageMGI.csh
#
# Envvars:
#
# Inputs:
#
#	data/IMG_MGI_IMAGE.txt
#
# Outputs:
#
#	data/imageMGI.csh.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Truncate table
#	2. Drop Indexes
#	3. BCP file
#	4. Create Indexes
#
# Modification History:
#
# 11/12/2003	lec
#	- new
#

cd `dirname $0` && source Configuration

setenv LOG      ${DATADIR}/`basename $0`.log
rm -rf $LOG
touch $LOG

setenv TABLE	IMG_MGI_IMAGE
setenv DATAFILE	${DATADIR}/IMG_MGI_IMAGE.txt

date >> $LOG

${SCHEMADIR}/table/${TABLE}_truncate.object | tee -a ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object | tee -a ${LOG}
cat $DBPASSWORDFILE | bcp ${DBNAME}..${TABLE} in ${DATAFILE} -c -t\\t -U$DBUSER >>& ${LOG}
${SCHEMADIR}/index/${TABLE}_create.object | tee -a ${LOG}

date >> $LOG

