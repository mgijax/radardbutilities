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
# Get all the RIKEN clone IDs.
#
cmd.append('select a.accID ' + \
           'from ACC_Accession a, PRB_Probe p ' + \
           'where a._Object_key = p._Probe_key and ' + \
                 'a._MGIType_key = 3 and ' + \
                 'a._LogicalDB_key = 26 and ' + \
                 'p.name like "RIKEN clone %"')

results = db.sql(cmd, 'auto')

#
# Write each RIKEN clone ID to the bcp file.
#
for r in results[0]:
    fp.write(r['accID'] + '\n')

fp.close()

#
# If any clone IDs were found, exit with a 0 to let the caller know
# there is something to load.
#
if len(results[0]) > 0:
    sys.exit(0)
else:
    sys.exit(1)
