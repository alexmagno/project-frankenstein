# Hybrid Read Strategy Implementation Guide

## 🎯 Overview

This document provides a comprehensive guide for implementing the hybrid read-side strategy in Project Frankenstein, combining **MongoDB document views** and **PostgreSQL read replicas with materialized views** for optimal learning and performance.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    WRITE SIDE (Commands)                        │
│                 PostgreSQL Primary Database                     │
│                    (Port 5432)                                  │
├─────────────────┬─────────────────┬─────────────────┬───────────┤
│  user_domain    │ product_domain  │  order_domain   │shared_dmn │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
                                    │
                            Event Stream (Kafka)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
         ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
         │   MongoDB       │ │ PostgreSQL      │ │    Redis        │
         │ Document Views  │ │ Read Replica    │ │    Cache        │
         │ (Port 27017)    │ │ (Port 5433)     │ │  (Port 6379)    │
         │                 │ │ + Mat. Views    │ │                 │
         └─────────────────┘ └─────────────────┘ └─────────────────┘
```

## 📊 Use Case Decision Matrix

| **Scenario** | **MongoDB** | **PG Replica** | **Redis** | **Reasoning** |
|--------------|-------------|----------------|-----------|---------------|
| **User Profile Display** | ✅ Primary | ❌ | ✅ Cache | Nested data, frequent UI updates |
| **Product Search & Filters** | ✅ Primary | ❌ | ✅ Cache | Text search, faceted filtering |
| **Order History (UI)** | ✅ Primary | ❌ | ✅ Cache | Document structure matches UI needs |
| **Real-time Dashboard** | ✅ Primary | ❌ | ✅ Cache | Fast aggregations, flexible schema |
| **Financial Reports** | ❌ | ✅ Primary | ❌ | SQL joins, regulatory compliance |
| **Business Analytics** | ❌ | ✅ Primary | ❌ | Complex queries, data warehousing |
| **Audit & Compliance** | ❌ | ✅ Primary | ❌ | SQL reporting, immutable history |
| **Cross-domain Analysis** | ❌ | ✅ Primary | ❌ | Multi-table joins, aggregations |

## 🔧 Implementation Strategy

### Phase 1: MongoDB Document Views (Weeks 1-2)

#### **1.1 MongoDB Collections Design**

```javascript
// User Views Collection
{
  _id: "user_123",
  version: 15,
  lastUpdated: ISODate("2024-01-15T10:30:00Z"),
  profile: {
    id: "user_123",
    email: "john@example.com",
    firstName: "John",
    lastName: "Doe",
    fullName: "John Doe",
    avatar: "https://example.com/avatars/john.jpg",
    tier: "VIP"
  },
  preferences: {
    language: "en",
    timezone: "UTC-5",
    notifications: {
      email: true,
      sms: false,
      push: true
    }
  },
  activity: {
    lastLogin: ISODate("2024-01-15T09:45:00Z"),
    loginCount: 247,
    orderCount: 25,
    totalSpent: 2500.00,
    averageOrderValue: 100.00
  },
  addresses: [
    {
      id: "addr_1",
      type: "shipping",
      street: "123 Main St",
      city: "Springfield",
      state: "IL",
      zipCode: "62701",
      country: "US",
      isDefault: true
    }
  ]
}

// Product Views Collection
{
  _id: "product_456",
  name: "Smartphone Pro Max",
  slug: "smartphone-pro-max",
  description: "Latest smartphone with advanced features",
  category: {
    id: "electronics",
    name: "Electronics",
    path: "Electronics > Mobile > Smartphones"
  },
  pricing: {
    current: 899.99,
    original: 999.99,
    currency: "USD",
    discount: 10.0
  },
  inventory: {
    available: 150,
    reserved: 25,
    threshold: 10,
    status: "IN_STOCK"
  },
  images: [
    {
      url: "https://example.com/images/phone1.jpg",
      alt: "Smartphone front view",
      isPrimary: true
    }
  ],
  attributes: {
    color: "Midnight Black",
    storage: "256GB",
    screenSize: "6.7 inches",
    weight: "0.5 lbs"
  },
  ratings: {
    average: 4.5,
    count: 1247,
    distribution: {
      "5": 800,
      "4": 300,
      "3": 100,
      "2": 30,
      "1": 17
    }
  }
}

// Order Views Collection
{
  _id: "order_789",
  orderNumber: "ORD-2024-001234",
  customer: {
    id: "user_123",
    name: "John Doe",
    email: "john@example.com"
  },
  status: {
    current: "SHIPPED",
    history: [
      {
        status: "PENDING",
        timestamp: ISODate("2024-01-10T10:00:00Z"),
        note: "Order placed"
      },
      {
        status: "PROCESSING",  
        timestamp: ISODate("2024-01-10T14:30:00Z"),
        note: "Order confirmed and processing"
      },
      {
        status: "SHIPPED",
        timestamp: ISODate("2024-01-11T09:15:00Z"),
        note: "Order shipped via FedEx",
        trackingNumber: "1234567890"
      }
    ]
  },
  items: [
    {
      productId: "product_456",
      name: "Smartphone Pro Max",
      quantity: 1,
      unitPrice: 899.99,
      totalPrice: 899.99,
      image: "https://example.com/images/phone1.jpg"
    }
  ],
  pricing: {
    subtotal: 899.99,
    tax: 72.00,
    shipping: 15.00,
    discount: 50.00,
    total: 936.99
  },
  shipping: {
    address: {
      street: "123 Main St",
      city: "Springfield", 
      state: "IL",
      zipCode: "62701"
    },
    method: "STANDARD",
    carrier: "FedEx",
    trackingNumber: "1234567890",
    estimatedDelivery: ISODate("2024-01-15T18:00:00Z")
  },
  timestamps: {
    placed: ISODate("2024-01-10T10:00:00Z"),
    updated: ISODate("2024-01-11T09:15:00Z")
  }
}
```

#### **1.2 MongoDB Indexes**

```javascript
// User Views Indexes
db.user_views.createIndex({ "profile.email": 1 }, { unique: true })
db.user_views.createIndex({ "profile.tier": 1 })
db.user_views.createIndex({ "activity.lastLogin": -1 })
db.user_views.createIndex({ "lastUpdated": -1 })

// Product Views Indexes
db.product_views.createIndex({ "name": "text", "description": "text" })
db.product_views.createIndex({ "category.id": 1 })
db.product_views.createIndex({ "pricing.current": 1 })
db.product_views.createIndex({ "inventory.status": 1 })
db.product_views.createIndex({ "ratings.average": -1 })

// Order Views Indexes
db.order_views.createIndex({ "customer.id": 1, "timestamps.placed": -1 })
db.order_views.createIndex({ "status.current": 1 })
db.order_views.createIndex({ "orderNumber": 1 }, { unique: true })
db.order_views.createIndex({ "timestamps.placed": -1 })
```

### Phase 2: PostgreSQL Read Replicas + Materialized Views (Weeks 3-4)

#### **2.1 Materialized Views for Analytics**

```sql
-- Financial Summary Materialized View
CREATE MATERIALIZED VIEW analytics.financial_summary AS
SELECT 
    DATE_TRUNC('month', o.created_at) as month,
    COUNT(*) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    COUNT(DISTINCT o.user_id) as unique_customers,
    SUM(CASE WHEN o.status = 'COMPLETED' THEN o.total_amount ELSE 0 END) as completed_revenue,
    SUM(CASE WHEN o.status = 'CANCELLED' THEN o.total_amount ELSE 0 END) as lost_revenue
FROM order_domain.orders o
WHERE o.created_at >= CURRENT_DATE - INTERVAL '24 months'
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY month DESC;

-- Customer Analytics Materialized View  
CREATE MATERIALIZED VIEW analytics.customer_analytics AS
SELECT 
    u.id as customer_id,
    u.email,
    u.first_name,
    u.last_name,
    u.created_at as registration_date,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as lifetime_value,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.created_at) as last_order_date,
    CASE 
        WHEN MAX(o.created_at) > CURRENT_DATE - INTERVAL '30 days' THEN 'ACTIVE'
        WHEN MAX(o.created_at) > CURRENT_DATE - INTERVAL '90 days' THEN 'AT_RISK'  
        WHEN MAX(o.created_at) IS NOT NULL THEN 'INACTIVE'
        ELSE 'NEVER_PURCHASED'
    END as customer_segment
FROM user_domain.users u
LEFT JOIN order_domain.orders o ON u.id = o.user_id AND o.status = 'COMPLETED'
GROUP BY u.id, u.email, u.first_name, u.last_name, u.created_at;

-- Product Performance Materialized View
CREATE MATERIALIZED VIEW analytics.product_performance AS
SELECT 
    p.id as product_id,
    p.name,
    p.category_id,
    c.name as category_name,
    COUNT(oi.id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    COALESCE(inv.current_stock, 0) as current_stock,
    CASE 
        WHEN COUNT(oi.id) = 0 THEN 'NO_SALES'
        WHEN COUNT(oi.id) < 10 THEN 'LOW_SALES'
        WHEN COUNT(oi.id) < 100 THEN 'MEDIUM_SALES'
        ELSE 'HIGH_SALES'
    END as sales_performance
FROM product_domain.products p
LEFT JOIN product_domain.categories c ON p.category_id = c.id
LEFT JOIN order_domain.order_items oi ON p.id = oi.product_id
LEFT JOIN product_domain.inventory inv ON p.id = inv.product_id
WHERE p.created_at >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY p.id, p.name, p.category_id, c.name, inv.current_stock;

-- Audit Trail View for Compliance
CREATE MATERIALIZED VIEW compliance.audit_trail AS
SELECT 
    e.id as event_id,
    e.aggregate_id,
    e.aggregate_type,
    e.event_type,
    e.occurred_at,
    e.event_data->>'userId' as user_id,
    e.event_data->>'action' as action,
    e.event_data->>'ipAddress' as ip_address,
    e.metadata->>'userAgent' as user_agent,
    e.metadata->>'sessionId' as session_id
FROM shared_domain.events e
WHERE e.event_type IN ('USER_REGISTERED', 'USER_UPDATED', 'ORDER_PLACED', 'PAYMENT_PROCESSED')
ORDER BY e.occurred_at DESC;
```

#### **2.2 Refresh Strategies**

```sql
-- Create refresh function
CREATE OR REPLACE FUNCTION analytics.refresh_materialized_views()
RETURNS void AS $$
BEGIN
    -- Refresh financial summary (daily)
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.financial_summary;
    
    -- Refresh customer analytics (hourly)
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.customer_analytics;
    
    -- Refresh product performance (hourly)
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.product_performance;
    
    -- Refresh audit trail (every 15 minutes)
    REFRESH MATERIALIZED VIEW CONCURRENTLY compliance.audit_trail;
    
    -- Log refresh completion
    INSERT INTO analytics.refresh_log (view_name, refreshed_at) 
    VALUES ('all_views', NOW());
END;
$$ LANGUAGE plpgsql;

-- Schedule periodic refresh (would be configured in production)
-- SELECT cron.schedule('refresh-analytics', '0 * * * *', 'SELECT analytics.refresh_materialized_views();');
```

## 🔄 Event Projection Strategy

### MongoDB Projectors (Real-time UI Updates)

```java
@Component
@KafkaListener(topics = "user-events")
public class MongoUserViewProjector {
    
    @Autowired
    private MongoTemplate mongoTemplate;
    
    @KafkaHandler
    public void handle(UserRegisteredEvent event) {
        var userView = UserView.builder()
            .id(event.getUserId())
            .version(1)
            .lastUpdated(Instant.now())
            .profile(UserProfile.builder()
                .id(event.getUserId())
                .email(event.getEmail())
                .firstName(event.getFirstName())
                .lastName(event.getLastName())
                .fullName(event.getFirstName() + " " + event.getLastName())
                .tier("BASIC")
                .build())
            .activity(UserActivity.builder()
                .loginCount(0)
                .orderCount(0)
                .totalSpent(BigDecimal.ZERO)
                .build())
            .build();
            
        mongoTemplate.save(userView, "user_views");
    }
    
    @KafkaHandler  
    public void handle(UserProfileUpdatedEvent event) {
        var query = Query.query(Criteria.where("_id").is(event.getUserId()));
        var update = new Update()
            .set("profile.firstName", event.getFirstName())
            .set("profile.lastName", event.getLastName())
            .set("profile.fullName", event.getFirstName() + " " + event.getLastName())
            .inc("version", 1)
            .set("lastUpdated", Instant.now());
            
        mongoTemplate.updateFirst(query, update, "user_views");
    }
}
```

### PostgreSQL Materialized View Projectors (Analytics Updates)

```java
@Component
@KafkaListener(topics = "order-events")
public class PostgreSQLAnalyticsProjector {
    
    @Autowired
    @Qualifier("readReplicaJdbcTemplate")
    private JdbcTemplate readReplicaJdbcTemplate;
    
    @KafkaHandler
    @Scheduled(fixedRate = 3600000) // Refresh every hour
    public void refreshCustomerAnalytics() {
        readReplicaJdbcTemplate.execute(
            "REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.customer_analytics"
        );
    }
    
    @KafkaHandler
    @Scheduled(cron = "0 0 2 * * ?") // Refresh daily at 2 AM
    public void refreshFinancialSummary() {
        readReplicaJdbcTemplate.execute(
            "REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.financial_summary"
        );  
    }
}
```

## 🎯 Query Implementation Examples

### MongoDB Queries (UI-focused)

```java
@Repository
public class MongoUserViewRepository {
    
    @Autowired
    private MongoTemplate mongoTemplate;
    
    public Optional<UserView> findUserProfile(String userId) {
        return Optional.ofNullable(
            mongoTemplate.findById(userId, UserView.class, "user_views")
        );
    }
    
    public List<UserView> findActiveCustomers(int limit) {
        var query = Query.query(
            Criteria.where("activity.lastLogin")
                   .gte(Instant.now().minus(30, ChronoUnit.DAYS))
        ).limit(limit);
        
        return mongoTemplate.find(query, UserView.class, "user_views");
    }
    
    public List<ProductView> searchProducts(String searchTerm, String category, int page, int size) {
        var criteria = new Criteria();
        
        if (StringUtils.hasText(searchTerm)) {
            criteria = criteria.andOperator(
                new Criteria().orOperator(
                    Criteria.where("name").regex(searchTerm, "i"),
                    Criteria.where("description").regex(searchTerm, "i")
                )
            );
        }
        
        if (StringUtils.hasText(category)) {
            criteria = criteria.and("category.id").is(category);
        }
        
        var query = Query.query(criteria)
            .skip(page * size)
            .limit(size)
            .with(Sort.by(Sort.Direction.DESC, "ratings.average"));
            
        return mongoTemplate.find(query, ProductView.class, "product_views");
    }
}
```

### PostgreSQL Read Replica Queries (Analytics-focused)

```java
@Repository
public class PostgreSQLAnalyticsRepository {
    
    @Autowired
    @Qualifier("readReplicaJdbcTemplate")  
    private JdbcTemplate readReplicaJdbcTemplate;
    
    public List<FinancialSummary> getMonthlyRevenue(int months) {
        var sql = """
            SELECT month, total_orders, total_revenue, avg_order_value, unique_customers
            FROM analytics.financial_summary 
            WHERE month >= CURRENT_DATE - INTERVAL '%d months'
            ORDER BY month DESC
            """.formatted(months);
            
        return readReplicaJdbcTemplate.query(sql, new FinancialSummaryRowMapper());
    }
    
    public List<CustomerSegment> getCustomerSegmentation() {
        var sql = """
            SELECT 
                customer_segment,
                COUNT(*) as customer_count,
                AVG(lifetime_value) as avg_lifetime_value,
                SUM(lifetime_value) as total_lifetime_value
            FROM analytics.customer_analytics 
            GROUP BY customer_segment
            ORDER BY avg_lifetime_value DESC
            """;
            
        return readReplicaJdbcTemplate.query(sql, new CustomerSegmentRowMapper());
    }
    
    public List<AuditEntry> getComplianceAuditTrail(String userId, LocalDateTime from, LocalDateTime to) {
        var sql = """
            SELECT event_id, aggregate_type, event_type, occurred_at, action, ip_address
            FROM compliance.audit_trail
            WHERE user_id = ? AND occurred_at BETWEEN ? AND ?
            ORDER BY occurred_at DESC
            """;
            
        return readReplicaJdbcTemplate.query(sql, new AuditEntryRowMapper(), userId, from, to);
    }
}
```

## 📊 Performance Monitoring & Optimization

### Key Metrics to Track

1. **MongoDB Performance**:
   - Query response times
   - Index usage statistics
   - Collection scan ratios
   - Memory usage

2. **PostgreSQL Read Replica Performance**:
   - Replication lag
   - Materialized view refresh times  
   - Query execution plans
   - Connection pool metrics

3. **Business Metrics**:
   - Cache hit rates
   - Data consistency checks
   - Event processing latency
   - User experience metrics

### Optimization Strategies

1. **MongoDB Optimization**:
   - Compound indexes for common query patterns
   - Aggregation pipeline optimization
   - Document structure tuning
   - Connection pooling

2. **PostgreSQL Optimization**:
   - Incremental materialized view refreshes
   - Partitioned tables for large datasets
   - Index optimization for analytical queries
   - Connection pooling for read replicas

## 🎓 Learning Outcomes

By implementing this hybrid read strategy, you'll gain hands-on experience with:

1. **Multiple Database Technologies**: MongoDB and PostgreSQL
2. **CQRS Patterns**: Event-driven projections and view management
3. **Performance Optimization**: Caching, indexing, and query tuning
4. **Operational Complexity**: Managing multiple data stores
5. **Real-world Architecture**: How enterprises combine different data storage strategies

This comprehensive approach provides the best of both worlds while maximizing your learning experience in modern data architecture patterns.
