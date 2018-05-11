#! /bin/bash

if [ $# == 4 ]
then
  echo "Performing purging activity in $1 environment .."
  ENV=`echo $1| tr '[:lower:]' '[:upper:]'`
  if [ $ENV == "SIT" ]
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
  echo "Parameter need to be passed to the script : $0 <env name> <OU> <Start date : yyyy-mm-dd> <End date : yyyy-mm-dd>"
  exit 1
fi

OU=`echo $2| tr '[:lower:]' '[:upper:]'`

source $PCARD/.pcard_profile

#Loading the environment variables declared inside DATAFILE_PATHS_CL3 file
source DATAFILE_PATHS_CL3

execution_date=$(date +%Y%m%d%H%M%S)
StartDate=$3
EndDate=$4

LOGFILE_DIR="$WRAPPER_LOGS"
LOGFILE_NAME="${LOGFILE_DIR}/Purging_${OU}_DATA_FILE_$execution_date.log"
touch $LOGFILE_NAME

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME


##Common function  purging activity
fun () {
    echo "Checking files under path : $1"
    #arr_Filenames=($1/*.*)
    #FileCount=${#arr_Filenames[@]}
	FileCount=`find $1/ -type f -newermt "$StartDate" ! -newermt "$EndDate" | wc -l`
	echo "no of file to be purged with in the date range $StartDate to $EndDate is $FileCount"
    if [ $FileCount != 0 ]
	then
		#for flname in "${arr_Filenames[@]}"; do
		files=`find $1/ -type f -newermt "$StartDate" ! -newermt "$EndDate" | rev | cut -d '/' -s -f1 | rev`
		#files=`find ./ -type f -ls |grep "$CurrentDate" | awk '{print $11}' | cut -c 3-`
		#files=`find $1/ -type f -ls | grep "$CurrentDate" | awk '{print $11}' | rev | cut -d '/' -s -f1 | rev`
		cd $1
		shred -uf $files
		#done
	fi
}

declare -a caoutdir=("$caoutdir1" "$caoutdir2" "$caoutdir3" "$caoutdir4" "$caoutdir5" "$caoutdir6" "$caoutdir7" "$caoutdir8" "$caoutdir9" "$caoutdir10" "$caoutdir11" "$caoutdir12" "$caoutdir13" "$caoutdir14" "$caoutdir15" "$caoutdir16" "$caoutdir17")
declare -a cainarchdir=("$cainarchdir1" "$cainarchdir2" "$cainarchdir3" "$cainarchdir4" "$cainarchdir5" "$cainarchdir6" "$cainarchdir7" "$cainarchdir8" "$cainarchdir9")
declare -a caoutarchdir=("$caoutarchdir1" "$caoutarchdir2" "$caoutarchdir3" "$caoutarchdir4" "$caoutarchdir5" "$caoutarchdir6" "$caoutarchdir7" "$caoutarchdir8" "$caoutarchdir9"  "$caoutarchdir10" "$caoutarchdir11" "$caoutarchdir12" "$caoutarchdir13" "$caoutarchdir14" "$caoutarchdir15" "$caoutarchdir16" "$caoutarchdir17")

#Array of all ca folders
declare -a caarr=("${caoutdir[@]}" "${cainarchdir[@]}" "${caoutarchdir[@]}")

declare -a hkoutdir=("$hkoutdir1" "$hkoutdir2" "$hkoutdir3" "$hkoutdir4" "$hkoutdir5" "$hkoutdir6" "$hkoutdir7")
declare -a hkinarchdir=("$hkinarchdir1" "$hkinarchdir2")
declare -a hkoutarchdir=("$hkoutarchdir1" "$hkoutarchdir2" "$hkoutarchdir3" "$hkoutarchdir4" "$hkoutarchdir5" "$hkoutarchdir6" "$hkoutarchdir7")

#Array of all hk folders
declare -a hkarr=("${hkoutdir[@]}" "${hkinarchdir[@]}" "${hkoutarchdir[@]}")


declare -a mooutdir=("$mooutdir1" "$mooutdir2" "$mooutdir3" "$mooutdir4" "$mooutdir5" "$mooutdir6")
declare -a mooutarchdir=("$mooutarchdir1" "$mooutarchdir2" "$mooutarchdir3" "$mooutarchdir4" "$mooutarchdir5" "$mooutarchdir6" "$mooutarchdir7")

#Array of all mo folders
declare -a moarr=("${mooutdir[@]}" "${mooutarchdir[@]}")

#Array of all gl folders
declare -a glarr=("$glinarchdir1" "$glinarchdir2" "$glinarchdir3" "$glinarchdir4")

#Array of all my folders
declare -a my1inarchdir=("$my1inarchdir1" "$my1inarchdir2" "$my1inarchdir3")
declare -a my1outdir=("$my1outdir1" "$my1outdir2" "$my1outdir3" "$my1outdir4" "$my1outdir5" "$my1outdir6" "$my1outdir7" "$my1outdir8" "$my1outdir9" "$my1outdir10")
declare -a my1outarchdir=("$my1outarchdir1" "$my1outarchdir2" "$my1outarchdir3" "$my1outarchdir4" "$my1outarchdir5" "$my1outarchdir6" "$my1outarchdir7" "$my1outarchdir8" "$my1outarchdir9" "$my1outarchdir10")
declare -a my2outdir=("$my2outdir1" "$my2outdir2" "$my2outdir3" "$my2outdir4" "$my2outdir5" "$my2outdir6")
declare -a my2outarchdir=("$my2outarchdir1" "$my2outarchdir2" "$my2outarchdir3" "$my2outarchdir4" "$my2outarchdir5" "$my2outarchdir6")

declare -a myarr=("${my1inarchdir[@]}" "${my1outdir[@]}" "${my1outarchdir[@]}" "${my2outdir[@]}" "${my2outarchdir[@]}")

#Array of all sg folders
declare -a sginarchdir=("$sginarchdir1" "$sginarchdir2" "$sginarchdir3" "$sginarchdir4" "$sginarchdir5" "$sginarchdir6" "$sginarchdir7")
declare -a sgoutarchdir=("$sgoutarchdir1" "$sgoutarchdir2" "$sgoutarchdir3" "$sgoutarchdir4" "$sgoutarchdir5" "$sgoutarchdir6" "$sgoutarchdir7" "$sgoutarchdir8" "$sgoutarchdir9")
declare -a sgoutdir=("$sgoutdir1" "$sgoutdir2" "$sgoutdir3" "$sgoutdir4" "$sgoutdir5" "$sgoutdir6" "$sgoutdir7" "$sgoutdir8" "$sgoutdir9")

declare -a sgarr=("${sginarchdir[@]}" "${sgoutarchdir[@]}" "${sgoutdir[@]}")

#Array of all th folders
declare -a thinarchdir=("$thinarchdir1")
declare -a thoutdir=("$thoutdir1" "$thoutdir2" "$thoutdir3" "$thoutdir4" "$thoutdir5" "$thoutdir6")
declare -a thoutarchdir=("$thoutarchdir1" "$thoutarchdir2" "$thoutarchdir3" "$thoutarchdir4" "$thoutarchdir5" "$thoutarchdir6")

declare -a tharr=("${thinarchdir[@]}" "${thoutdir[@]}" "${thoutarchdir[@]}")

#Array of all ph folders
declare -a phoutdir=("$phoutdir1" "$phoutdir2" "$phoutdir3" "$phoutdir4" "$phoutdir5" "$phoutdir6" "$phoutdir7")
declare -a phoutarchdir=("$phoutarchdir1" "$phoutarchdir2" "$phoutarchdir3" "$phoutarchdir4" "$phoutarchdir5" "$phoutarchdir6" "$phoutarchdir7")

declare -a pharr=("${phoutdir[@]}" "${phoutarchdir[@]}")

#Array of all pk folders
declare -a pkoutdir=("$pkoutdir1" "$pkoutdir2" "$pkoutdir3" "$pkoutdir4" "$pkoutdir5" "$pkoutdir6" "$pkoutdir7" "$pkoutdir8" "$pkoutdir9")
declare -a pkoutarchdir=("$pkoutarchdir1" "$pkoutarchdir2" "$pkoutarchdir3" "$pkoutarchdir4" "$pkoutarchdir5" "$pkoutarchdir6" "$pkoutarchdir7" "$pkoutarchdir8" "$pkoutarchdir9")

declare -a pkarr=("${pkoutdir[@]}" "${pkoutarchdir[@]}")


if [ "$OU" == "CA" ]; then
	for i in "${caarr[@]}"
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
elif [ "$OU" == "HK" ]; then
    for i in "${hkarr[@]}"
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
elif [ "$OU" == "MO" ]; then
    for i in "${moarr[@]}"
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
elif [ "$OU" == "GL" ]; then
    for i in "${glarr[@]}"
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
elif [ "$OU" == "MY" ]; then
    for i in "${myarr[@]}"
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
elif [ "$OU" == "SG" ]; then
    for i in "${sgarr[@]}"
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
elif [ "$OU" == "TH" ]; then
    for i in "${tharr[@]}"
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
elif [ "$OU" == "PH" ]; then
    for i in "${pharr[@]}"
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
elif [ "$OU" == "PK" ]; then
    for i in "${pkarr[@]}"
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
fi

echo "File Archiving has been completed successfully!!"
exit 0