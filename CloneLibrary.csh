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
#	data/CloneLibraryTrans.bcp (generated at runtime)
#	data/CloneLibraryNIA.bcp (generated at runtime)
#	data/MGI_CloneLibrary.bcp (generated at runtime)
#
# Outputs:
#
#	logs/CloneLibrary.csh1.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Create the temp table tempdb..CloneLibraryTemp
#	2. Call CloneLibraryTrans.py to create the first bcp file of
#          clone libraries that have translations
#	3. Load the first bcp file into the temp table
#	4. Call CloneLibraryNIA.py to create the second bcp file of
#          additional NIA clone libraries from the
#          NIA_Parent_Daughter_Clones table
#	5. Load the second bcp file into the temp table
#	6. Call CloneLibrary.py to create the third bcp file of all
#          clone libraries from the temp table (adding the library number)
#	7. Load the third bcp file into the MGI_CloneLibrary table
#	8. Drop the temp table tempdb..CloneLibraryTemp
#
# Modification History:
#
# 02/23/2004	dbm
#	- new
#

cd `dirname $0` && source Configuration

setenv LOG      ${LOGDIR}/`basename $0`1.log
rm -rf ${LOG}
touch ${LOG}

setenv TEMPTABLE	tempdb..CloneLibraryTemp
setenv LIBTABLE	MGI_CloneLibrary
setenv TRANSBCP	${DATADIR}/CloneLibraryTrans.bcp
setenv NIABCP	${DATADIR}/CloneLibraryNIA.bcp
setenv LIBBCP	${DATADIR}/${LIBTABLE}.bcp

date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

create table ${TEMPTABLE}
(
  cloneSet  varchar(80) not null,
  goodName  varchar(255) not null,
  badName   varchar(255) not null
)
go

grant select on ${TEMPTABLE} to public
go

checkpoint
go

quit

EOSQL

date >> ${LOG}

${SCHEMADIR}/table/${LIBTABLE}_truncate.object >> ${LOG}
${SCHEMADIR}/index/${LIBTABLE}_drop.object >> ${LOG}

date >> ${LOG}

CloneLibraryTrans.py ${MGD_DBSERVER} ${MGD_DBNAME} ${TRANSBCP} >> ${LOG}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${TEMPTABLE} in ${TRANSBCP} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}

CloneLibraryNIA.py ${DBSERVER} ${DBNAME} ${TEMPTABLE} ${NIABCP} >> ${LOG}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${TEMPTABLE} in ${NIABCP} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}

CloneLibrary.py ${DBSERVER} ${DBNAME} ${TEMPTABLE} ${LIBBCP} >> ${LOG}

if ( $status == 0 ) then
    cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${LIBTABLE} in ${LIBBCP} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

date >> ${LOG}

${SCHEMADIR}/index/${LIBTABLE}_create.object >> ${LOG}

date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

drop table ${TEMPTABLE}
go

checkpoint
go

quit

EOSQL

date >> ${LOG}
