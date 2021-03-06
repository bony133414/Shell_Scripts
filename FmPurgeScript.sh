#! /bin/bash

if [ $# == 1 ]
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
  echo "Parameter need to be passed to the script : $0 <env name>"
  exit 1
fi

source $PCARD/.pcard_profile

#HK Input Directories
indir1=$LANDING_ZONE/inbound/HKI13
indir2=$LANDING_ZONE/inbound/HKI14
indir3=$INBOUND_DATA_HOME/HKI13
indir4=$INBOUND_DATA_HOME/HKI14
indir5=$DATA_ROOT/rtsp/shell/error/inbound/HKI14
indir6=$DATA_ROOT/rtsp/shell/error/inbound/HKI13
indir7=$INBOUND_ARCHIVE_HOME/hk/HKI14
indir8=$INBOUND_ARCHIVE_HOME/hk/HKI13

#HK Output Directories
outdir1=$OUTBOUND_DATA_HOME/HKO08
outdir2=$OUTBOUND_DATA_HOME/HKO26
outdir3=$OUTBOUND_DATA_HOME/HKO25
outdir4=$OUTBOUND_DATA_HOME/HKO02
outdir5=$OUTBOUND_DATA_HOME/HKO10
outdir6=$OUTBOUND_DATA_HOME/HKO28
outdir7=$OUTBOUND_DATA_HOME/HKO23

#MO Outbound
mooutdir1=$OUTBOUND_DATA_HOME/MOO08
mooutdir2=$OUTBOUND_DATA_HOME/MOO26
mooutdir3=$OUTBOUND_DATA_HOME/MOO01
mooutdir4=$OUTBOUND_DATA_HOME/MOO28
mooutdir5=$OUTBOUND_DATA_HOME/MOO23
mooutdir6=$OUTBOUND_DATA_HOME/MOO25

LOGFILE_DIR="$WRAPPER_LOGS"
LOGFILE_NAME="${LOGFILE_DIR}/Archiving_HK_MO_DATA.log"
touch $LOGFILE_NAME

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME

CurrentDate=$(date "+%b %_d")

##Archive directory for the back up of input/output files before purging
Archive_Dir="$WRAPPER_LOGS/HK_MO_Files"
echo "$Archive_Dir"

if [ -d $Archive_Dir ]
then
  echo -e "\n"
else
  mkdir $Archive_Dir
fi


##Common function for archiving and purging activity
fun () {
    echo "$1"
    #arr_Filenames=($1/*.*)
    #FileCount=${#arr_Filenames[@]}
	FileCount=`find $1/ -type f -ls | grep "$CurrentDate" | awk '{print $11}' | wc -l`
	echo "no of file to be archived is $FileCount"
    if [ $FileCount != 0 ]
	then
		#for flname in "${arr_Filenames[@]}"; do
		files=`find $1/ -type f -ls | grep "$CurrentDate" | awk '{print $11}' | rev | cut -d '/' -s -f1 | rev`
		cd $1
		cp -p $files $Archive_Dir
		#files=`find ./ -type f -ls |grep "$CurrentDate" | awk '{print $11}' | cut -c 3-`
		#files=`find $1/ -type f -ls | grep "$CurrentDate" | awk '{print $11}' | rev | cut -d '/' -s -f1 | rev`
		#shred -u $files
		#done
	fi
}

declare -a hkiarr=("$indir1" "$indir2" "$indir3" "$indir4" "$indir5" "$indir6" "$indir7" "$indir8")
declare -a hkoarr=("$outdir1" "$outdir2" "$outdir3" "$outdir4" "$outdir5" "$outdir6" "$outdir7")
declare -a mooarr=("$mooutdir1" "$mooutdir2" "$mooutdir3" "$mooutdir4" "$mooutdir5" "$mooutdir6")
for i in "${hkiarr[@]}"
do
   echo "$i"
   if [ -d "$i" ]
	 then
		 echo "Directory $i exists"
		 if [ "$(ls -A $i)" ]; then
		 echo "Take action $i is not Empty"
		 fun $i	 
	 else
		 echo "$i is Empty"
	 fi
   else
     echo "No $i Directory available"
fi
done

for i in "${hkoarr[@]}"
do
   echo "$i"
   if [ -d "$i" ]
	 then
		 echo "Directory $i exists"
		 if [ "$(ls -A $i)" ]; then
		 echo "Take action $i is not Empty"
		 fun $i	 
	 else
		 echo "$i is Empty"
	 fi
   else
     echo "No $i Directory available"
fi
done

for i in "${mooarr[@]}"
do
   echo "$i"
   if [ -d "$i" ]
	 then
		 echo "Directory $i exists"
		 if [ "$(ls -A $i)" ]; then
		 echo "Take action $i is not Empty"
		 fun $i	 
	 else
		 echo "$i is Empty"
	 fi
   else
     echo "No $i Directory available"
fi
done

#Purging activity for FM tables

cd $WRAPPER_LOGS
sqlplus -S $ORA_USER/$ORA_PASS > /dev/null 2>&1 << EOF
set head off;
spool on;
spool purging_fm_ables.txt

--select statements for below tables
--JOBS Table
select * from JOBS where JOBNAME like '%MO%' and REQUESTDATE like '%20-MAY-17%';
select * from JOBS where JOBNAME like '%HK%' and REQUESTDATE like '%20-MAY-17%';
--JOB_STATUS Table
select * from JOB_STATUS where JOBID in (select JOBID from (select a.JOBID, a.JOBNAME, a.REQUESTDATE, a.PROCESSDATE, b.STATUS, b.statusdate FROM JOBS a, JOB_STATUS b where a.STATUSID = b.STATUSID and a.JOBNAME like '%MO%' and a.REQUESTDATE like '%20-MAY-17%' order by a.REQUESTDATE desc));
select * from JOB_STATUS where JOBID in (select JOBID from (select a.JOBID, a.JOBNAME, a.REQUESTDATE, a.PROCESSDATE, b.STATUS, b.statusdate FROM JOBS a, JOB_STATUS b where a.STATUSID = b.STATUSID and a.JOBNAME like '%HK%' and a.REQUESTDATE like '%20-MAY-17%' order by a.REQUESTDATE desc));
--FILETYPESFORJOB
select * from FILETYPESFORJOB where FILETYPE like '%MO%' union select * from FILETYPESFORJOB where FILETYPE like '%HK%';
select * from FILETYPESFORJOB where FILETYPE like '%MO%' union select * from FILETYPESFORJOB where FILETYPE like '%MO%';
--DATAFILES
select * from DATAFILES where FILEID in (select FILEID from (select a.FILEID, a.FILENAME, a.CREATEDATE, a.PROCESSDATE, a.FILETYPE, b.STATUS, b.statusdate FROM DATAFILES a, FILE_STATUS b where b.STATUSID = a.STATUSID and FILENAME like '%HK%' order by b.statusdate));
--FILE_STATUS
select * from FILE_STATUS where FILEID in (select FILEID from (select b.FILEID, a.FILENAME, a.CREATEDATE, a.PROCESSDATE, a.FILETYPE, b.STATUS, b.statusdate FROM DATAFILES a, FILE_STATUS b where b.STATUSID = a.STATUSID and FILENAME like '%HK%' order by b.statusdate));

spool out

exit;
EOF

