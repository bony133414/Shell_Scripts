#! /bin/bash

if [ $# == 1 ]
then
  echo "Generate Reports for : $1"
else
  echo "Parameter need to be passed to the script : $0 <OU> "
  exit 1
fi

OU=$1

#source /opt/pwrcard/UAT/.pcard_profile
source /opt/pwrcard/STAGE/.pcard_profile

RUN_TIME=`date +"%Y%m%d%H%M%S"`
LOGFILE_DIR="/opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/logs"
LOGFILE_NAME="${LOGFILE_DIR}/ID_240_xxx_Trigger_$RUN_TIME.log"
touch $LOGFILE_NAME


## Redirecting STDOUT and STDERR to LOGFILE_NAME ##

exec 2>>$LOGFILE_NAME
exec 1>>$LOGFILE_NAME

CreditQry_Output=`sqlplus -S zz4m4t/oracle123<<EOF
set head off;
SET PAGESIZE 40000;
@/opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_CreditQry_04DEC17.sql;
/
exit
EOF`

echo "CreditQry Output without sed : $CreditQry_Output"

CreditQ=`echo $CreditQry_Output | sed '/^$/d'`
echo "CreditQry Output with sed : $CreditQ"

DebitQry_Output=`sqlplus -S zz4m4t/oracle123<<EOF
set head off;
SET PAGESIZE 40000;
@/opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_DebitQry_04DEC17.sql;
/
exit
EOF`

DebitQ=`echo $DebitQry_Output | sed '/^$/d'`
echo "DebitQry Output with sed : $DebitQ"

#echo "Query output is : $Sql_OutPut"

Debit_fun() {
echo "Inside Function : $1"
cd /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/
perl -i -pe 's|'"${2}"'|'"${1}"'|g' ID240_xxx_Debit.xml
echo "##################"
cat ID240_xxx_Debit.xml
echo -e "##################\n"
#cp /opt/pwrcard/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Debit.xml /data/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcessPci/ 
cp /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Debit.xml /opt/jboss/STAGE/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcess/
sleep 5
echo "File copied for : $1"
echo "After edit reverting the cange inside the file"
perl -i -pe 's|'"${1}"'|'"${2}"'|g' ID240_xxx_Debit.xml
}

Credit_fun() {
echo "Inside Function : $1"
cd /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/
perl -i -pe 's|'"${2}"'|'"${1}"'|g' ID240_xxx_Credit.xml
echo "##################"
cat ID240_xxx_Credit.xml
echo -e "##################\n"
#cp /opt/pwrcard/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Credit.xml /data/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcessPci/
cp /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Credit.xml /opt/jboss/STAGE/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcess/
sleep 5
echo "File copied for : $1"
echo "After edit reverting the cange inside the file"
perl -i -pe 's|'"${1}"'|'"${2}"'|g' ID240_xxx_Credit.xml
}

echo "Printing inside while loop"
while read -r line
do
	merchant_id=`echo -e "${line[0]}"`
	count=`echo -n $merchant_id | wc -c`
	if [ "$merchant_id" != null ] && [ $count == 65	 ]
	then
	    Credit_fun $OU$merchant_id SERIAL_NO
    elif [ "$merchant_id" == "no rows selected" ]
    then 
		echo "No rows has been selected from Credit query.. Hence triggering the reports with empty data for ${OU}.."
		perl -i -pe 's|'"SERIAL_NO"'|'"${OU}"'|g' ID240_xxx_Credit.xml
		echo "##################"
		cat ID240_xxx_Credit.xml
		echo "\n##################"
		#cp /opt/pwrcard/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Credit.xml /data/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcessPci/ 
		cp /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Credit.xml /opt/jboss/STAGE/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcess/
		perl -i -pe 's|'"${OU}"'|'"SERIAL_NO"'|g' ID240_xxx_Credit.xml
    else
	    echo "Merchant id is incorrect : $merchant_id"
    fi
done <<< "$CreditQry_Output"


echo "Printing inside while loop"
while read -r line
do
	merchant_id=`echo -e "${line[0]}"`
	count=`echo -n $merchant_id | wc -c`
	if [ "$merchant_id" != null ] && [ $count == 65	 ]
	then
	    Debit_fun $OU$merchant_id SERIAL_NO
	elif [ "$merchant_id" == "no rows selected" ]
    then 
		echo "No rows has been selected from Debit query.. Hence triggering the reports with empty data for ${OU}.."
		cd /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/
		perl -i -pe 's|'"SERIAL_NO"'|'"${OU}"'|g' ID240_xxx_Debit.xml
		echo "##################"
		cat ID240_xxx_Debit.xml
		echo "\n##################"
		#cp /opt/pwrcard/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Debit.xml /data/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcessPci/ 
		cp /opt/pwrcard/STAGE/rtsp/shell/in_scripts/Myreports-ID240/ID240_xxx_Debit.xml /opt/jboss/STAGE/jasperreports-server-cp-6.1.0-bin/camel/inbound/myreportsProcess/
		perl -i -pe 's|'"${OU}"'|'"SERIAL_NO"'|g' ID240_xxx_Debit.xml
    else
	    echo "Merchant id is incorrect : $merchant_id"
    fi
done <<< "$DebitQry_Output"
