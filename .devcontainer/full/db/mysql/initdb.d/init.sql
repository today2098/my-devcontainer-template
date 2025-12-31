-- @conn root

GRANT SELECT ON `%`.* TO 'devuser' @'%';

GRANT ALL PRIVILEGES ON testdb.* TO 'devuser' @'%';

CREATE DATABASE IF NOT EXISTS testdb;