-- Create databases for each microservice
CREATE DATABASE user_service;
CREATE DATABASE product_service;
CREATE DATABASE order_service;
CREATE DATABASE sonarqube;

-- Create users for each service (optional, for better security)
CREATE USER user_service_user WITH ENCRYPTED PASSWORD 'userservice123';
CREATE USER product_service_user WITH ENCRYPTED PASSWORD 'productservice123';
CREATE USER order_service_user WITH ENCRYPTED PASSWORD 'orderservice123';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE user_service TO user_service_user;
GRANT ALL PRIVILEGES ON DATABASE product_service TO product_service_user;
GRANT ALL PRIVILEGES ON DATABASE order_service TO order_service_user;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO frankenstein;

-- Connect to each database and create extensions if needed
\c user_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c product_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c order_service;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
