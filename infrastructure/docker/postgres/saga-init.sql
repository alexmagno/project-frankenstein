-- Create SAGA dedicated database
CREATE DATABASE frankenstein_saga;

-- Create SAGA users
CREATE USER saga_coordinator WITH ENCRYPTED PASSWORD :'SAGA_COORDINATOR_PASSWORD';
CREATE USER saga_participant WITH ENCRYPTED PASSWORD :'SAGA_PARTICIPANT_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE frankenstein_saga TO saga_coordinator;
GRANT ALL PRIVILEGES ON DATABASE frankenstein_saga TO saga_participant;

-- Connect to SAGA database
\c frankenstein_saga;

-- Create SAGA schemas
CREATE SCHEMA IF NOT EXISTS saga_coordination;  -- For Orchestration pattern
CREATE SCHEMA IF NOT EXISTS saga_participants;  -- Service registry
CREATE SCHEMA IF NOT EXISTS analytics_domain;   -- Business domain for cross-database SAGA
CREATE SCHEMA IF NOT EXISTS notification_domain; -- Notification system domain

-- SAGA state management table
CREATE TABLE saga_coordination.saga_orchestrator (
    saga_id UUID PRIMARY KEY DEFAULT uuidv7(),
    saga_type VARCHAR(100) NOT NULL,
    business_transaction_id UUID NOT NULL,
    current_step INTEGER NOT NULL DEFAULT 1,
    total_steps INTEGER NOT NULL,
    saga_data JSONB NOT NULL,
    compensation_data JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'started', -- started, in_progress, completed, compensating, failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    timeout_at TIMESTAMP WITH TIME ZONE,
    error_details TEXT
);

-- SAGA step execution tracking
CREATE TABLE saga_coordination.saga_execution_log (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    saga_id UUID REFERENCES saga_coordination.saga_orchestrator(saga_id),
    step_number INTEGER NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    operation_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL, -- pending, completed, failed, compensated
    request_payload JSONB,
    response_payload JSONB,
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    compensation_completed_at TIMESTAMP WITH TIME ZONE
);

-- SAGA participants registry
CREATE TABLE saga_participants.service_registry (
    service_name VARCHAR(100) PRIMARY KEY,
    service_url VARCHAR(500) NOT NULL,
    health_check_url VARCHAR(500) NOT NULL,
    timeout_seconds INTEGER DEFAULT 30,
    retry_attempts INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT true,
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SAGA compensation actions
CREATE TABLE saga_coordination.compensation_actions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    saga_id UUID REFERENCES saga_coordination.saga_orchestrator(saga_id),
    step_number INTEGER NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    compensation_endpoint VARCHAR(200) NOT NULL,
    compensation_payload JSONB,
    execution_order INTEGER NOT NULL, -- Order for compensation (reverse of execution)
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    executed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX idx_saga_orchestrator_type ON saga_coordination.saga_orchestrator(saga_type);
CREATE INDEX idx_saga_orchestrator_status ON saga_coordination.saga_orchestrator(status);
CREATE INDEX idx_saga_orchestrator_created ON saga_coordination.saga_orchestrator(created_at);

CREATE INDEX idx_execution_log_saga_id ON saga_coordination.saga_execution_log(saga_id);
CREATE INDEX idx_execution_log_service ON saga_coordination.saga_execution_log(service_name);
CREATE INDEX idx_execution_log_status ON saga_coordination.saga_execution_log(status);

CREATE INDEX idx_compensation_saga_id ON saga_coordination.compensation_actions(saga_id);
CREATE INDEX idx_compensation_order ON saga_coordination.compensation_actions(execution_order);

-- Business domain tables (for cross-database SAGA demonstration)
CREATE TABLE analytics_domain.business_metrics (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    metric_type VARCHAR(100) NOT NULL, -- 'ORDER_PLACED', 'USER_REGISTERED', 'PRODUCT_VIEWED'
    entity_id UUID NOT NULL,
    metric_value DECIMAL(15,2),
    metadata JSONB,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE notification_domain.notification_queue (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    recipient_id UUID NOT NULL,
    notification_type VARCHAR(100) NOT NULL, -- 'EMAIL', 'SMS', 'PUSH'
    template_name VARCHAR(100) NOT NULL,
    template_data JSONB,
    delivery_status VARCHAR(50) DEFAULT 'pending', -- pending, sent, failed, delivered
    scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE
);

-- Grant schema permissions
GRANT ALL ON SCHEMA saga_coordination TO saga_coordinator;
GRANT USAGE ON SCHEMA saga_coordination TO saga_participant;

GRANT ALL ON SCHEMA saga_participants TO saga_coordinator, saga_participant;
GRANT ALL ON SCHEMA analytics_domain TO saga_coordinator, saga_participant;
GRANT ALL ON SCHEMA notification_domain TO saga_coordinator, saga_participant;

-- Grant table permissions  
GRANT ALL ON ALL TABLES IN SCHEMA saga_coordination TO saga_coordinator;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA saga_coordination TO saga_participant;

GRANT ALL ON ALL TABLES IN SCHEMA saga_participants TO saga_coordinator, saga_participant;
GRANT ALL ON ALL TABLES IN SCHEMA analytics_domain TO saga_coordinator, saga_participant;
GRANT ALL ON ALL TABLES IN SCHEMA notification_domain TO saga_coordinator, saga_participant;
