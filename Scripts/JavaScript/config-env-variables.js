require('dotenv').config({path: __dirname + '/.env'});

var config = {};
config.service = {};
config.service.cerbervs = {};
config.service.cerbervs.db = {};
config.service.cerbervs.db.database = process.env.SERVICE_CERBERVS_DB_DATABASE;
config.service.cerbervs.db.hostname = process.env.SERVICE_CERBERVS_DB_HOSTNAME;
config.service.cerbervs.db.password = process.env.SERVICE_CERBERVS_DB_PASSWORD;
config.service.cerbervs.db.port = process.env.SERVICE_CERBERVS_DB_PORT;
config.service.cerbervs.db.username = process.env.SERVICE_CERBERVS_DB_USERNAME;

module.exports = config;
