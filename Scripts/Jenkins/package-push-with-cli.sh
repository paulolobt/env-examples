cd $WORKSPACE

RELEASE_DIR=<jenkins path>/release/ths-release-prod-$BUILD_NUMBER

mkdir -p $RELEASE_DIR

zip -r ths-release-prod-v$BUILD_NUMBER.zip *

cp ths-release-prod-v$BUILD_NUMBER.zip $RELEASE_DIR

cd $RELEASE_DIR

AWS_ELASTICBEANSTALK_ADDRESS=<elasticbeanstalk url external>
AWS_EC2_ADDRESS=<ec2 external url>
AWS_EC2_ADDRESS_ANALYTICS=<ec2 external url>
AWS_EC2_INTERNAL_IP=<internal ip>
AWS_EC2_INTERNAL_IP_ANALYTICS=<internal ip>
AWS_EC2_CREDENTIAL=<.pem>
AWS_EC2_PATH=<internal path>

# THS ANALYTICS
THSAnalytics () {
    ssh -i $AWS_EC2_CREDENTIAL jenkins@$AWS_EC2_ADDRESS_ANALYTICS "cd $AWS_EC2_PATH;"\
    "if [ "$DELETE_DATABASE" == "true" ]; then docker stop \$(docker ps -q -f name=thsenv_*); else "\
    "docker ps | grep thsenv | grep -v 'db\|elasticsearch' | cut -d ' ' -f 1 | xargs docker stop; fi; rm -rf *"
    
    scp -i $AWS_EC2_CREDENTIAL ths-release-prod-v$BUILD_NUMBER.zip \
        jenkins@$AWS_EC2_ADDRESS_ANALYTICS:$AWS_EC2_PATH
        
    ssh -i $AWS_EC2_CREDENTIAL jenkins@$AWS_EC2_ADDRESS_ANALYTICS "cd $AWS_EC2_PATH;"\
    "unzip ths-release-prod-v$BUILD_NUMBER.zip;"\
    "export SERVICE_STORE_AWS_HOSTNAME=store.$AWS_ELASTICBEANSTALK_ADDRESS;"\
    "export SERVICE_ELK_USE_SAMPLE_DATA=true;"\
    "export SERVICE_TOTEM_UP=false;"\
    "export SERVICE_ELK_KIBANA_UP=true;"\
    "export NODE_ENV=production;"\
    "export ENVIRONMENT=production;"\
    "cd ths-env;"\
    "if [ "$DELETE_DATABASE" == "true" ]; then ./ths-cli.sh --delete analytics; else ./ths-cli.sh --update analytics; fi"
}

# THS SERVICES
THSServices () {
    ssh -i $AWS_EC2_CREDENTIAL jenkins@$AWS_EC2_ADDRESS "cd $AWS_EC2_PATH;"\
    "if [ "$DELETE_DATABASE" == "true" ]; then docker stop \$(docker ps -q -f name=thsenv_*); else "\
    "docker ps | grep thsenv | grep -v 'db\|elasticsearch' | cut -d ' ' -f 1 | xargs docker stop; fi; rm -rf *"
    
    scp -i $AWS_EC2_CREDENTIAL ths-release-prod-v$BUILD_NUMBER.zip \
        jenkins@$AWS_EC2_ADDRESS:$AWS_EC2_PATH
        
    ssh -i $AWS_EC2_CREDENTIAL jenkins@$AWS_EC2_ADDRESS "cd $AWS_EC2_PATH;"\
    "unzip ths-release-prod-v$BUILD_NUMBER.zip;"\
    "export SERVICE_ELK_USE_SAMPLE_DATA=true;"\
    "export SERVICE_TOTEM_UP=false;"\
    "export SERVICE_ELK_KIBANA_UP=false;"\
    "export NODE_ENV=production;"\
    "export ENVIRONMENT=production;"\
    "cd ths-env;"\
    "if [ "$DELETE_DATABASE" == "true" ]; then ./ths-cli.sh --delete ths; else ./ths-cli.sh --update ths; fi"
}

if [ "$SERVICE_UP" = "ALL" ]; then
	echo "THS services + THS analytics"
    THSAnalytics
    THSServices
elif [ "$SERVICE_UP" = "THS" ]; then
	echo "Only THS services"
    THSServices
elif [ "$SERVICE_UP" = "ANALYTICS" ]; then
	echo "Only THS analytics"
    THSAnalytics
fi
