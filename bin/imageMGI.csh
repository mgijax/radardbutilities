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
#	data/IMAGE_MGI_Human.txt
#
# Outputs:
#
#	logs/imageMGI.csh1.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#	1. Truncate IMG_MGI_IMAGE table
#	2. Drop indexes
#	3. BCP IMG_MGI_IMAGE.txt into IMG_MGI_IMAGE
#	4. Create indexes
#	5. Create temporary MGI_IMAGE_Human table
#	6. BCP IMAGE_MGI_Human.txt into IMAGE_MGI_Human
#	7. Delete records from IMG_MGI_IMAGE that have an imageID in
#          IMAGE_MGI_Human
#
# Modification History:
#
# 11/12/2003	lec
#	- new
#
# 01/12/2004	dbm
#	- Added code to remove human IMAGE IDs
#

cd `dirname $0` && source ../Configuration

setenv LOG      ${LOGDIR}/`basename $0`1.log
rm -rf ${LOG}
touch ${LOG}

setenv TABLE		IMG_MGI_IMAGE
setenv HUMANTABLE	MGI_IMAGE_HUMAN
setenv DATAFILE		${DATADIR}/IMG_MGI_IMAGE.txt
setenv HUMANFILE	${DATADIR}/MGI_IMAGE_Human.txt

date >> ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object >>& ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp ${DBNAME}..${TABLE} in ${DATAFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

${SCHEMADIR}/index/${TABLE}_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

create table ${HUMANTABLE}
(
  mgiID      varchar(30) not null,
  imageID    varchar(30) not null
)
go

checkpoint
go

quit

EOSQL

cat ${DBPASSWORDFILE} | bcp tempdb..${HUMANTABLE} in ${HUMANFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use ${DBNAME}
go

delete ${TABLE}
from ${TABLE} i, tempdb..${HUMANTABLE} h
where i.imageID = h.imageID
go

checkpoint
go

use tempdb
go

drop table ${HUMANTABLE}
go

checkpoint
go

quit

EOSQL

date >> ${LOG}
