require('dotenv').config({path: __dirname + '/.env'});

var config = {};
config.service = {};
config.service.app = {};
config.service.app.db = {};
config.service.app.db.database = process.env.SERVICE_DB_DATABASE;
config.service.app.db.hostname = process.env.SERVICE_DB_HOSTNAME;
config.service.app.db.password = process.env.SERVICE_DB_PASSWORD;
config.service.app.db.port = process.env.SERVICE_DB_PORT;
config.service.app.db.username = process.env.SERVICE_DB_USERNAME;

module.exports = config;
