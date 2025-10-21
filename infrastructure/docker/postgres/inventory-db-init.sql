-- Inventory Service Database Initialization
CREATE DATABASE inventory_service_db;

-- Create inventory service user (using environment variables)
CREATE USER inventory_service WITH ENCRYPTED PASSWORD :'INVENTORY_SERVICE_DATASOURCE_PASSWORD';
CREATE USER inventory_saga_coordinator WITH ENCRYPTED PASSWORD :'INVENTORY_SAGA_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE inventory_service_db TO inventory_service;
GRANT ALL PRIVILEGES ON DATABASE inventory_service_db TO inventory_saga_coordinator;

-- Connect to inventory service database
\c inventory_service_db;

-- Create extensions
-- Note: uuidv7() is natively available in PostgreSQL 18+
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS product_domain;
CREATE SCHEMA IF NOT EXISTS saga_coordination;
CREATE SCHEMA IF NOT EXISTS event_store;

-- SAGA coordination tables
CREATE TABLE saga_coordination.product_saga_state (
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

-- Event store for inventory service
CREATE TABLE event_store.inventory_events (
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
GRANT ALL ON SCHEMA inventory_domain TO inventory_service;
GRANT ALL ON SCHEMA saga_coordination TO inventory_service, inventory_saga_coordinator;
GRANT ALL ON SCHEMA event_store TO inventory_service;

GRANT ALL ON ALL TABLES IN SCHEMA saga_coordination TO inventory_service, inventory_saga_coordinator;
GRANT ALL ON ALL TABLES IN SCHEMA event_store TO inventory_service;
