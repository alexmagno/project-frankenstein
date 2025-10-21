-- Order Service Database Initialization
CREATE DATABASE order_service_db;

-- Create order service user (using environment variables)
CREATE USER order_service WITH ENCRYPTED PASSWORD :'ORDER_SERVICE_DATASOURCE_PASSWORD';
CREATE USER order_saga_coordinator WITH ENCRYPTED PASSWORD :'ORDER_SAGA_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE order_service_db TO order_service;
GRANT ALL PRIVILEGES ON DATABASE order_service_db TO order_saga_coordinator;

-- Connect to order service database
\c order_service_db;

-- Create extensions
-- Note: uuidv7() is natively available in PostgreSQL 18+
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS order_domain;
CREATE SCHEMA IF NOT EXISTS saga_coordination;
CREATE SCHEMA IF NOT EXISTS event_store;

-- SAGA coordination tables
CREATE TABLE saga_coordination.order_saga_state (
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

-- Event store for order service
CREATE TABLE event_store.order_events (
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
GRANT ALL ON SCHEMA order_domain TO order_service;
GRANT ALL ON SCHEMA saga_coordination TO order_service, order_saga_coordinator;
GRANT ALL ON SCHEMA event_store TO order_service;

GRANT ALL ON ALL TABLES IN SCHEMA saga_coordination TO order_service, order_saga_coordinator;
GRANT ALL ON ALL TABLES IN SCHEMA event_store TO order_service;
