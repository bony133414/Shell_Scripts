#! /bin/bash

if [ $# == 1 ]
then
  echo "Performing purging activity in $1 environment .."
  ENV=`echo $1| tr '[:lower:]' '[:upper:]'`
  if [ $ENV == "DEV" ]
  then
          PCARD=/opt/pwrcard/DEV
          Tape_10Y=/opt/DEV/data/rtsp/shell/longtermstorage_folder_10Y
      Tape_2Y=/opt/DEV/data/rtsp/shell/longtermstorage_folder_2Y
  elif [ $ENV == "ST" ]
  then
           PCARD=/opt/pwrcard/
           Tape_10Y=/opt/ST/data/rtsp/shell/longtermstorage_folder_10Y
           Tape_2Y=/opt/ST/data/rtsp/shell/longtermstorage_folder_2Y
		   Tape_1Y=/opt/ST/data/rtsp/shell/longtermstorage_folder_1Y
  elif [ $ENV == "SIT" ]
  then
          PCARD=/opt/pwrcard/
  elif [ $ENV == "UAT" ]
  then
          PCARD=/opt/pwrcard/UAT/
  elif [ $ENV == "MOPS" ]
  then
          PCARD=/opt/pwrcard/PS/
  elif [ $ENV == "PROD" ]
  then
      PCARD=/opt/pwrcard/PROD
          exit 1
  else
      echo "Trying in some other environment... need to modify the script..."
          exit 1
  fi
else
  echo "Parameter need to be passed to the script : $0 <env name> "
  exit 1
fi


source $PCARD/.pcard_profile

echo "log folder : /opt/ST/Rpt_Logs"

execution_date=$(date +%Y%m%d)

LOGFILE_DIR="/opt/ST/Rpt_Logs"
LOGFILE_NAME="${LOGFILE_DIR}/Archiving_HK_MO_DATA_$execution_date.log"
touch $LOGFILE_NAME

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME

#CurrentDate=$(date "+%b %_d")


##Archive directory for the back up of input/output files before purging
Archive_Dir="/opt/ST/test1/Data_Files_Archive"
echo "$Archive_Dir"

if [ -d $Archive_Dir ]
then
  echo -e "\n"
else
  mkdir $Archive_Dir
fi

RPT_PATH=/home/jboss/ArchivedNpciReports

fun () {
    echo "Checking files under : $1"
        cd $RPT_PATH
        FileStatus=`find . -type f -name $1*`
        echo "no of file to be archived is $FileCount"
    if [ "$FileCount" != 0 ] && [ "$2" == "NA" ]
        then
                        files=`find $RPT_PATH/ -type f -name '*$1*' | rev | cut -d '/' -s -f1 | rev`
                        Dir=`echo $1 | rev | cut -d '/' -s -f1,2,3 | rev`
                        mkdir -p $Archive_Dir/$Dir
                        echo "Archiving Directory : $Archive_Dir/$Dir"
                        cd $1
                        echo "files inside $1 older than $2 : $files"
                        cp -p $files $Archive_Dir/$Dir
    elif [ "$FileCount" != 0 ] && [ "$2" != "NA" ]
        then
            files=`find $RPT_PATH/ -type f -name '*$1*' | rev | cut -d '/' -s -f1 | rev`
                                if [ "$3" == "10Y" || "$2" == "EC" ]
                                then
                                        cp -p $files $Tape_10Y
                                        echo " ########### List of Files : $files ###########"
                                        echo " Movedoved to : $Tape_10Y"
                                elif [ "$2" == "2Y" ]
                                then
                                        cp -p $files $Tape_2Y
                                        echo " ########### List of Files : $files ###########"
                                        echo " Movedoved to : $Tape_10Y"
								elif [ "$2" == "1Y" ]
                                then
                                        cp -p $files $Tape_1Y
                                        echo " ########### List of Files : $files ###########"
                                        echo " Movedoved to : $Tape_10Y"
                                fi
        fi
}

linesToSkip=2
{
    for ((i=$linesToSkip;i--;)) ;do
         read
    done
    while read -a line ;do
                 Record_ID=`echo -e "${line[0]}"`
                 Tape_Retention=`echo -e "${line[1]}"`               
                 fun $path $Online_Retention $Tape_Retention
        done
} < MyReports.cfg

exit 0