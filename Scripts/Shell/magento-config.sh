#!/bin/sh
echo "Initializing Magento setup..."

MAGENTO_ROOT="/srv/www"
MAGENTO_COMMAND="/usr/local/bin/php -d memory_limit=2G ./bin/magento"

cd $MAGENTO_ROOT

if [ -f ./app/etc/config.php ] || [ -f ./app/etc/env.php ]; then
  echo "It appears Magento is already installed (app/etc/config.php or app/etc/env.php exist). Exiting setup..."
  exit
fi

echo "Download and extract Magento archive..."

MAGENTO_ARCHIVE_URL="http://$M2SETUP_ARCHIVE_HOSTNAME:$M2SETUP_ARCHIVE_PORT"

# Verify if the local package service is running
if ! curl -I -m 5 $MAGENTO_ARCHIVE_URL; then
  MAGENTO_ARCHIVE_URL=https://s3-us-west-2.amazonaws.com/<bucket>
fi

# Download the specific Magento package and extract
if [ "$M2SETUP_USE_SAMPLE_DATA" = true ]; then
  curl -L $MAGENTO_ARCHIVE_URL/magento-ths-v1.tar.gz | tar xzf - -o -C .
else
  curl -L http://pubfiles.nexcess.net/magento/ce-packages/magento2-$M2SETUP_VERSION.tar.gz | tar xzf - -o -C .
fi

chmod +x ./bin/magento

if [ "$M2SETUP_USE_SAMPLE_DATA" = true ]; then
  M2SETUP_USE_SAMPLE_DATA_STRING="--use-sample-data"
else
  M2SETUP_USE_SAMPLE_DATA_STRING=""
fi

echo "Waiting for database connection..."
sleep 50

echo "Running Magento 2 setup script..."
$MAGENTO_COMMAND setup:install \
  --db-host=$M2SETUP_DB_HOST \
  --db-name=$M2SETUP_DB_NAME \
  --db-user=$M2SETUP_DB_USER \
  --db-password=$M2SETUP_DB_PASSWORD \
  --admin-firstname=$M2SETUP_ADMIN_FIRSTNAME \
  --admin-lastname=$M2SETUP_ADMIN_LASTNAME \
  --admin-email=$M2SETUP_ADMIN_EMAIL \
  --admin-user=$M2SETUP_ADMIN_USER \
  --admin-password=$M2SETUP_ADMIN_PASSWORD \
  --backend-frontname=$M2SETUP_ADMIN_PATH \
  $M2SETUP_USE_SAMPLE_DATA_STRING

echo "Deploy static Magento 2 content..."
$MAGENTO_COMMAND setup:static-content:deploy

echo "Flush all cache data..."
$MAGENTO_COMMAND cache:flush

echo "Reindex all indexes..."
$MAGENTO_COMMAND indexer:reindex

echo "The setup script has completed execution."
