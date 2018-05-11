#! /bin/bash

if [ $# == 3 ]
then
  echo "Performing purging activity in $1 environment .."
  ENV=`echo $1| tr '[:lower:]' '[:upper:]'`
  if [ $ENV == "SIT" ]
  then 
	  PCARD=/opt/pwrcard
	  OutPut_Location=/opt/jboss/HkMooutput
  elif [ $ENV == "UAT" ]
  then
      PCARD=/opt/pwrcard/UAT
  else
      echo "Trying in some other environment... need to modify the script..."
	  exit 1
  fi
else
  echo "Parameter need to be passed to the script : $0 <env name> <Start date : yyyy-mm-dd> <End date : yyyy-mm-dd>"
  exit 1
fi

source $PCARD/.pcard_profile

#OutPut data directory
outdir1=$OUTBOUND_DATA_HOME/MOO05
outdir2=$OUTBOUND_DATA_HOME/HKO08
outdir3=$OUTBOUND_DATA_HOME/HKO10
outdir4=$OUTBOUND_DATA_HOME/HKO02
outdir5=$OUTBOUND_DATA_HOME/MOO01

StartDate=$2
EndDate=$3

LOGFILE_DIR="$WRAPPER_LOGS"
LOGFILE_NAME="${LOGFILE_DIR}/HK_MO_MyReports_Datafiles.log"
touch $LOGFILE_NAME

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME

##Common function for archiving and purging activity
fun () {
    echo "Folder path is : $1"
	FolderName=`echo $1 | rev | cut -d '/' -s -f1 | rev`
	if [ "$FolderName" == "MOO05" ]
	then
	   FileCount=`find $1/GSAP_I_MO_SBCI183_MOC*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	   echo "no of file to be populated in PCI MyReports is $FileCount"
	   if [ $FileCount != 0 ]
	   then
	        arr_Filenames=`find $1/GSAP_I_MO_SBCI183_MOC*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		    cd $1
			echo "File names : $arr_Filenames"
			mv $arr_Filenames $OutPut_Location
	   fi
	 elif [ "$FolderName" == "HKO08" ]
	 then
	   FileCount=`find $1/GSAP_I_HK_SBCI183_HKC*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	   echo "no of file to be populated in PCI MyReports is $FileCount"
	   if [ $FileCount != 0 ]
	   then
	       arr_Filenames=`find $1/GSAP_I_HK_SBCI183_HKC*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		   cd $1
			echo "File names : $arr_Filenames"
			mv $arr_Filenames $OutPut_Location
	   fi
    elif [ "$FolderName" == "HKO10" ]
	 then
	   FileCount=`find $1/RPYH.BCP.UPLOAD.SHELL.NFCS*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	   echo "no of file to be populated in PCI MyReports is $FileCount"
	   if [ $FileCount != 0 ]
	   then
	       arr_Filenames=`find $1/RPYH.BCP.UPLOAD.SHELL.NFCS*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		   cd $1
			echo "File names : $arr_Filenames"
			mv $arr_Filenames $OutPut_Location
	   fi 
    elif [ "$FolderName" == "HKO02" ]
	 then
	   FileCount=`find $1/A01.HK.A40*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	   echo "no of file to be populated in PCI MyReports is $FileCount"
	   if [ $FileCount != 0 ]
	   then
	       arr_Filenames=`find $1/A01.HK.A40*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		   cd $1
			echo "File names : $arr_Filenames"
			mv $arr_Filenames $OutPut_Location
	   fi 
    elif [ "$FolderName" == "MOO01" ]
	 then
	   FileCount=`find $1/A01.MO.A40*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	   echo "no of file to be populated in PCI MyReports is $FileCount"
	   if [ $FileCount != 0 ]
	   then
	       arr_Filenames=`find $1/A01.MO.A40*.* -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		   cd $1
			echo "File names : $arr_Filenames"
			mv $arr_Filenames $OutPut_Location
	   fi 
    else
        echo "Folder doesn't exists !!!"
    fi		
}

declare -a hkoarr=("$outdir1" "$outdir2" "$outdir3" "$outdir4" "$outdir5")

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
