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
#	2. Drop indexes on RIKEN_FANTOM_Clones table
#	3. Call RIKENClones.py to create the bcp file of RIKEN clone IDs
#	4. BCP RIKEN_FANTOM_Clones.bcp into RIKEN_FANTOM_Clones
#	5. Create indexes on RIKEN_FANTOM_Clones table
#
# Modification History:
#
# 02/23/2004	dbm
#	- new
#

cd `dirname $0` && source ../Configuration

setenv LOG      ${LOGDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

setenv TABLE	RIKEN_FANTOM_Clones
setenv BCPFILE	${DATADIR}/${TABLE}.bcp

date >> ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object >>& ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object >>& ${LOG}

RIKENClones.py ${BCPFILE} ${MGD_DBSERVER} ${MGD_DBNAME} >>& ${LOG}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${BCPFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

${SCHEMADIR}/index/${TABLE}_create.object >>& ${LOG}

date >> ${LOG}
