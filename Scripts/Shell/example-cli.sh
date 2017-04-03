#!/bin/sh
#===============================================================================
#
#          FILE:  app-cli.sh
#
#         USAGE:  ./app-cli.sh [options] [services]
#
#   DESCRIPTION:  App environment client to manage services and data containers.
#
#       OPTIONS:  -h, --help            show help
#                 -d, --delete          delete all containers including data container
#                 -u, --update          update all containers except data container
#  REQUIREMENTS:  Docker Engine and Docker Compose installed.
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Paulo Lobato <paulo.lobatojr@hotmail.com>
#       COMPANY:  ---
#       VERSION:  1.1
#      REVISION:  ---
#===============================================================================

usage () {
    echo "./app-cli.sh - App environment client"
    echo " "
    echo "./app-cli.sh [options] [services]"
    echo " "
    echo "options:"
    echo "-h, --help            show help"
    echo "-d, --delete          delete all containers including data container"
    echo "-u, --update          update all containers except data container"
    echo " "
    echo "services:"
    echo "<empty>               App services + App Analytics services"
    echo "app                   App services"
    echo "analytics             App Analytics services"
}

stopContainer () {
    if [ "$1" = "--no-data" ]; then
        # Stop all containers that have a `appenv_` prefix except data containers
        docker ps | grep appenv | grep -v 'db\|elasticsearch' | cut -d ' ' -f 1 | xargs docker stop
    else
        # Stop all containers that have a `appenv_` prefix
        docker stop $(docker ps -q -f name=appenv_*)
    fi
}

deleteContainer () {
    if [ "$1" = "--no-data" ]; then
        # Delete all containers that have a `appenv_` prefix except data containers
        docker ps -a | grep appenv | grep -v 'db\|elasticsearch' | cut -d ' ' -f 1 | xargs docker rm
    else
        # Delete all containers that have a `appenv_` prefix
        docker rm $(docker ps -aq -f name=appenv_*)
    fi
}

deleteContainerImage () {
    # Delete all images that have a `appenv_` prefix
    docker rmi $(docker images -q appenv_*)
}

deployAppServices () {
    # Install Magento container
    docker-compose -f docker-compose.magento.yml run --rm magentosetup

    docker-compose -f docker-compose.magento.yml up -d magentoapp

    # Deploy App proxy container
    docker-compose -f docker-compose.common.yml up -d

    # Deploy App Admin container
    docker-compose -f docker-compose.admin.yml up -d webadmin

    # Deploy Totem container
    if [ "$SERVICE_TOTEM_UP" = true ]; then
        docker-compose -f docker-compose.totem.yml up -d
    fi

    # Deploy App Web Store and Service Store container
    docker-compose -f docker-compose.store.yml up -d webstore
}

deployAppAnalyticsServices () {
    # Deploy App proxy container
    docker-compose -f docker-compose.common.yml up -d

    # Deploy ELK containers
    if [ "$SERVICE_ELK_KIBANA_UP" = true ]; then
        docker-compose -f docker-compose.elk.yml up -d
    else
        docker-compose -f docker-compose.elk.yml up -d kafka-rest elasticsearch logstash pentaho
    fi
}

validateAppEnv () {
    # Check if the environment variables exists
    if [ $SERVICE_STORE_HOSTNAME ] && [ $SERVICE_MAGENTO_HOSTNAME ] &&
    [ $SERVICE_ADMIN_HOSTNAME ] && [ $SERVICE_STORE_WEB_HOSTNAME ]; then
        return 0
    else
        return 1
    fi
}

validateAppAnalyticsEnv () {
    # Check if the environment variables exists
    if [ $SERVICE_ELK_ELASTICSEARCH_HOSTNAME ] && [ $SERVICE_ELK_KIBANA_HOSTNAME ] &&
    [ $SERVICE_ELK_LOGSTASH_HOSTNAME ] && [ $SERVICE_ELK_PENTAHO_DB_HOSTNAME ]; then
        return 0
    else
        return 1
    fi
}

main () {
    while test $# -gt 0; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --delete)
                shift
                if validateAppEnv || validateAppAnalyticsEnv; then
                    stopContainer
                    deleteContainer
                    deleteContainerImage
                else
                    echo 'Error: If App services set SERVICE_STORE_HOSTNAME, SERVICE_ADMIN_HOSTNAME, SERVICE_STORE_WEB_HOSTNAME, SERVICE_MAGENTO_HOSTNAME. Also Analytics services SERVICE_ELK_ELASTICSEARCH_HOSTNAME, SERVICE_ELK_KIBANA_HOSTNAME, SERVICE_ELK_LOGSTASH_HOSTNAME and SERVICE_ELK_PENTAHO_DB_HOSTNAME environment variables.'
                    exit 1
                fi
                break
                ;;
            --update)
                shift
                if validateAppEnv || validateAppAnalyticsEnv; then
                    stopContainer --no-data
                    deleteContainer --no-data
                    deleteContainerImage
                else
                    echo 'Error: If App services set SERVICE_STORE_HOSTNAME, SERVICE_ADMIN_HOSTNAME, SERVICE_STORE_WEB_HOSTNAME, SERVICE_MAGENTO_HOSTNAME. Also Analytics services SERVICE_ELK_ELASTICSEARCH_HOSTNAME, SERVICE_ELK_KIBANA_HOSTNAME, SERVICE_ELK_LOGSTASH_HOSTNAME and SERVICE_ELK_PENTAHO_DB_HOSTNAME environment variables.'
                    exit 1
                fi
                break
                ;;
            *)
                echo "./app-cli: '$1' is not a valid option."
                echo "See './app-cli --help'."
                exit 1
                break
                ;;
        esac
    done

    if [ $# -eq 0 ] ; then
        if validateAppEnv && validateAppAnalyticsEnv; then
            deployAppAnalyticsServices
            deployAppServices
        else
            echo 'Error: Set SERVICE_STORE_HOSTNAME, SERVICE_ADMIN_HOSTNAME, SERVICE_STORE_WEB_HOSTNAME, SERVICE_MAGENTO_HOSTNAME, SERVICE_ELK_ELASTICSEARCH_HOSTNAME, SERVICE_ELK_KIBANA_HOSTNAME, SERVICE_ELK_LOGSTASH_HOSTNAME and SERVICE_ELK_PENTAHO_DB_HOSTNAME environment variables.'
            exit 1
        fi
    else
        while test $# -gt 0; do
            case "$1" in
                app)
                    shift
                    if validateAppEnv; then
                        deployAppServices
                        echo "App"
                    else
                        echo 'Error: Set SERVICE_STORE_HOSTNAME, SERVICE_ADMIN_HOSTNAME, SERVICE_STORE_WEB_HOSTNAME and SERVICE_MAGENTO_HOSTNAME environment variables.'
                        exit 1
                    fi
                    ;;
                analytics)
                    shift
                    if validateAppAnalyticsEnv; then
                        deployAppAnalyticsServices
                    else
                        echo 'Error: Set SERVICE_ELK_ELASTICSEARCH_HOSTNAME, SERVICE_ELK_KIBANA_HOSTNAME and SERVICE_ELK_LOGSTASH_HOSTNAME environment variables.'
                        exit 1
                    fi
                    ;;
                *)
                    echo "'$1' is not a valid service."
                    shift
                    ;;
            esac
        done
    fi
}

if [ $# -eq 0 ] ; then
    main --help
    exit 0
fi

main $@

