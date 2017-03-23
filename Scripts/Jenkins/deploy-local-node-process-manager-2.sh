cd $WORKSPACE

echo "==================================================================="
echo " DEPLOYMENT ENV STAGING"
echo "==================================================================="

APP_NAME=<app name>
DB_NAME=<db-name>
STRONG_PM_HOST=http://<pm url>
STRONG_PM_PORT=8701
STRONG_PM_CONTAINER_ID=$(docker ps -qf "name=strong-pm-container")

echo "==================================================================="
echo " INITIAL SETUP - DOCKER - CONTAINERS"
echo "==================================================================="

start_db() {
	echo -e "\nStarting MariaDB database...\n"
    docker run --name $DB_NAME -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=namedb -p 3306:3306 -d mariadb:latest
    sleep 10
    echo -e "\nMariaDB database was started.\n"
}

if [ $STRONG_PM_CONTAINER_ID ]; then
	echo -e "\n\nStrongloop PM docker id: $STRONG_PM_CONTAINER_ID\n\n"
    
    if [ $DELETE_THS_DATABASE == "TRUE" ]; then
		echo -e "\n\nDelete THS database...\n"
        DATABASE_CONTAINER_ID=$(docker ps -qf "name=$DB_NAME")
        docker stop $DATABASE_CONTAINER_ID
        docker rm $DATABASE_CONTAINER_ID
        start_db
	fi
else
	echo -e "\n\nCleanup docker containers.\n"
    docker rm $(docker ps -a -q)
    start_db
    echo -e "\n\nStarting Strongloop PM...\n"
    docker run -d --restart=no -p 8701:8701 -p 3000:3000 -p 80:3001 \
    --link ths-admin-db:db --name strong-pm-container strongloop/strong-pm
    sleep 10
    STRONG_PM_CONTAINER_ID=$(docker ps -qf "name=strong-pm-container")
    echo -e "\nStrongloop PM was started.\n"
fi

if ! docker exec $STRONG_PM_CONTAINER_ID slpmctl status $APP_NAME &> /dev/null;
then
	echo -e "\n\nCreating application $APP_NAME on PM...\n"
    sleep 10
    docker exec $STRONG_PM_CONTAINER_ID slpmctl create $APP_NAME
    docker exec $STRONG_PM_CONTAINER_ID slpmctl env-set $APP_NAME \
    PORT=3001 NODE_ENV=production THS_DB_HOST=db
    echo -e "\n\n$APP_NAME application was created.\n"
fi

echo "==================================================================="
echo " REMOVING PACKAGE ../*.tgz"
echo "==================================================================="
rm -f ../$APP_NAME.*.tgz

echo "==================================================================="
echo " PROCESS MANAGER - STATUS"
echo "==================================================================="
docker exec $STRONG_PM_CONTAINER_ID slpmctl status

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
slc deploy $STRONG_PM_HOST:$STRONG_PM_PORT

echo "==================================================================="
echo " PROCESS MANAGER STATUS - [application]"
echo "==================================================================="
docker exec $STRONG_PM_CONTAINER_ID slpmctl status $APP_NAME
