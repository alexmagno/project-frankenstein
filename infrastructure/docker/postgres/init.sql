-- Create shared database for all microservices
CREATE DATABASE frankenstein_shared;
CREATE DATABASE sonarqube;

-- Create users for each service (for security and auditing)
CREATE USER user_service_user WITH ENCRYPTED PASSWORD 'userservice123';
CREATE USER product_service_user WITH ENCRYPTED PASSWORD 'productservice123';
CREATE USER order_service_user WITH ENCRYPTED PASSWORD 'orderservice123';

-- Grant privileges on shared database
GRANT ALL PRIVILEGES ON DATABASE frankenstein_shared TO user_service_user;
GRANT ALL PRIVILEGES ON DATABASE frankenstein_shared TO product_service_user;  
GRANT ALL PRIVILEGES ON DATABASE frankenstein_shared TO order_service_user;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO frankenstein;

-- Connect to shared database and create extensions
\c frankenstein_shared;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization

-- Create schemas for each service domain (logical separation)
CREATE SCHEMA IF NOT EXISTS user_domain;
CREATE SCHEMA IF NOT EXISTS product_domain;
CREATE SCHEMA IF NOT EXISTS order_domain;
CREATE SCHEMA IF NOT EXISTS shared_domain; -- For cross-domain entities

-- Grant schema permissions
GRANT ALL ON SCHEMA user_domain TO user_service_user;
GRANT USAGE ON SCHEMA user_domain TO product_service_user, order_service_user;

GRANT ALL ON SCHEMA product_domain TO product_service_user;
GRANT USAGE ON SCHEMA product_domain TO user_service_user, order_service_user;

GRANT ALL ON SCHEMA order_domain TO order_service_user;
GRANT USAGE ON SCHEMA order_domain TO user_service_user, product_service_user;

GRANT ALL ON SCHEMA shared_domain TO user_service_user, product_service_user, order_service_user;
