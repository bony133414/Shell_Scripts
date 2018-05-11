#! /bin/bash

if [ $# == 1 ]
then
  echo "Performing purging activity in $1 environment .."
  ENV=`echo $1| tr '[:lower:]' '[:upper:]'`
  if [ $ENV == "DEV" ]
  then
	  PCARD=/opt/pwrcard/DEV
	  Tape_10Y=/opt/pwrcard/DEV/data/rtsp/shell/longtermstorage_folder_10Y
      Tape_2Y=/opt/pwrcard/DEV/data/rtsp/shell/longtermstorage_folder_2Y
  elif [ $ENV == "ST" ]
  then
	  PCARD=/opt/pwrcard/
	  Tape_10Y=/opt/pwrcard/ST/data/rtsp/shell/longtermstorage_folder_10Y
	  Tape_2Y=/opt/pwrcard/ST/data/rtsp/shell/longtermstorage_folder_2Y
  elif [ $ENV == "SIT" ]
  then
	  PCARD=/opt/pwrcard/
	  Tape_10Y=/opt/pwrcard/SIT/data/rtsp/shell/longtermstorage_folder_10Y
	  Tape_2Y=/opt/pwrcard/SIT/data/rtsp/shell/longtermstorage_folder_2Y
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

echo "log folder : $WRAPPER_LOGS"

execution_date=$(date +%Y%m%d)

LOGFILE_DIR="$WRAPPER_LOGS"
LOGFILE_NAME="${LOGFILE_DIR}/Archiving_HK_MO_DATA_$execution_date.log"
touch $LOGFILE_NAME

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME

#CurrentDate=$(date "+%b %_d")


##Archive directory for the back up of input/output files before purging
Archive_Dir="$WRAPPER_LOGS/Data_Files_Archive"
echo "$Archive_Dir"

if [ -d $Archive_Dir ]
then
  echo -e "\n"
else
  mkdir $Archive_Dir
fi


fun () {
    echo "Checking files under : $1"
	echo "Arguments to the function : $1 $2 $3"
        cd $1
        FileCount=`find $1/ -type f -mtime $2 | wc -l`
        echo "############### no of file to be archived under $1 is $FileCount ##############"
    if [ "$FileCount" != 0 ] && [ "$3" == "NA" ]
        then
			files=`find $1/ -type f -mtime $2 | rev | cut -d '/' -s -f1 | rev`
			Dir=`echo $1 | rev | cut -d '/' -s -f1,2,3 | rev`
			mkdir -p $Archive_Dir/$Dir
			echo "Archiving Directory : $Archive_Dir/$Dir"
			cd $1
			#echo "files inside $1 older than $2 : $files"
			cp -p $files $Archive_Dir/$Dir
			#files=`find ./ -type f -ls |grep "$CurrentDate" | awk '{print $11}' | cut -c 3-`
			#files=`find $1/ -type f -ls | grep "$CurrentDate" | awk '{print $11}' | rev | cut -d '/' -s -f1 | rev`
			#shred -u $files
			#done
    elif [ "$FileCount" != 0 ] && [ "$3" != "NA" ]
        then
            files=`find $1/ -type f -mtime $2 | rev | cut -d '/' -s -f1 | rev`
			Dir=`echo $1 | rev | cut -d '/' -s -f1,2,3 | rev`
			if [ "$3" == "10Y" ]
			then
					cp -p $files $Tape_10Y/$Dir
					#echo " ########### List of Files : $files ###########"
					echo " Movedoved to : $Tape_10Y"
			elif [ "$3" == "2Y" ]
			then
					cp -p $files $Tape_10Y/$Dir
					#echo " ########### List of Files : $files ###########"
					echo " Movedoved to : $Tape_10Y"
			fi
        fi
}

while read -a line ;do
		 FileType=`echo ${line}|awk -F '|' '{ print $1 }'`
		 Record_ID=`echo ${line}|awk -F '|' '{ print $2 }'`
		 Folder_Path=`echo ${line}|awk -F '|' '{ print $3 }'`
		 Online_Retention=`echo ${line}|awk -F '|' '{ print $4 }'`
		 Tape_Retention=`echo ${line}|awk -F '|' '{ print $5 }'`
		 echo "Record_ID : $Record_ID || Folder_Path : $Folder_Path || Online_Retention : $Online_Retention || Tape_Retention : $Tape_Retention"
		 if [ "$FileType" == "inbound" ]
		 then
				 path="$INBOUND_ARCHIVE_HOME""$Folder_Path"
		 elif [ "$FileType" == "outbound" ]
		 then
				 path="$OUTBOUND_ARCHIVE_HOME""$Folder_Path"
		 fi
		 fun $path $Online_Retention $Tape_Retention
done < <(tail -n +2 DataFile.cfg)


exit 0