cd $WORKSPACE

export PATH=/usr/local/bin:$PATH

echo "==================================================================="
echo " DEPLOYMENT ENV TEST"
echo "==================================================================="

#echo "=================================================================="
#echo " STOPPING STRONG ARC"
#echo "==================================================================="
#kill -9 `ps -ef | grep 'slc arc' | grep -v grep | awk '{print $2}'`

echo "==================================================================="
echo " REMOVING PACKAGE ../*.tgz"
echo "==================================================================="
rm -f ../application.*.tgz

#echo "==================================================================="
#echo " UNDEPLOYING APPLICATION - [application]"
#echo "==================================================================="
#slc ctl remove application 2>/dev/null | exit 0

echo "==================================================================="
echo " PROCESS MANAGER - STATUS"
echo "==================================================================="
slc ctl status application

echo "==================================================================="
echo " DELETE DATABASE - [applicationdb]"
echo "==================================================================="
mysql -u application -papplication123 -e "drop database if exists applicationdb;" 2>/dev/null
  
echo "==================================================================="
echo " CREATE DATABASE - [applicationdb]"
echo "==================================================================="
mysql -u application -papplication123 -e "create database applicationdb;" 2>/dev/null


echo "==================================================================="
echo " INSTALLING NODE DEPENDENCIES"
echo "==================================================================="
npm install

echo "==================================================================="
echo " PACKING APPLICATION - [application-x.x.x.TGZ]"
echo "==================================================================="
slc build -p

echo "==================================================================="
echo " DEPLOYING APPLICATION  - [application]"
echo "==================================================================="
slc deploy http://localhost:8701

echo "==================================================================="
echo " SET ENVIRONMENT VARIABLES: [application] HOST: localhost PORT:3001"
echo "==================================================================="
slc ctl env-set application PORT=3001 NODE_ENV=staging DB_HOSTNAME=localhost DB_PORT=3306 DB_USERNAME=application DB_PASSWORD=application123 DB_DATABASE=applicationdb

echo "==================================================================="
echo " RESTARTING APPLICATION  - [application]"
echo "==================================================================="
slc ctl restart application

echo "==================================================================="
echo " PROCESS MANAGER STATUS - [application]"
echo "==================================================================="
slc ctl status application

#echo "==================================================================="
#echo " RUN INTEGRATION TESTS - [application]"
#echo "==================================================================="
#sleep 10
#export TEST_PORT=3001
#npm test

#echo "==================================================================="
#echo " STARTING STRONG ARC - HOST: localhost PORT:5000"
#echo "==================================================================="
#PORT=5000 slc arc &>/dev/null &
#exit 0
