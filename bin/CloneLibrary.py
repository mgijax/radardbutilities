#!/usr/local/bin/python

import sys 
import db
import string
import os


#
# Main
#

mgdServer=sys.argv[1]
mgdDB=sys.argv[2]
radarServer=sys.argv[3]
radarDB=sys.argv[4]
tempTable=sys.argv[5]
bcpFile=sys.argv[6]

niaSet = 'NIA'
nia15KSet = 'NIA 15K'
nia74KSet = 'NIA 7.4K'
nia15KLib = 'NIA Mouse 15K cDNA Clone Set'
nia74KLib = 'NIA Mouse 7.4K cDNA Clone Set'

db.set_sqlServer(mgdServer)
db.set_sqlDatabase(mgdDB)

cmd = []

#
# Load the temp table with all clone libraries that have translations defined
# in the MGI_Translation table.
#
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'select distinct s.name, p.name, t.badName ' + \
           'from PRB_Source p, ' + \
                'MGI_Translation t, ' + \
                'MGI_TranslationType tt, ' + \
                'MGI_Set s, ' + \
                'MGI_SetMember sm ' + \
           'where p._Source_key = t._Object_key and ' + \
                 't._TranslationType_key = tt._TranslationType_key and ' + \
                 'tt.translationType = "Library" and ' + \
                 'p._Source_key = sm._Object_key and ' + \
                 'sm._Set_key = s._Set_key and ' + \
                 's._MGIType_key = 5')

#
# Load the temp table with a record for each clone library in the PRB_Source
# table so that the good and bad names are the same to allow for lookups of
# good names that do not require a translation.
#
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'select distinct s.name, p.name, p.name ' + \
           'from PRB_Source p, ' + \
                'MGI_Set s, ' + \
                'MGI_SetMember sm ' + \
           'where p._Source_key = sm._Object_key and ' + \
                 'sm._Set_key = s._Set_key and ' + \
                 's._MGIType_key = 5')

results = db.sql(cmd, 'auto')

db.set_sqlServer(radarServer)
db.set_sqlDatabase(radarDB)

cmd = []

#
# Load the temp table with a record for each clone library in the
# NIA_Parent_Daughter_Clones table that does not already exist in the temp
# table.
#
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'select distinct "' + niaSet + '", ' + \
                  'n.cloneLibrary, n.cloneLibrary ' + \
           'from NIA_Parent_Daughter_Clones n ' + \
           'where not exists ' + \
               '(select 1 ' + \
                'from tempdb..' + tempTable + ' t ' + \
                'where t.badName = n.cloneLibrary)')

#
# Delete any NIA 15K or NIA 7.4K libraries from the temp table.
#
cmd.append('delete from tempdb..' + tempTable + ' ' + \
           'where badName = "' + nia15KLib + '" or ' + \
                 'badName = "' + nia74KLib + '"')

#
# Add records to the temp table for the NIA 15K clone library. There should
# be one for the NIA clone set and one for the NIA 15K clone set.
#
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'values ("' + niaSet + '",' + \
           '"' + nia15KLib + '","' + nia15KLib + '")')
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'values ("' + nia15KSet + '",' + \
           '"' + nia15KLib + '","' + nia15KLib + '")')

#
# Add records to the temp table for the NIA 7.4K clone library. There should
# be one for the NIA clone set and one for the NIA 7.4K clone set.
#
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'values ("' + niaSet + '",' + \
           '"' + nia74KLib + '","' + nia74KLib + '")')
cmd.append('insert into tempdb..' + tempTable + ' ' + \
           'values ("' + nia74KSet + '",' + \
           '"' + nia74KLib + '","' + nia74KLib + '")')

results = db.sql(cmd, 'auto')

cmd = []

#
# Select all clone libraries from the temp table. Order them by the "good"
# name to keep all records together that need to be assigned the same
# library number.
#
cmd.append('select cloneSet, goodName, badName ' + \
           'from tempdb..' + tempTable + ' ' + \
           'order by goodName, cloneSet')

results = db.sql(cmd, 'auto')

fp = open(bcpFile,"w")

libraryNum = 0
lastGoodName = ""

#
# Write each clone library to the bcp file. Use the same library number for
# each record with the same "good" library name.
#
for r in results[0]:
    if r['goodName'] != lastGoodName:
        libraryNum = libraryNum + 1
        lastGoodName = r['goodName']
    fp.write(str(libraryNum) + '\t' + r['cloneSet'] + '\t' + \
             r['goodName'] + '\t' + r['badName'] + '\n')

fp.close()

#
# If any libraries were found, exit with a 0 to let the caller know
# there is something to load.
#
if libraryNum > 0:
    sys.exit(0)
else:
    sys.exit(1)
