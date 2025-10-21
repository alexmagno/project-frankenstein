-- Infrastructure Database for SonarQube and Unleash  
CREATE DATABASE sonarqube;
CREATE DATABASE unleash;

-- Create users (using environment variables)
CREATE USER sonarqube_user WITH ENCRYPTED PASSWORD :'SONARQUBE_JDBC_PASSWORD';
CREATE USER unleash_user WITH ENCRYPTED PASSWORD :'UNLEASH_JDBC_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube_user;
GRANT ALL PRIVILEGES ON DATABASE unleash TO unleash_user;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO postgres;
GRANT ALL PRIVILEGES ON DATABASE unleash TO postgres;
