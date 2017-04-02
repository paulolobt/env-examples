cd $WORKSPACE

RELEASE_DIR=/opt/jenkins/release/app-release-$BUILD_NUMBER

mkdir -p $RELEASE_DIR

cp -R .[a-zA-Z0-9]* * $RELEASE_DIR

cd $RELEASE_DIR

# export S3 fake hostname env variable
export AWS_S3_ENDPOINT=localhost:4569

# Deploy app services
if [ "$DELETE_DATABASE" = "true" ]; then
    # Stop all containers that have a `project_app*` prefix
    docker stop $(docker ps -q -f name=project_app*) || true
    
    # Delete all containers that have a `project_app*` prefix
    docker rm $(docker ps -aq -f name=project_app*) || true
else
    # Stop all containers that have a `project_app*` prefix except data containers
    docker ps | grep project_app | grep -v 'data' | cut -d ' ' -f 1 | xargs docker stop || true
    
    # Delete all containers that have a `project_app*` prefix except data containers
    docker ps -a | grep project_app | grep -v 'data' | cut -d ' ' -f 1 | xargs docker rm || true
fi

# Delete all images that have a `project_app*` prefix
docker rmi $(docker images -q project_app*) || true

# Remove all dangling volumes
docker volume rm `docker volume ls -q -f dangling=true` || true

# Run all app services
/usr/local/bin/docker-compose up -d app
