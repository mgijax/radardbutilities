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
bcpFile=sys.argv[3]

fp = open(bcpFile,"w")

db.set_sqlServer(mgdServer)
db.set_sqlDatabase(mgdDB)

cmd = []

#
# Select all clone libraries defined in the MGI_Translation table and
# load them into a temp table.
#
cmd.append('select distinct s.name "cloneSet", ' + \
                  'p.name "goodName", t.badName "badName" ' + \
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
cmd.append('select distinct s.name "cloneSet", ' + \
                  'p.name "goodName", p.name "badName" ' + \
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

results = db.sql(cmd, 'auto')

count = 0

#
# Write each clone library to the bcp file.
#
for r in results[0]:
    fp.write(r['cloneSet'] + '\t' + r['goodName'] + '\t' + r['badName'] + '\n')
    count = count + 1

for r in results[1]:
    fp.write(r['cloneSet'] + '\t' + r['goodName'] + '\t' + r['badName'] + '\n')
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
