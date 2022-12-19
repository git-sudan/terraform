#!/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
echo -e "${BOLD}${GREEN}*********************************************${NONE}"
echo -e "${BOLD}${GREEN}         AWS RDS WITH TERRAFORM              ${NONE}"
echo -e "${BOLD}${RED}****PLEASE GO THROUGH EVERY STEP CAREFULLY*****${NONE}"
echo -e "${BOLD}${GREEN}*********************************************${NONE}"
echo -e " "
echo -e "${BOLD}${GREEN}${UNDERLINE}PREREQUISITE:${NONE}"
echo -e " "
echo -e "${BOLD}${GREEN}Install Terraform version >= 0.12  (https://www.terraform.io/downloads.html)${NONE}"
echo -e "${BOLD}${GREEN}Clone the rdsterraform (git clone https://bitbucket.csgi.com/scm/db/rdsterraform.git${NONE}"
echo -e "${BOLD}${GREEN}AWS Programmatic Access Using SAML with MFA (https://confluence.csgicorp.com/display/AWS/AWS+Programmatic+Access+Using+SAML+with+MFA)${NONE}"
echo -e "${BOLD}${GREEN}terraform must be run while logged-in to adfs-cloudadministrators.${NONE}"
echo -e " "
echo -e "${BOLD}${WHITE}********************************************************************************************************************${NONE}"
echo -e "${BOLD}${WHITE}Terraform managed security group - csg-rds-standard-sg & subnet group - rds-terraformsubnetgroup is MANDATORY${NONE}"
echo -e "${BOLD}${WHITE}********************************************************************************************************************${NONE}"
echo -e " "
echo -e "${BOLD}${WHITE}ENSURE THERE IS NO SPACE BEFORE YOUR INPUTS${NONE}"
echo -e " "
echo -e "${BOLD}${RED}HIT ENTER TO CONTINUE OR CTRL+C TO CANCEL${NONE}"
read response
echo -e " "
echo -e "${BOLD}${RED}ENTER VPC NAME WHEN PROMPTED:${NONE}"
VPCSAMPLE=`cat ../conf_data/terraform.tfvars | grep VPCNAME | awk -F= '{print $2}'`
sleep 1
echo -e "${BOLD}${WHITE}VPC NAME FROM EXISTING INFRASTRUCTURE:${NONE}${GREEN}$VPCSAMPLE${NONE}"
echo -e "${BOLD}${RED}ENTER YOUR INPUT BELOW (WITHOUT DOUBLE QUOTES):${NONE}"
read VPCNAME
echo "VPCNAME=\"$VPCNAME\"" > vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER VPC REGION WHEN PROMPTED:${NONE}"
REGIONSAMPLE=`cat ../conf_data/terraform.tfvars | grep REGION | awk -F= '{print $2}'`
sleep 1
echo -e "${BOLD}${WHITE}REGION FROM EXISTING INFRASTRUCTURE:${NONE}${GREEN}$REGIONSAMPLE${NONE}"
echo -e "${BOLD}${RED}ENTER YOUR INPUT BELOW (WITHOUT DOUBLE QUOTES):${NONE}"
read REGION
echo "REGION=\"$REGION\"" >> vars.log
echo -e " "
echo -e "${BOLD}${GREEN}ENTER S3 BUCKET NAME FROM $REGION:${NONE}"
read SSSBUCKET
echo -e " "
echo -e "${BOLD}${RED}ENTER THE AVAILABILITY ZONE WHERE YOU WANT DB INSTANCE TO BE HOSTED ${NONE}"
echo -e "${BOLD}${GREEN}AVAILABLE AZS ON TERRAFORM INFRASTRUCTURE${NONE}"
cat ../conf_data/infrastructure_azs.txt
echo -e "${BOLD}${GREEN}ENTER YOUR INPUT BELOW${NONE}"
read AVAILABILITYZONE
echo "AVAILABILITYZONE=\"$AVAILABILITYZONE\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER APPLICATION NAME IN SHORT & HIT ENTER${NONE}"
echo -e "${BOLD}${GREEN}eg. wfx for workforce express${NONE}"
read APPNAME
echo "APPNAME=\"$APPNAME\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER CLIENT NAME IN SHORT & HIT ENTER${NONE}"
echo -e "${BOLD}${GREEN}eg. chr or chtr for charter${NONE}"
read CLIENTNAME
echo "CLIENTNAME=\"$CLIENTNAME\"" >> vars.log
echo -e " "
echo -e "${BOLD}${GREEN}RDBMS: postgres${NONE}"
ENGINE="postgres"
echo "ENGINE=\"$ENGINE\"" >> vars.log
echo -e " "
if [ "$ENGINE" == "oracle-ee" -o "$ENGINE" == "oracle-se" -o "$ENGINE" == "oracle-se1" -o "$ENGINE" == "oracle-se2" ]  ; then
export DB="orcl"
LICENSE=bring-your-own-license
echo "LICENSE=\"$LICENSE\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER $ENGINE VERSION BELOW AND HIT ENTER${NONE}"
echo -e "${BOLD}${GREEN}CHECK VERSIONS.XLSX FOR VARIOUS RDBMS VERSIONS${NONE}"
echo -e "${BOLD}${GREEN}Eg. oracle : 12.1.0.2.v8 | 18.0.0.0.ru-2020-04.rur-2020-04.r1 | 19.0.00.ru-2020-04.rur-2020-04.r1${NONE}"
read ENGINEVERSION
echo "ENGINEVERSION=\"$ENGINEVERSION\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER CHARECTER-SET FOR $ENGINE ${NONE}"
echo -e "Check https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.OracleCharacterSets.html${NONE}"
echo -e "${BOLD}${GREEN}Eg. AL32UTF8 | WE8ISO8859P15 | US7ASCII | UTF8 ${NONE}"
read CSET
echo "CHARECTERSET=\"$CSET\"" >> vars.log
echo -e "${BOLD}${GREEN}${NONE}"
elif [ "$ENGINE" == "sqlserver-ex" -o "$ENGINE" == "sqlserver-se" -o "$ENGINE" == "sqlserver-we" -o "$ENGINE" == "sqlserver-ee" ]; then
export DB="sqls"
LICENSE=licence-included
echo "LICENSE=\"$LICENSE\"" >> vars.log
echo -e "${BOLD}${RED}ENTER $ENGINE VERSION BELOW AND HIT ENTER${NONE}"
echo -e "${BOLD}${GREEN}CHECK VERSIONS.XLSX FOR VARIOUS RDBMS VERSIONS${NONE}"
echo -e "${BOLD}${GREEN}sql-server : 13.00.5598.27.v1 | 14.00.3281.6.v1  ${NONE}"
read ENGINEVERSION
echo "ENGINEVERSION=\"$ENGINEVERSION\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER CHARECTERSET COLLATION FOR $ENGINE ${NONE}"
echo -e "${BOLD}${GREEN}Check https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.SQLServer.CommonDBATasks.Collation.html${NONE}"
echo -e "${BOLD}${GREEN}Eg. SQL_Latin1_General_CP1_CI_AS | SQL_Latin1_General_CP1_CI_AI  ${NONE}"
read CSET
echo "CHARECTERSET=\"$CSET\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER TIMEZONE FOR THE RDS INSTANCE $ENGINE ${NONE}"
echo -e "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.TimeZone${NONE}"
echo -e "${BOLD}${GREEN}Eg. Central Standard Time | Eastern Standard Time ${NONE}"
read TIMEZONE
echo "TIMEZONE=\"$TIMEZONE\"" >> vars.log
elif [ "$ENGINE" == "postgres" ]; then
  DB="pg"
  echo -e "${BOLD}${RED}ENTER $ENGINE VERSION BELOW AND HIT ENTER${NONE}"
  echo -e "${BOLD}${GREEN}postgres: 10.13 | 11.8 | 12.3 ${NONE}"
  read ENGINEVERSION
  echo "ENGINEVERSION=\"$ENGINEVERSION\"" >> vars.log
  LICENSE=postgresql-license
  echo "LICENSE=\"$LICENSE\"" >> vars.log
else
echo -e "${BOLD}${GREEN}ENTER RIGHT RDBMS EDITION ${NONE}"
exit 2;
fi
echo -e " "
echo -e "${BOLD}${GREEN}YOU HAVE CHOSEN:${WHITE}$ENGINE${NONE}"
echo -e " "
echo -e "${BOLD}${WHITE}LICENSING MODEL FOR $ENGINE $ENGINEVERSION IS: ${GREEN} $LICENSE ${NONE}"
echo -e " "
echo -e "${BOLD}${RED}NATURE OF ENVIRONMENT${NONE}"
echo -e "${BOLD}${GREEN}qa|dev|test|prod${NONE}"
read ENVIRONMENT
echo "ENVIRONMENT=\"$ENVIRONMENT\"" >> vars.log
echo -e " "
export $ENVIRONMENT
#echo -e "${BOLD}${RED}ENTER A TEMPORARYNAME FOR THE RDS INSTANCE${NONE}"
#echo -e "${BOLD}${GREEN}eg.wfx|wfxchtrprod|wfxqa ${NONE}"
#read TEMPUNIQUEID
#echo "UNIQUEID=\"$UNIQUEID\"" >> vars.log
echo -e "${BOLD}${GREEN}ENTER A NAME FOR THE RDS INSTANCE${NONE}"
echo -e "${BOLD}${RED}YOU CAN CHOOSE FROM BELOW OR ENTER ONE OF YOUR OWN IN BELOW FORMAT${NONE}|${WHITE}MAKE SURE IT IS UNIQUE & ORDERED${NONE}"
seq -f "${APPNAME}${CLIENTNAME}${ENVIRONMENT}%04g" 6
echo -e " "
echo -e "${BOLD}${GREEN}MENTION BELOW:${NONE}"
read DBNAME
echo "DBNAME=\"$DBNAME\"" >> vars.log
export VARF="$DB-$DBNAME"
cd SERVICES
mkdir -p $ENVIRONMENT/$VARF
chmod 755 *
cd ..
cp ../RDS-INFRA-DETAILS/data.tf SERVICES/$ENVIRONMENT/$VARF/
cp ../RDS-INFRA-DETAILS/provider.tf SERVICES/$ENVIRONMENT/$VARF/
cp ../RDS-INFRA-DETAILS/versions.tf SERVICES/$ENVIRONMENT/$VARF/
cp ../RDS-INFRA-DETAILS/remotebackend.tf SERVICES/$ENVIRONMENT/$VARF/
sed -i "s/swaps3/${SSSBUCKET}/g" SERVICES/${ENVIRONMENT}/${VARF}/remotebackend.tf
sed -i "s/swapkey/${VARF}.terraform.tfstate/g" SERVICES/${ENVIRONMENT}/${VARF}/remotebackend.tf
sed -i "s/swapregion/${REGION}/g" SERVICES/${ENVIRONMENT}/${VARF}/remotebackend.tf
echo -e "${BOLD}${GREEN}DB UNIQUE NAME:$VARF${NONE}"
echo "UNIQUEID=\"${DB}-${DBNAME}\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}INSTANCE CLASS${NONE}"
echo -e "${BOLD}${GREEN}eg db.t2.micro db.t3.small${NONE}"
read INSTANCECLASS
echo "INSTANCECLASS=\"$INSTANCECLASS\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER STORAGE TYPE BELOW (WITHOUT SPACE)${NONE}"
echo -e "${BOLD}${GREEN}gp2 | io1${NONE}"
read STORAGETYPE
echo -e " "
echo "STORAGETYPE=\"$STORAGETYPE\"" >> vars.log
if [ "$STORAGETYPE" == "io1" ]; then
  echo -e "${BOLD}${GREEN}ENTER MAX IOPS,MORE THAN 1000${NONE}"
  read IOPS
echo "IOPS=\"$IOPS\"" >> vars.log
elif [ "$STORAGETYPE" == "gp2" ]; then
echo -e "${BOLD}${WHITE}MARKED GP2 SSD AS STORAGE${NONE}"
#echo "IOPS=\"$IOPS\"" >> vars.log
else
echo "INVALID DATA"
exit 2;
fi
echo -e " "
echo -e "${BOLD}${RED}ENTER STORAGE TO BE ALLOCATED IN GB BELOW${NONE}"
echo -e "${BOLD}${GREEN}ENTER ONLY THE NUMBER${NONE}"
read ALLOCATEDSTORAGE
echo "ALLOCATEDSTORAGE=\"$ALLOCATEDSTORAGE\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENABLE STORAGE ENCRYPTION (YES/NO):${NONE}"
echo -e " "
echo -e "${BOLD}${RED}KINDLY NOTE BELOW INSTANCE CLASS ARE NOT AVAILABLE FOR STORAGE ENCRYPTION ${NONE}"
echo -e "${BOLD}${RED}General Purpose (M1)  : db.m1.small | db.m1.medium | db.m1.large | db.m1.xlarge${NONE}"
echo -e "${BOLD}${RED}Memory Optimized (M2) : db.m2.xlarge | db.m2.2xlarge | db.m2.4xlarge ${NONE}"
echo -e "${BOLD}${RED}Burst Capable (T2)    : db.t2.micro${NONE}"
#echo -e "${BOLD}${WHITE}if you are creating a cross-region read replica enter NO | KMS encryption needed in that case ${NONE}"
echo -e " "
echo -e "${BOLD}${RED}DO YOU WANT TO ENABLE STORAGE ENCRYPTION:${NONE}"
echo -e "${BOLD}${GREEN}ACCEPTED VALUES : YES | NO ${NONE}"
read STORAGEENCRYPTION
if [ "$STORAGEENCRYPTION" == "YES" -o "$STORAGEENCRYPTION" == "yes" ]  ; then
echo "STORAGEENCRYPTION=\"true\"" >> vars.log
elif [ "$STORAGEENCRYPTION" == "NO" -o "$STORAGEENCRYPTION" == "no" ]; then
echo "STORAGEENCRYPTION=\"false\"" >> vars.log
else
echo "INVALID DATA"
exit 2;
fi
echo -e " "
echo -e "${BOLD}${RED}ENTER DB ADMIN USER NAME${NONE}"
echo -e "${BOLD}${GREEN}PROVIDE A VALID NAME${NONE}"
read ADMINUSER
echo "ADMINUSER=\"$ADMINUSER\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}PASSWORD FOR DB ADMIN USER${NONE}"
echo -e "${BOLD}${GREEN}PROVIDE A STRONG PASSWORD${NONE}"
read ADMINPASSWORD
echo "ADMINPASSWORD=\"$ADMINPASSWORD\"" >> vars.log
echo -e " "
#echo -e "${BOLD}${RED}ENTER VPC NAME WHERE RDS INSTANCE WILL BE HOSTED BELOW ${NONE}"
#echo -e "${BOLD}${GREEN}VPC NAME MUST BE UNIQUE${NONE}"
#read VPCNAME
#echo "VPCNAME=\"$VPCNAME\"" >> vars.log
#echo -e " "
echo -e "${BOLD}${RED}DO YOU WANT TO ENABLE MULTIPLE AZ REPLICA:${NONE}"
echo -e "${BOLD}${GREEN}ACCEPTED VALUES : YES | NO ${NONE}"
read MULTIAZOP
if [ "$MULTIAZOP" == "YES" -o "$MULTIAZOP" == "yes" ]  ; then
echo "MULTIAZ=\"true\"" >> vars.log
elif [ "$MULTIAZOP" == "NO" -o "$MULTIAZOP" == "no" ]; then
echo "MULTIAZ=\"false\"" >> vars.log
else
echo "INVALID DATA"
exit 2;
fi
echo -e " "
echo -e "${BOLD}${RED}ENTER MAINTENANCE WINDOW (WITHOUT DOUBLE QUOTES)${NONE}"
echo -e "${BOLD}${GREEN}FORMAT: Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00 ${NONE}"
read MAINTENANCEWINDOW
echo "MAINTENANCEWINDOW=\"$MAINTENANCEWINDOW\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER BACKUP WINDOW(WITHOUT DOUBLE QUOTES)${NONE}"
echo -e "${BOLD}${GREEN}Eg: 03:00-06:00 | 21:00-22:00 ${NONE}"
read BACKUPWINDOW
echo "BACKUPWINDOW=\"$BACKUPWINDOW\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER BACKUP RETENTION PERIOD IN DAYS (ONLY NUMBER)${NONE}"
echo -e "${BOLD}${GREEN}Eg. 10 for 10 days retention${NONE}"
read BACKUPRETENTION
echo "BACKUPRETENTION=\"$BACKUPRETENTION\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER CSG PRODUCT CODE${NONE}"
echo -e "${BOLD}${GREEN}eg.0000 for Rundeck${NONE}"
read PRODUCTCODE
echo "PRODUCTCODE=\"$PRODUCTCODE\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER GAM FUNCTION${NONE}"
read GAMFUNCTION
echo "GAMFUNCTION=\"$GAMFUNCTION\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER GAM SERVICE LEVEL${NONE}"
read GAMSERVICELEVEL
echo "GAMSERVICELEVEL=\"$GAMSERVICELEVEL\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER YOUR REMEDY GROUP${NONE}"
echo -e "${BOLD}${GREEN}eg. DBA-ORACLE DBA-POSTGRES${NONE}"
read REMEDYGROUP
echo "REMEDYGROUP=\"$REMEDYGROUP\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER CUSTOMER NAME${NONE}"
echo -e "${BOLD}${GREEN}eg. CHARTER COMCAST CIT TIMEWARNER${NONE}"
read CUSTOMER
echo "CUSTOMER=\"$CUSTOMER\"" >> vars.log
echo -e " "
echo -e "${BOLD}${RED}ENTER GAM SECURITY CLASS${NONE}"
echo -e "${BOLD}${GREEN}Eg. A | B | C | D ${NONE}"
read SECURITYCLASS
echo "SECURITYCLASS=\"$SECURITYCLASS\"" >> vars.log
echo -e " "
#ADD IF CLAUSE HERE
#if [ -f terraform.tfvars ]; then
#DATE=`date +"%Y-%m-%d-%H-%M-%S"`
#echo -e "${BOLD}${GREEN}TAKING BACKUP OF CURRENT terraform.tfvars file ${NONE}"
#cp terraform.tfvars terraform.tfvars.$DATE
#fi
#echo -e " "
echo -e "${BOLD}${GREEN}TERRAFORM VARIABLE FILE SET to $VARF.tfvars on SERVICES/$ENVIRONMENT/$VARF directory ${NONE}"
cp vars.log SERVICES/$ENVIRONMENT/$VARF/$VARF.tfvars
echo -e " "
echo -e "${BOLD}${GREEN}VERIFY BELOW DATA${NONE}"
echo -e " "
cat SERVICES/$ENVIRONMENT/$VARF/$VARF.tfvars
echo -e " "
echo -e "${BOLD}${GREEN}********************************************************${NONE}"
echo -e "${BOLD}${GREEN}MOVING CONFIG FILES............${NONE}"
echo -e "${BOLD}${GREEN}********************************************************${NONE}"
echo -e " "
if [ "$ENGINE" == "oracle-ee" -o "$ENGINE" == "oracle-se" -o "$ENGINE" == "oracle-se1" -o "$ENGINE" == "oracle-se2" ]; then
  if [ "$STORAGETYPE" == "io1" ]; then
    cp ../conf_data/rdbms/oracle/io/rds_oracle_io.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
#mv rds_oracle_io.tf ${VARF}_conf.tf
  else
    cp ../conf_data/rdbms/oracle/rds_oracle.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
#    mv rds_oracle.tf $VARF_conf.tf
    fi
elif [ "$ENGINE" == "sqlserver-ex" -o "$ENGINE" == "sqlserver-se" -o "$ENGINE" == "sqlserver-we" -o "$ENGINE" == "sqlserver-ee" ]; then
  if [ "$STORAGETYPE" == "io1" ]; then
    cp ../conf_data/rdbms/mssql/io/rds_mssql_io.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
#    mv rds_mssql_io.tf $VARF_conf.tf
  else
    cp ../conf_data/rdbms/mssql/rds_mssql.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
#    mv rds_mssql.tf $VARF_conf.tf
    fi
elif [ "$ENGINE" == "postgres" ]; then
  if [ "$STORAGETYPE" == "io1" ]; then
    cp ../conf_data/rdbms/postgres/io/rds_postgres_io.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
#    mv rds_postgres_io.tf $VARF_conf.tf
  else
    cp ../conf_data/rdbms/postgres/rds_postgres.tf SERVICES/$ENVIRONMENT/$VARF/$VARF.tf
    sed -i "s/rdsswaptext/${VARF}/g" SERVICES/${ENVIRONMENT}/${VARF}/${VARF}.tf
    fi
else
echo -e "MAIN.TF & VARIABLE.TF NOT MOVED"
exit 2;
fi
echo -e " "
echo -e "${BOLD}${GREEN}BELOW ARE THE NON VARIABLE INPUTS IN CONFIGURATION FILE $VARF.tf| VERIFY ${NONE}"
cat SERVICES/$ENVIRONMENT/$VARF/$VARF.tf | grep -v var
echo -e " "
echo -e "${BOLD}${GREEN}********************************************************${NONE}"
echo -e "${BOLD}${WHITE}       ENTER YES TO CONTINUE CREATION OF DATABASE ${NONE}"
echo -e "${BOLD}${WHITE}                           (OR)                   ${NONE}"
echo -e "${BOLD}${WHITE} ENTER NO OR CTRL+C AND PERFORM BELOW STEPS AFTER VALIDATION:${NONE}"
echo -e "${BOLD}${GREEN}********************************************************${NONE}"
echo -e "${BOLD}${GREEN}cd SERVICES/$ENVIRONMENT/$VARF${NONE}"
echo -e "${BOLD}${GREEN}terraform init${NONE}"
echo -e "${BOLD}${GREEN}terraform plan -var-file=$VARF.tfvars ${NONE}"
echo -e "${BOLD}${GREEN}terraform apply -var-file=$VARF.tfvars${NONE}"
echo -e "${BOLD}${GREEN}********************************************************${NONE}"
echo -e " "
echo -e " "
echo -e "${BOLD}${GREEN}DO YOU WISH TO CONTINUE (YES/NO/CTRL+C)${NONE}"
read USERANS
if [ "$USERANS" == "YES" -o "$USERANS" == "yes" ]  ; then
echo -e " "
echo -e "${BOLD}${GREEN}RESPONSE : ${WHITE} $USERANS | PROCEEDING FURTHER STEPS${NONE}"
echo -e " "
elif [ "$USERANS" == "NO" -o "$USERANS" == "no" ]; then
echo -e "${BOLD}${GREEN}RESPONSE : $USERANS  | EXIT 2${NONE}"
else
echo -e " "
echo "EXIT"
exit 2;
fi
echo -e " "
cd SERVICES/$ENVIRONMENT/$VARF
if [ $? -eq 0 ]; then
echo -e "${BOLD}${GREEN}CONTINUING TO CREATE DB INSTANCE...........${NONE}"
echo -e " "
else
echo -e "${BOLD}${RED}ERROR DURING DIRECTORY CREATION | EXECUTION FAILED${NONE}"
exit 2;
fi
terraform init > init.log
if [ $? -eq 0 ]; then
echo -e "${BOLD}${GREEN}INITIALIZATION SUCCESS${NONE}"
echo -e " "
else
echo -e "${BOLD}${RED}INITIALIZATION FAILED ${NONE}"
cat init.log
exit 2;
fi
terraform plan -var-file=$VARF.tfvars > plan.log
if [ $? -eq 0 ]; then
echo -e "${BOLD}${GREEN}TAKEN PLAN FOR $VARF | SAVED AS plan.log ${NONE}"
echo -e " "
else
echo -e "${BOLD}${RED}FAILED DURING TERRAFORM PLAN | EXECUTION FAILED${NONE}"
cat
exit 2;
fi
terraform apply -auto-approve -var-file=$VARF.tfvars > build.log 
