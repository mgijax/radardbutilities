#!/bin/csh -f

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
#       2. Truncate the MGI_CloneLibrary table
#       3. Drop the indexes on the MGI_CloneLibrary table
#	4. Call CloneLibrary.py to load the clone libraries into the
#          temp table and create a bcpfile for the MGI_CloneLibrary
#          table (adding the library number)
#	5. Load the bcp file into the MGI_CloneLibrary table
#       6. Create the indexes on the MGI_CloneLibrary table
#	7. Drop the temp table tempdb..CloneLibraryTemp
#
# Modification History:
#
# 02/23/2004	dbm
#	- new
#
# 05/19/2004	dbm
#	- merged 3 Python scripts into one
#

cd `dirname $0` && source ../Configuration

setenv LOG      ${LOGDIR}/`basename $0`1.log
rm -rf ${LOG}
touch ${LOG}

setenv TEMPTABLE	CloneLibraryTemp
setenv LIBTABLE	MGI_CloneLibrary
setenv BCPFILE	${DATADIR}/${LIBTABLE}.bcp

date >> ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >>& ${LOG}

use tempdb
go

create table ${TEMPTABLE}
(
  cloneSet  varchar(80) not null,
  goodName  varchar(255) not null,
  badName   varchar(255) not null
)
go

grant all on ${TEMPTABLE} to public
go

checkpoint
go

quit

EOSQL

${RADAR_DBSCHEMADIR}/table/${LIBTABLE}_truncate.object >>& ${LOG}
${RADAR_DBSCHEMADIR}/index/${LIBTABLE}_drop.object >>& ${LOG}

./CloneLibrary.py  ${MGD_DBSERVER} ${MGD_DBNAME} ${RADAR_DBSERVER} ${RADAR_DBNAME} ${TEMPTABLE} ${BCPFILE} >>& ${LOG}

if ( $status == 0 ) then
    cat ${RADAR_DBPASSWORDFILE} | bcp ${RADAR_DBNAME}..${LIBTABLE} in ${BCPFILE} -c -t\\t -S${RADAR_DBSERVER} -U${RADAR_DBUSER} >>& ${LOG}
endif

${RADAR_DBSCHEMADIR}/index/${LIBTABLE}_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >>& ${LOG}

use tempdb
go

drop table ${TEMPTABLE}
go

checkpoint
go

quit

EOSQL

date >> ${LOG}
