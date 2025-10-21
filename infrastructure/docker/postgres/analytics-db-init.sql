-- Analytics Database Initialization (Cross-Service Analytics)
CREATE DATABASE analytics_db;

-- Create analytics service user (using environment variables)
CREATE USER analytics_service WITH ENCRYPTED PASSWORD :'ANALYTICS_SERVICE_DATASOURCE_PASSWORD';
CREATE USER analytics_saga_coordinator WITH ENCRYPTED PASSWORD :'ANALYTICS_SAGA_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE analytics_db TO analytics_service;
GRANT ALL PRIVILEGES ON DATABASE analytics_db TO analytics_saga_coordinator;

-- Connect to analytics database
\c analytics_db;

-- Create extensions
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- Not needed in PostgreSQL 18+
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
-- Note: uuidv7() is natively available in PostgreSQL 18+

-- Create schemas
CREATE SCHEMA IF NOT EXISTS analytics_domain;
CREATE SCHEMA IF NOT EXISTS saga_coordination;
CREATE SCHEMA IF NOT EXISTS event_store;

-- OLAP Data Warehouse Schema (Star Schema Design)

-- Dimension Tables
CREATE TABLE analytics_domain.time_dimension (
    time_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    week INTEGER NOT NULL,
    day_of_year INTEGER NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    month_name VARCHAR(20),
    day_name VARCHAR(20),
    is_weekend BOOLEAN DEFAULT false,
    is_holiday BOOLEAN DEFAULT false
);

CREATE TABLE analytics_domain.customer_dimension (
    customer_key UUID PRIMARY KEY DEFAULT uuidv7(),
    customer_id UUID NOT NULL,
    customer_type VARCHAR(50),
    registration_date DATE,
    customer_tier VARCHAR(20),
    geographic_region VARCHAR(100),
    acquisition_channel VARCHAR(100),
    -- SCD Type 2 for historical tracking
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_current BOOLEAN DEFAULT true,
    version INTEGER DEFAULT 1
);

CREATE TABLE analytics_domain.product_dimension (
    product_key UUID PRIMARY KEY DEFAULT uuidv7(),
    product_id UUID NOT NULL,
    product_name VARCHAR(500),
    category_name VARCHAR(200),
    category_hierarchy VARCHAR(1000),
    brand VARCHAR(200),
    price_range VARCHAR(50),
    -- SCD Type 2 for price/category changes
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_current BOOLEAN DEFAULT true,
    version INTEGER DEFAULT 1
);

-- Fact Tables
CREATE TABLE analytics_domain.sales_fact (
    sale_id UUID PRIMARY KEY DEFAULT uuidv7(),
    time_key INTEGER REFERENCES analytics_domain.time_dimension(time_key),
    customer_key UUID REFERENCES analytics_domain.customer_dimension(customer_key),
    product_key UUID REFERENCES analytics_domain.product_dimension(product_key),
    order_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    profit_margin DECIMAL(10,2),
    sale_timestamp TIMESTAMP WITH TIME ZONE NOT NULL
) PARTITION BY RANGE (time_key);

CREATE TABLE analytics_domain.user_activity_fact (
    activity_id UUID PRIMARY KEY DEFAULT uuidv7(),
    time_key INTEGER REFERENCES analytics_domain.time_dimension(time_key),
    customer_key UUID REFERENCES analytics_domain.customer_dimension(customer_key),
    activity_type VARCHAR(100) NOT NULL,
    session_id UUID,
    page_views INTEGER DEFAULT 0,
    session_duration_minutes INTEGER DEFAULT 0,
    conversion_flag BOOLEAN DEFAULT false,
    activity_timestamp TIMESTAMP WITH TIME ZONE NOT NULL
) PARTITION BY RANGE (time_key);

-- Pre-calculated Aggregations (OLAP Cubes)
CREATE MATERIALIZED VIEW analytics_domain.monthly_sales_cube AS
SELECT 
    td.year,
    td.month,
    td.month_name,
    cd.customer_tier,
    cd.geographic_region,
    pd.category_name,
    COUNT(*) as total_orders,
    SUM(sf.total_amount) as total_revenue,
    AVG(sf.total_amount) as avg_order_value,
    SUM(sf.profit_margin) as total_profit,
    COUNT(DISTINCT sf.customer_key) as unique_customers
FROM analytics_domain.sales_fact sf
JOIN analytics_domain.time_dimension td ON sf.time_key = td.time_key
JOIN analytics_domain.customer_dimension cd ON sf.customer_key = cd.customer_key  
JOIN analytics_domain.product_dimension pd ON sf.product_key = pd.product_key
WHERE cd.is_current = true AND pd.is_current = true
GROUP BY td.year, td.month, td.month_name, cd.customer_tier, cd.geographic_region, pd.category_name;

-- Customer Lifetime Value Calculation
CREATE MATERIALIZED VIEW analytics_domain.customer_ltv_analysis AS
SELECT 
    cd.customer_key,
    cd.customer_tier,
    cd.geographic_region,
    COUNT(*) as total_orders,
    SUM(sf.total_amount) as lifetime_value,
    AVG(sf.total_amount) as avg_order_value,
    MAX(td.full_date) as last_order_date,
    EXTRACT(days FROM (CURRENT_DATE - MAX(td.full_date))) as days_since_last_order,
    CASE 
        WHEN MAX(td.full_date) > CURRENT_DATE - INTERVAL '30 days' THEN 'ACTIVE'
        WHEN MAX(td.full_date) > CURRENT_DATE - INTERVAL '90 days' THEN 'AT_RISK'
        ELSE 'INACTIVE'
    END as customer_status
FROM analytics_domain.sales_fact sf
JOIN analytics_domain.time_dimension td ON sf.time_key = td.time_key
JOIN analytics_domain.customer_dimension cd ON sf.customer_key = cd.customer_key
WHERE cd.is_current = true
GROUP BY cd.customer_key, cd.customer_tier, cd.geographic_region;

-- SAGA coordination for analytics
CREATE TABLE saga_coordination.analytics_saga_state (
    saga_id UUID PRIMARY KEY DEFAULT uuidv7(),
    saga_type VARCHAR(100) NOT NULL,
    business_transaction_id UUID NOT NULL,
    participating_services TEXT[] NOT NULL,
    current_step INTEGER NOT NULL DEFAULT 1,
    total_steps INTEGER NOT NULL,
    saga_data JSONB NOT NULL,
    compensation_data JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'started',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event store for analytics
CREATE TABLE event_store.analytics_events (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    source_service VARCHAR(100) NOT NULL,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_version INTEGER NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB DEFAULT '{}',
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Grant permissions
GRANT ALL ON SCHEMA analytics_domain TO analytics_service;
GRANT ALL ON SCHEMA saga_coordination TO analytics_service, analytics_saga_coordinator;
GRANT ALL ON SCHEMA event_store TO analytics_service;

GRANT ALL ON ALL TABLES IN SCHEMA analytics_domain TO analytics_service;
GRANT ALL ON ALL TABLES IN SCHEMA saga_coordination TO analytics_service, analytics_saga_coordinator;
GRANT ALL ON ALL TABLES IN SCHEMA event_store TO analytics_service;
