#!/bin/csh -f

# $Header$
# $Name$

#
# Program: RIKENClones.csh
#
# Original Author: Dave Miers
#
# Purpose:
#
#	Loads the RIKEN_FANTOM_Clones table in the RADAR database with
#       RIKEN clone IDs from the MGD database.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	RIKENClones.csh
#
# Envvars:
#
# Inputs:
#
#	data/RIKEN_FANTOM_Clones.bcp (generated at runtime)
#
# Outputs:
#
#	logs/RIKENClones.csh.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Truncate RIKEN_FANTOM_Clones table
#	2. Call RIKENClones.py to create the bcp file of RIKEN clone IDs
#	3. BCP RIKEN_FANTOM_Clones.bcp into RIKEN_FANTOM_Clones
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

setenv TABLE	RIKEN_FANTOM_Clones
setenv BCPFILE	${DATADIR}/${TABLE}.bcp

date >> ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object >> ${LOG}

date >> ${LOG}

RIKENClones.py ${BCPFILE} ${MGD_DBSERVER} ${MGD_DBNAME}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${BCPFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}
