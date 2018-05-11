#! /bin/bash

if [ $# == 3 ]
then
  echo "Performing purging activity in $1 environment .."
  ENV=`echo $1| tr '[:lower:]' '[:upper:]'`
  if [ $ENV == "SIT" ]
  then 
	  PCARD=/opt/pwrcard
	  ORA_USER=FMGR_USER
	  ORA_PASS=NewU53r
  elif [ $ENV == "UAT" ]
  then
      PCARD=/opt/pwrcard/UAT
	  ORA_USER=FMGR_USER
	  ORA_PASS=fm8admin16
  else
      echo "Trying in some other environment... need to modify the script..."
	  exit 1
  fi
else
  echo "Parameter need to be passed to the script : $0 <env name> <Start_Date> <End_Date>"
  exit 1
fi

Start_Date=$2
End_Date=$3

source $PCARD/.pcard_profile

#Purging activity for FM tables

cd $WRAPPER_LOGS
sqlplus -S $ORA_USER/$ORA_PASS > /dev/null 2>&1 << EOF
set head off;
spool on;
spool purging_fm_tables_delete.txt

--select statements for below tables
--JOB_STATUS Table
delete from JOB_STATUS where JOBID in (select JOBID from (select a.JOBID, a.JOBNAME, a.REQUESTDATE, a.PROCESSDATE, b.STATUS, b.statusdate FROM JOBS a, JOB_STATUS b where a.STATUSID = b.STATUSID and a.JOBNAME like '%MO%' and a.REQUESTDATE between '$Start_Date' and '$End_Date' order by a.REQUESTDATE desc));
delete from JOB_STATUS where JOBID in (select JOBID from (select a.JOBID, a.JOBNAME, a.REQUESTDATE, a.PROCESSDATE, b.STATUS, b.statusdate FROM JOBS a, JOB_STATUS b where a.STATUSID = b.STATUSID and a.JOBNAME like '%HK%' and a.REQUESTDATE between '$Start_Date' and '$End_Date' order by a.REQUESTDATE desc));
--JOBS Table
delete from JOBS where JOBNAME like '%MO%' and REQUESTDATE between '$Start_Date' and '$End_Date';
delete from JOBS where JOBNAME like '%HK%' and REQUESTDATE between '$Start_Date' and '$End_Date';
--FILETYPESFORJOB
delete from FILETYPESFORJOB where FILETYPE like '%MO%';
delete from FILETYPESFORJOB where FILETYPE like '%HK%';
--DATAFILES
delete from DATAFILES where FILEID in (select FILEID from (select a.FILEID, a.FILENAME, a.CREATEDATE, a.PROCESSDATE, a.FILETYPE, b.STATUS, b.statusdate FROM DATAFILES a, FILE_STATUS b where b.STATUSID = a.STATUSID and FILENAME like '%HK%' and b.statusdate between '$Start_Date' and '$End_Date' order by b.statusdate));
--FILE_STATUS
delete from FILE_STATUS where FILEID in (select FILEID from (select b.FILEID, a.FILENAME, a.CREATEDATE, a.PROCESSDATE, a.FILETYPE, b.STATUS, b.statusdate FROM DATAFILES a, FILE_STATUS b where b.STATUSID = a.STATUSID and FILENAME like '%HK%' and b.statusdate between '$Start_Date' and '$End_Date' order by b.statusdate));
--FMGR_ADMIN.JOBFILEIDMAPPER
delete from from FMGR_ADMIN.JOBFILEIDMAPPER where CREATIONDATE between '$Start_Date' and '$End_Date';


commit;
spool out

exit;
EOF


