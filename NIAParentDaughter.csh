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
#	Loads radar..NIA_Parent_Daughter_Clones from 2 NIA input files.
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
#	/data/downloads/clone_sets/NIA/NIA-CloneSets-DaughterClone.txt
#	/data/downloads/clone_sets/NIA/NIA-CloneSets-ParentClone.txt
#
# Outputs:
#
#	NIAParentDaughter.log
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
# Modification History:
#
# 11/12/2003	lec
#	- new
#

cd `dirname $0` && source Configuration

setenv LOG      ${DATADIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

setenv TABLE	NIA_Parent_Daughter_Clones
setenv DATAFILE1	/data/downloads/clone_sets/NIA/NIA-CloneSets-DaughterClone.txt
setenv DATAFILE2	/data/downloads/clone_sets/NIA/NIA-CloneSets-ParentClone.txt

date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

create table tempdb..NIA_Daughter
(
  origin       varchar(5) not null,
  daughterID   varchar(30) not null,
  parentID     varchar(30) not null,
  imageID      varchar(5) not null,
  libraryID    varchar(5) not null,
  libraryName  varchar(30) not null,
  seqIDs       varchar(60) not null
)
go

create table tempdb..NIA_Parent
(
  origin         varchar(5) not null,
  parentID       varchar(30) not null,
  imageID        varchar(10) not null,
  libraryID      varchar(10) not null,
  libraryName    varchar(255) not null,
  seqIDs         varchar(60) not null
)
go

checkpoint
go

quit

EOSQL

cat ${DBPASSWORDFILE} | bcp tempdb..NIA_Daughter in ${DATAFILE1} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
cat ${DBPASSWORDFILE} | bcp tempdb..NIA_Parent in ${DATAFILE2} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

${SCHEMADIR}/table/${TABLE}_truncate.object | tee -a ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use ${DBNAME}
go

insert into ${TABLE}
select d.parentID, d.daughterID, d.origin, p.libraryName
from tempdb..NIA_Daughter d, tempdb..NIA_Parent p
where d.parentID = p.parentID
go

checkpoint
go

quit

EOSQL

${SCHEMADIR}/index/${TABLE}_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

drop table NIA_Daughter
go

drop table NIA_Parent
go

checkpoint
go

quit

EOSQL

date >> ${LOG}

