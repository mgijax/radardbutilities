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
#	/data/downloads/clone_sets/NIA/NIA-CloneSets-ParentClone-Ext.txt
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
#	1. Create the temp table NIA_Daughter
#	2. Create the temp table NIA_Parent
#	3. BCP daughter clones into the NIA_Daughter table
#	4. BCP parent clones into the NIA_Parent table
#	5. BCP extended parent clones into the NIA_Parent table if they exist
#	6. Truncate NIA_Parent_Daughter_Clones table
#	7. Drop indexes on NIA_Parent_Daughter_Clones table
#	8. Join the 2 temp tables on parentID and load the results into
#	   the NIA_Parent_Daughter_Clones table
#	9. Create indexes on NIA_Parent_Daughter_Clones table
#	10. Drop the temp table NIA_Daughter
#	11. Drop the temp table NIA_Parent
#
# Modification History:
#
# 11/12/2003	lec
#	- new
#

cd `dirname $0` && source ../Configuration

setenv LOG      ${LOGDIR}/`basename $0`1.log
rm -rf ${LOG}
touch ${LOG}

setenv DAUGHTERTABLE	NIA_Daughter
setenv PARENTTABLE	NIA_Parent
setenv TABLE		NIA_Parent_Daughter_Clones
setenv DAUGHTERFILE	/data/downloads/clone_sets/NIA/NIA-CloneSets-DaughterClone.txt
setenv PARENTFILE	/data/downloads/clone_sets/NIA/NIA-CloneSets-ParentClone.txt
setenv PARENTFILE_EXT	/data/downloads/clone_sets/NIA/NIA-CloneSets-ParentClone-Ext.txt

date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

create table ${DAUGHTERTABLE}
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

create table ${PARENTTABLE}
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

cat ${DBPASSWORDFILE} | bcp tempdb..${DAUGHTERTABLE} in ${DAUGHTERFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

cat ${DBPASSWORDFILE} | bcp tempdb..${PARENTTABLE} in ${PARENTFILE} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}

if ( -r ${PARENTFILE_EXT} ) then
    cat ${DBPASSWORDFILE} | bcp tempdb..${PARENTTABLE} in ${PARENTFILE_EXT} -c -t\\t -S${DBSERVER} -U${DBUSER} >>& ${LOG}
endif

${SCHEMADIR}/table/${TABLE}_truncate.object >>& ${LOG}
${SCHEMADIR}/index/${TABLE}_drop.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use ${DBNAME}
go

insert into ${TABLE}
select d.parentID, d.daughterID, d.origin, p.libraryName
from tempdb..${DAUGHTERTABLE} d, tempdb..${PARENTTABLE} p
where d.parentID = p.parentID
go

checkpoint
go

quit

EOSQL

${SCHEMADIR}/index/${TABLE}_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >>& ${LOG}

use tempdb
go

drop table ${DAUGHTERTABLE}
go

drop table ${PARENTTABLE}
go

checkpoint
go

quit

EOSQL

date >> ${LOG}
