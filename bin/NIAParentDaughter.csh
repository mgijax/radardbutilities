#!/bin/csh -f

# $Header$
# $Name$

#
# Program: NIAParentDaughter.csh
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	Loads radar..NIA_Parent_Daughter_Clones from a tab-delimited data file.
#
# Requirements Satisfied by This Program:
#
# Usage:
#
#	NIAParentDaughter.csh
#
# Envvars:
#
# Inputs:
#
#	data/NIA_Parent_Daughter_Clones.txt
#
# Outputs:
#
#	logs/NIAParentDaughter.csh1.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Truncate NIA_Parent_Daughter_Clones table
#	2. Drop indexes on NIA_Parent_Daughter_Clones table
#	3. Load NIA_Parent_Daughter_Clones.txt into the
#          NIA_Parent_Daughter_Clones table using bcp
#	4. Create indexes on NIA_Parent_Daughter_Clones table
#
# Modification History:
#
# 11/12/2003	lec
#	- new
#
# 09/27/2003	dbm
#	- Modified to load the data from one new NIA file that contains all
#	  the required information.
#

cd `dirname $0` && source ../Configuration

setenv LOG      ${LOGDIR}/`basename $0`1.log
rm -rf ${LOG}
touch ${LOG}

setenv TABLE	NIA_Parent_Daughter_Clones
setenv BCPFILE	${DATADIR}/NIA_Parent_Daughter_Clones.txt

date >> ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object >>& ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${BCPFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

${SCHEMADIR}/index/${TABLE}_create.object >>& ${LOG}

date >> ${LOG}
