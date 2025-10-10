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
CREATE EXTENSION IF NOT EXISTS "btree_gin"; -- For JSON indexing

-- Create schemas for each service domain (logical separation)
CREATE SCHEMA IF NOT EXISTS user_domain;
CREATE SCHEMA IF NOT EXISTS product_domain;
CREATE SCHEMA IF NOT EXISTS order_domain;
CREATE SCHEMA IF NOT EXISTS shared_domain; -- For cross-domain entities and event store

-- Create Event Store tables in shared_domain
-- Events table for event sourcing
CREATE TABLE shared_domain.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_version INTEGER NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB DEFAULT '{}',
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Snapshots table for performance optimization
CREATE TABLE shared_domain.snapshots (
    aggregate_id UUID PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,
    version INTEGER NOT NULL,
    snapshot_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projection status table for tracking read model updates
CREATE TABLE shared_domain.projection_status (
    projection_name VARCHAR(100) PRIMARY KEY,
    last_processed_event_id UUID,
    last_processed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'active', -- active, rebuilding, error
    error_message TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Saga state table for long-running processes
CREATE TABLE shared_domain.saga_state (
    saga_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    saga_type VARCHAR(100) NOT NULL,
    saga_data JSONB NOT NULL,
    status VARCHAR(50) DEFAULT 'active', -- active, completed, compensating, failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_events_aggregate_id ON shared_domain.events(aggregate_id);
CREATE INDEX idx_events_aggregate_type ON shared_domain.events(aggregate_type);
CREATE INDEX idx_events_occurred_at ON shared_domain.events(occurred_at);
CREATE INDEX idx_events_event_type ON shared_domain.events(event_type);
CREATE INDEX idx_events_composite ON shared_domain.events(aggregate_id, event_version);

-- GIN index for JSON queries
CREATE INDEX idx_events_data_gin ON shared_domain.events USING GIN(event_data);
CREATE INDEX idx_events_metadata_gin ON shared_domain.events USING GIN(metadata);

-- Partitioning for events table (by month for better performance)
-- This will be implemented in Flyway migrations

-- Grant schema permissions
GRANT ALL ON SCHEMA user_domain TO user_service_user;
GRANT USAGE ON SCHEMA user_domain TO product_service_user, order_service_user;

GRANT ALL ON SCHEMA product_domain TO product_service_user;
GRANT USAGE ON SCHEMA product_domain TO user_service_user, order_service_user;

GRANT ALL ON SCHEMA order_domain TO order_service_user;
GRANT USAGE ON SCHEMA order_domain TO user_service_user, product_service_user;

GRANT ALL ON SCHEMA shared_domain TO user_service_user, product_service_user, order_service_user;
