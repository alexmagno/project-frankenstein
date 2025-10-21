-- User Service Database Initialization
CREATE DATABASE user_service_db;

-- Create user service user (using environment variables)
CREATE USER user_service WITH ENCRYPTED PASSWORD :'USER_SERVICE_DATASOURCE_PASSWORD';
CREATE USER user_saga_coordinator WITH ENCRYPTED PASSWORD :'USER_SAGA_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE user_service_db TO user_service;
GRANT ALL PRIVILEGES ON DATABASE user_service_db TO user_saga_coordinator;

-- Connect to user service database
\c user_service_db;

-- Create extensions
-- Note: uuidv7() is natively available in PostgreSQL 18+
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS user_domain;
CREATE SCHEMA IF NOT EXISTS saga_coordination;
CREATE SCHEMA IF NOT EXISTS event_store;

-- User domain tables will be created by Flyway
-- SAGA coordination tables
CREATE TABLE saga_coordination.user_saga_state (
    saga_id UUID PRIMARY KEY DEFAULT uuidv7(),
    saga_type VARCHAR(100) NOT NULL,
    business_transaction_id UUID NOT NULL,
    current_step INTEGER NOT NULL DEFAULT 1,
    total_steps INTEGER NOT NULL,
    saga_data JSONB NOT NULL,
    compensation_data JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'started',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event store for user service
CREATE TABLE event_store.user_events (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_version INTEGER NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB DEFAULT '{}',
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Grant permissions
GRANT ALL ON SCHEMA user_domain TO user_service;
GRANT ALL ON SCHEMA saga_coordination TO user_service, user_saga_coordinator;
GRANT ALL ON SCHEMA event_store TO user_service;

GRANT ALL ON ALL TABLES IN SCHEMA saga_coordination TO user_service, user_saga_coordinator;
GRANT ALL ON ALL TABLES IN SCHEMA event_store TO user_service;
