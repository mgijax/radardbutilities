#!/usr/local/bin/python

import sys 
import db
import string
import os


#
# Main
#

radarServer=sys.argv[1]
radarDB=sys.argv[2]
tempTable=sys.argv[3]
bcpFile=sys.argv[4]

nia74Lib = 'NIA Mouse 7.4K cDNA Clone Set'
nia15Lib = 'NIA Mouse 15K cDNA Clone Set'

fp = open(bcpFile,"w")

db.set_sqlServer(radarServer)
db.set_sqlDatabase(radarDB)

cmd = []

#
# Select all clone libraries from the NIA_Parent_Daughter_Clones table
# that don't already exist in the temp table.
#
cmd.append('select distinct "NIA" "cloneSet", ' + \
                  'n.cloneLibrary "goodName", n.cloneLibrary "badName" ' + \
           'from NIA_Parent_Daughter_Clones n ' + \
           'where not exists ' + \
               '(select 1 ' + \
                'from tempdb..' + tempTable + ' t ' + \
                'where t.badName = n.cloneLibrary)')

#
# Find out if the NIA 7.4K clone library has already been loaded into the
# temp table.
#
cmd.append('select count(*) "count" ' + \
           'from tempdb..' + tempTable + ' ' + \
           'where badName = "' + nia74Lib + '"')

#
# Find out if the NIA 15K clone library has already been loaded into the
# temp table.
#
cmd.append('select count(*) "count" ' + \
           'from tempdb..' + tempTable + ' ' + \
           'where badName = "' + nia15Lib + '"')

results = db.sql(cmd, 'auto')

count = 0

#
# Write each clone library to the bcp file.
#
for r in results[0]:
    fp.write(r['cloneSet'] + '\t' + r['goodName'] + '\t' + r['badName'] + '\n')
    count = count + 1

#
# Write the NIA 7.4K clone library to the bcp file if it doesn't already exist.
#
if results[1][0]['count'] == 0:
    fp.write('NIA 7.4K' + '\t' + nia74Lib + '\t' + nia74Lib + '\n')
    count = count + 1

#
# Write the NIA 15K clone library to the bcp file if it doesn't already exist.
#
if results[2][0]['count'] == 0:
    fp.write('NIA 15K' + '\t' + nia15Lib + '\t' + nia15Lib + '\n')
    count = count + 1

fp.close()

#
# If any libraries were found, exit with a 0 to let the caller know
# there is something to load.
#
if count > 0:
    sys.exit(0)
else:
    sys.exit(1)
