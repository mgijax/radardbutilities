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

fp = open(bcpFile,"w")

db.set_sqlServer(radarServer)
db.set_sqlDatabase(radarDB)

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
