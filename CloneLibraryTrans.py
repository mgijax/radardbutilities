#!/usr/local/bin/python

import sys 
import db
import string
import os

bcpFile=sys.argv[1]
mgdServer=sys.argv[2]
mgdDB=sys.argv[3]


#
# Main
#

fp = open(bcpFile,"w")

db.set_sqlServer(mgdServer)
db.set_sqlDatabase(mgdDB)

cmd = []

#
# Select all clone libraries defined in the MGI_Translation table and
# load them into a temp table.
#
cmd.append('select s.name "cloneSet", p._Source_key, ' + \
                  't.badName "badName", p.name "goodName" ' + \
           'into #tempCloneLibTrans ' + \
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
# Select all clone libraries not defined in the MGI_Translation table and
# add them to the temp table.
#
cmd.append('insert into #tempCloneLibTrans ' + \
           'select s.name "cloneSet", p._Source_key, ' + \
                  'p.name "badName", p.name "goodName" ' + \
           'from PRB_Source p, ' + \
                'MGI_Set s, ' + \
                'MGI_SetMember sm ' + \
           'where not exists ' + \
               '(select 1 ' + \
                'from MGI_Translation t, MGI_TranslationType tt ' + \
                'where p._Source_key = t._Object_key and ' + \
                      't._TranslationType_key = tt._TranslationType_key and ' + \
                      'tt.translationType = "Library") and ' + \
                 'p._Source_key = sm._Object_key and ' + \
                 'sm._Set_key = s._Set_key and ' + \
                 's._MGIType_key = 5')

#
# Select all the clone libraries to write to the bcp file.
#
cmd.append('select cloneSet, badName, goodName ' + \
           'from #tempCloneLibTrans ' + \
           'order by cloneSet, badName, goodName')

results = db.sql(cmd, 'auto')

#
# Initialize the library key.
#
libraryKey = 0

#
# Write each clone library to the bcp file with a unique library key.
#
for r in results[2]:
    libraryKey = libraryKey + 1
    fp.write(str(libraryKey) + '\t' + r['cloneSet'] + '\t' + \
        r['badName'] + '\t' + r['goodName'] + '\n')

fp.close()

#
# If any library keys were used, exit with a 0 to let the caller know
# there is something to load.
#
if libraryKey > 0:
    sys.exit(0)
else:
    sys.exit(1)
