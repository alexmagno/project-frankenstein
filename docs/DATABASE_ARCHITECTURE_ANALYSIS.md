# Database Architecture: Database Per Service Implementation

## 🎯 Current Architecture

**Project Frankenstein implements Database Per Service pattern** with dedicated PostgreSQL instances for each microservice, SAGA coordination, and OLAP analytics.

## 🏗️ Database Per Service Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DATABASE PER SERVICE ARCHITECTURE                   │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────────┬───────┤
│   user-db   │inventory-db │  order-db   │ payment-db  │notification │analyt.│
│   (5432)    │   (5433)    │   (5434)    │   (5435)    │  -db (5437) │(5438) │ 
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┼───────┤
│user_domain  │inventory_   │order_domain │payment_     │notification │OLAP   │
│saga_coord   │domain       │saga_coord   │domain       │_domain      │star   │
│event_store  │saga_coord   │event_store  │saga_coord   │saga_coord   │schema │
│             │event_store  │             │event_store  │event_store  │cubes  │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────┴───────┘
                                    │
                     Cross-Service Events (RabbitMQ + EventBridge)
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    READ SIDE (MongoDB + Redis)                             │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────────┤
│  user_views     │inventory_views  │  order_views    │    notification_views   │
│ - user_summary  │ - product_list  │ - order_history │ - delivery_status       │
│ - user_profile  │ - stock_levels  │ - order_details │ - template_usage        │
│ - user_activity │ - category_tree │ - payment_info  │ - channel_performance   │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────────┘
```

## 📊 Database Allocation

| **Service** | **Database** | **Port** | **Domain** | **Purpose** |
|-------------|--------------|----------|------------|-------------|
| user-service | user-db | 5432 | user_domain | Authentication, profiles, roles |
| inventory-service | inventory-db | 5433 | inventory_domain | Products, catalog, stock management |  
| order-service | order-db | 5434 | order_domain | Orders, order items, status |
| payment-service | payment-db | 5435 | payment_domain | Payments, external provider integration |
| notification-service | notification-db | 5437 | notification_domain | Email/SMS templates and delivery |
| analytics | analytics-db | 5438 | analytics_domain | OLAP data warehouse, business intelligence |
| infrastructure | infrastructure-db | 5439 | N/A | SonarQube, Unleash tools |

## 🔄 SAGA Coordination Pattern

Each service manages its own distributed transactions:

### **Complete E-Commerce SAGA Flow**
```
1. order-service: Creates order → RabbitMQ: OrderCreated
2. inventory-service: Reserves stock → RabbitMQ: InventoryReserved  
3. payment-service: External payment → EventBridge → Bridge → RabbitMQ: PaymentCompleted
4. notification-service: Sends email/SMS → RabbitMQ: CustomerNotified
5. analytics-service: Records metrics → SAGA completion

Compensation (if any step fails):
└── Each service handles its own rollback via RabbitMQ compensation events
```

## 📈 OLAP Analytics Implementation

### **Star Schema Design**
- **Fact Tables**: sales_fact, user_activity_fact
- **Dimension Tables**: time_dimension, customer_dimension, product_dimension
- **OLAP Cubes**: Pre-calculated monthly_sales_cube, customer_ltv_analysis
- **Business Intelligence**: Customer LTV, sales trends, inventory optimization

## 🔄 Hybrid Messaging Strategy

### **RabbitMQ (Java-to-Java)**
- Order processing choreography
- SAGA coordination
- Service-to-service events

### **EventBridge (Lambda Integration)**
- External payment webhooks
- AWS service events
- Image processing events

### **Bidirectional Bridges**
- EventBridge-to-RabbitMQ Lambda bridge
- RabbitMQ-to-EventBridge Lambda bridge

## 💡 Architecture Benefits

### **Service Autonomy**
- Each service evolves independently
- Technology diversity possible
- Individual scaling strategies

### **Fault Isolation** 
- Database failure affects only one service
- Service-level security boundaries
- Independent deployment cycles

### **Real-World Patterns**
- Enterprise microservices architecture
- Distributed transaction coordination
- External system integration
- Business intelligence and analytics

## 🎯 Complete E-Commerce Platform

**Services**: user, inventory, order, payment, notification, bff  
**Messaging**: RabbitMQ + EventBridge with bidirectional bridges  
**Analytics**: OLAP data warehouse with business intelligence  
**External Integration**: Payment providers, email/SMS services  
**Frontend**: React with BFF aggregation layer

This architecture demonstrates **production-ready enterprise microservices** with proper service boundaries, distributed transaction coordination, and comprehensive business intelligence capabilities.