#!/usr/local/bin/python

import sys 
import db
import string
import os

bcpFile=sys.argv[1]
radarServer=sys.argv[2]
radarDB=sys.argv[3]

nia74Lib = 'NIA Mouse 7.4K cDNA Clone Set'
nia15Lib = 'NIA Mouse 15K cDNA Clone Set'


#
# Main
#

fp = open(bcpFile,"w")

db.set_sqlServer(radarServer)
db.set_sqlDatabase(radarDB)

cmd = []

#
# Get the maximum library key already used in the MGI_CloneLibrary table.
#
cmd.append('select max(_Library_key) "key" from MGI_CloneLibrary')

#
# Find out if the NIA 7.4K clone library has already been loaded into the
# MGI_CloneLibrary table.
#
cmd.append('select count(*) "count" ' + \
           'from MGI_CloneLibrary ' + \
           'where badName = "' + nia74Lib + '"')

#
# Find out if the NIA 15K clone library has already been loaded into the
# MGI_CloneLibrary table.
#
cmd.append('select count(*) "count" ' + \
           'from MGI_CloneLibrary ' + \
           'where badName = "' + nia15Lib + '"')

#
# Select all clone libraries from the NIA_Parent_Daughter_Clones table
# that don't already exist in the MGI_CloneLibrary table.
#
cmd.append('select distinct "NIA" "cloneSet", ' + \
                  'n.cloneLibrary "badName", n.cloneLibrary "goodName" ' + \
           'from NIA_Parent_Daughter_Clones n ' + \
           'where not exists ' + \
               '(select 1 ' + \
                'from MGI_CloneLibrary l ' + \
                'where l.badName = n.cloneLibrary)')

results = db.sql(cmd, 'auto')

#
# Initialize the library key to the maximum value from the table.
#
libraryKey = results[0][0]['key']

#
# Write each clone library to the bcp file with a unique library key.
#
for r in results[3]:
    libraryKey = libraryKey + 1
    fp.write(str(libraryKey) + '\t' + r['cloneSet'] + '\t' + \
        r['badName'] + '\t' + r['goodName'] + '\n')

#
# Write the NIA 7.4K clone library to the bcp file if it doesn't already exist.
#
if results[1][0]['count'] == 0:
    libraryKey = libraryKey + 1
    fp.write(str(libraryKey) + '\t' + 'NIA 7.4K' + '\t' + \
        nia74Lib + '\t' + nia74Lib + '\n')

#
# Write the NIA 15K clone library to the bcp file if it doesn't already exist.
#
if results[2][0]['count'] == 0:
    libraryKey = libraryKey + 1
    fp.write(str(libraryKey) + '\t' + 'NIA 15K' + '\t' + \
        nia15Lib + '\t' + nia15Lib + '\n')

fp.close()

#
# If any library keys were used, exit with a 0 to let the caller know
# there is something to load.
#
if libraryKey > 0:
    sys.exit(0)
else:
    sys.exit(1)
