#  $Header$
#  $Name$
#
#  DLAfunctions.sh
###########################################################################
#
#  Purpose:  This script provides shell script functions to any script that
#            executes it.
#
#  Usage:
#
#      . DLAfunctions.sh
#
#  Env Vars:  None
#
#  Inputs:  See individual functions
#
#  Outputs:  See individual functions
#
#  Exit Codes:  See individual functions
#
#  Assumes:
#
#      - Bourne shell is being used.
#
#  Implementation:  See individual functions
#
#  Notes:  None
#
###########################################################################


###########################################################################
#
#  Function:  createArchive
#
#  Usage:  createArchive  archiveDir  sourceDir1  ...  sourceDirN
#
#          where
#              archiveDir is the directory where the archive file is to be
#                         created.
#              sourceDirs are the directories where the function will
#                         look for files to include in the archive.
#
#  Purpose:  Create an archive of all files in the given source directories
#            and any subdirectories.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:
#
#      - Creates the archive directory if it does not already exist.
#      - Creates an archive file in the archive directory.
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
createArchive ()
{
#
#  Make sure the archive directory was passed to the script, along with at
#  least one source directory to create the archive from.
#
if [ $# -lt 2 ]
then
    echo "Usage:  createArchive  archiveDir  sourceDir(s)"
    exit 1
fi

#
#  If the archive directory does not exist, it should be created.
#
ARC_DIR=$1
shift

if [ ! -d ${ARC_DIR} ]
then
    mkdir ${ARC_DIR}
    if [ $? -ne 0 ]
    then
        echo "Cannot create archive directory: ${ARC_DIR}"
        exit 1
    fi
fi

#
#  Get the date and time to use for archiving the files.
#
ARC_FILE=${ARC_DIR}/arc`date '+%Y%m%d.%H%M'`.jar

#
#  Archive the files.
#
LIST=`find $* -type f -print 2>/dev/null`
if [ `echo ${LIST} | wc -l` -gt 0 ]
then
    for FILE in `echo ${LIST}`
    do
        if [ -f ${ARC_FILE} ]
        then
            jar -uvfM ${ARC_FILE} ${FILE} >/dev/null 2>&1
        else
            jar -cvfM ${ARC_FILE} ${FILE} >/dev/null 2>&1
        fi
    done
fi
}


###########################################################################
#
#  Name:  createLock
#
#  Usage:  createLock  lockfile
#
#          where
#              lockfile is the name of the lock file to be created.
#
#  Purpose:  Create the given lock file.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Creates the given lock file.
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
createLock ()
{
#
#  Make sure the lock file was passed to the script.
#
if [ $# -ne 1 ]
then
    echo "Usage:  createLock  lockfile"
    exit 1
fi

#
#  Make sure the lock file doesn't already exist.
#
if [ -f $1 ]
then
    echo "Lock file already exists: $1"
    exit 1
fi

#
#  Create the lock file.
#
date > $1
if [ $? -ne 0 ]
then
    echo "Could not create lock file: $1"
    exit 1
fi
}


###########################################################################
#
#  Name:  getConfigEnv
#
#  Usage:  getConfigEnv  [-e]
#
#          where
#              -e is an option to display all environment variables.
#
#  Purpose:  Write the basic configuration settings and the complete
#            list of environment variables (optional) to stdout.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Nothing
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
getConfigEnv ()
{
#
#  Check for the environment option.
#
if [ $# -eq 1 -a "$1" = "-e" ]
then
    ENV_OPT="YES"
elif [ $# -eq 0 ]
then
    ENV_OPT="NO"
else
    echo "Usage:  getConfigEnv  [-e]"
    exit 1
fi

echo "============================================================"
echo "Platform: `hostname`"
echo "Job Stream: $0"

if [ "${ENV_OPT}" = "YES" ]
then
    echo "\n**** Environment Variables ****"
    env | pg | sort
fi
echo "============================================================"
}


###########################################################################
#
#  Name:  mailLog
#
#  Usage:  mailLog  recipient-list  subject  logfile
#
#          where
#              recipient-list is a comma separated list of email address to
#                             sent the log to.
#              subject is the text to appear in the email subject line.
#              logfile is the path of the log file to be mailed.
#
#  Purpose:  Send the contents of the given log file to each recipient.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Nothing
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
mailLog ()
{
#
#  Validate the arguments to the function.
#
if [ $# -ne 3 ]
then
    echo "Usage:  mailLog  recipient-list  subject  logfile"
    exit 1
fi
RECIPIENTS=$1
SUBJECT=$2
LOGFILE=$3

#
#  Make sure the log file exists.
#
if [ ! -r ${LOGFILE} ]
then
    echo "Cannot read log file: ${LOGFILE}"
    exit 1
fi

#
#  Mail the log file.
#
for i in `echo ${RECIPIENTS} | sed 's/,/ /g'`
do
    mailx -s "${SUBJECT}" ${i} < ${LOGFILE}
done
}


###########################################################################
#
#  Name:  removeLock
#
#  Usage:  removeLock  lockfile
#
#          where
#              lockfile is the name of the lock file to be removed.
#
#  Purpose:  Remove the given lock file.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Removes the lock file.
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
removeLock ()
{
#
#  Make sure the lock file was passed to the script.
#
if [ $# -ne 1 ]
then
    echo "Usage:  removeLock  lockfile"
    exit 1
fi

#
#  Make sure the lock file exist.
#
if [ ! -f $1 ]
then
    echo "Lock file does not exist: $1"
    exit 1
fi

#
#  Remove the lock file.
#
rm -f $1
if [ $? -ne 0 ]
then
    echo "Could not remove lock file: $1"
    exit 1
fi
}


###########################################################################
#
#  Name:  startLog
#
#  Usage:  startLog  logfile1  logfile2  ...  logfileN
#
#          where
#              logfiles are the log files that need to be initialized
#                  for use with this job stream.
#
#  Purpose:  Clear the given log files and write a startup timestamp to
#            each one.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Removes any prior contents of the given log files.
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
startLog ()
{

#
#  Make sure at least one log file was passed to the script.
#
if [ $# -eq 0 ]
then
    echo "Usage:  startLog  logfile(s)" | tee -a ${LOG}
    exit 1
fi

while [ "$1" != "" ]
do
    if [ ! -f $1 -o -w $1 ]
    then
        echo "Start Log: `date`" > $1
    else
        echo "Cannot write to log file: $1" | tee -a ${LOG}
        exit 1
    fi
    shift
done
}


###########################################################################
#
#  Name:  stopLog
#
#  Usage:  stopLog  logfile1  logfile2  ...  logfileN
#
#          where
#              logfiles are the log files that need to be stopped.
#
#  Purpose:  Append a timestamp to signal the end of each of the given
#            log files.
#
#  Returns:
#
#      Nothing = Successful completion
#      1 = An error occurred
#
#  Assumes:  Nothing
#
#  Effects:  Nothing
#
#  Throws:  Nothing
#
#  Notes:  None
#
###########################################################################
stopLog ()
{
#
#  Make sure at least one log file was passed to the script.
#
if [ $# -eq 0 ]
then
    echo "Usage:  startLog  logfile(s)" | tee -a ${LOG}
    exit 1
fi

while [ "$1" != "" ]
do
    if [ -w $1 ]
    then
        echo "\nStop Log: `date`" >> $1
    else
        echo "Cannot write to log file: $1" | tee -a ${LOG}
        exit 1
    fi
    shift
done
}

preload ()
{
#
#  Function that performs cleanup tasks for the job stream prior to
#  termination.
#
#
#  Archive the log and report files from the previous run.
#
createArchive ${ARCHIVEDIR} ${LOGDIR} ${RPTDIR} | tee -a ${LOG}

#
#  Initialize the log files.
#
startLog ${LOG_PROC} ${LOG_DIAG} ${LOG_CUR} ${LOG_VAL} | tee -a ${LOG}

#
#  Write the configuration information to the log files.
#
getConfigEnv >> ${LOG_PROC}
getConfigEnv -e >> ${LOG_DIAG}

#
#  Start a new job stream and get the job stream key.
#
echo "Start a new job stream" >> ${LOG_PROC}
JOBKEY=`${JOBSTART_CSH} ${RADAR_DBSCHEMADIR} ${JOBSTREAM}`
if [ $? -ne 0 ]
then
    echo "Could not start a new job stream for this load" >> ${LOG_PROC}
    postload
    exit 1
fi
echo "JOBKEY=${JOBKEY}" >> ${LOG_PROC}
}


#
#  Function that performs cleanup tasks for the job stream prior to
#  termination.
#
postload ()
{
    #
    #  End the job stream if a new job key was successfully obtained.
    #  The STAT variable will contain the return status from the data
    #  provider loader or the clone loader.
    #
    if [ ${JOBKEY} -gt 0 ]
    then
	echo "End the job stream" >> ${LOG_PROC}
	${JOBEND_CSH} ${RADAR_DBSCHEMADIR} ${JOBKEY} ${STAT}
    fi
    #
    #  End the log files.
    #
    stopLog ${LOG_PROC} ${LOG_DIAG} ${LOG_CUR} ${LOG_VAL} | tee -a ${LOG}
}


#  $Log$
#  Revision 1.2  2004/04/09 17:32:51  mbw
#  added preload and postload functions
#
#  Revision 1.6  2004/03/31 15:29:20  dbm
#  Use hostname command to get platform name in getConfigEnv() function
#
#  Revision 1.5  2003/11/26 18:24:46  dbm
#  Changed createArchive to accept a list of directories to archive
#
#  Revision 1.4  2003/10/17 17:48:17  dbm
#  Fixed bug in StartLog
#
#  Revision 1.3  2003/08/08 13:23:52  dbm
#  Add reports directory to archiving and send getConfigEnv output to stdout.
#
#  Revision 1.2  2003/05/13 18:59:44  dbm
#  Added lock file functions and more error checking
#
#  Revision 1.1  2003/04/07 17:44:04  dbm
#  Initial version
#
###########################################################################
#
# Warranty Disclaimer and Copyright Notice
# 
#  THE JACKSON LABORATORY MAKES NO REPRESENTATION ABOUT THE SUITABILITY OR 
#  ACCURACY OF THIS SOFTWARE OR DATA FOR ANY PURPOSE, AND MAKES NO WARRANTIES, 
#  EITHER EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY AND FITNESS FOR A 
#  PARTICULAR PURPOSE OR THAT THE USE OF THIS SOFTWARE OR DATA WILL NOT 
#  INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS, OR OTHER RIGHTS.  
#  THE SOFTWARE AND DATA ARE PROVIDED "AS IS".
# 
#  This software and data are provided to enhance knowledge and encourage 
#  progress in the scientific community and are to be used only for research 
#  and educational purposes.  Any reproduction or use for commercial purpose 
#  is prohibited without the prior express written permission of The Jackson 
#  Laboratory.
# 
# Copyright © 1996, 1999, 2002 by The Jackson Laboratory
# 
# All Rights Reserved
#
###########################################################################
