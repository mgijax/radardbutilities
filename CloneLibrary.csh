#!/bin/csh -f

# $Header$
# $Name$

#
# Program: CloneLibrary.csh
#
# Original Author: Dave Miers
#
# Purpose:
#
#	Loads the MGI_CloneLibrary table in the RADAR database with
#       clone libraries from the MGD database.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	CloneLibrary.csh
#
# Envvars:
#
# Inputs:
#
#	data/MGI_CloneLibrary_1.bcp (generated at runtime)
#	data/MGI_CloneLibrary_2.bcp (generated at runtime)
#
# Outputs:
#
#	logs/CloneLibrary.csh.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Truncate MGI_CloneLibrary table
#	2. Call CloneLibraryTrans.py to create the first bcp file of
#          clone libraries
#	3. BCP MGI_CloneLibrary_1.bcp into MGI_CloneLibrary
#	4. Call CloneLibraryNIA.py to create the second bcp file of
#          clone libraries
#	5. BCP MGI_CloneLibrary_2.bcp into MGI_CloneLibrary
#
# Modification History:
#
# 02/23/2004	dbm
#	- new
#

cd `dirname $0` && source Configuration

setenv LOG      ${LOGDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

setenv TABLE	MGI_CloneLibrary
setenv BCPFILE1	${DATADIR}/${TABLE}_1.bcp
setenv BCPFILE2	${DATADIR}/${TABLE}_2.bcp

date >> ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object >> ${LOG}

date >> ${LOG}

CloneLibraryTrans.py ${BCPFILE1} ${MGD_DBSERVER} ${MGD_DBNAME}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${BCPFILE1} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}

CloneLibraryNIA.py ${BCPFILE2} ${DBSERVER} ${DBNAME}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${BCPFILE2} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}
