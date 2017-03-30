var config = require('../config/config');

module.exports = {
  mysql: {
    host:      config.service.db.hostname,
    port:      config.service.db.port,
    user:      config.service.db.username,
    password:  config.service.db.password,
    database:  config.service.db.database,
    connector: 'mysql'
  }
};
