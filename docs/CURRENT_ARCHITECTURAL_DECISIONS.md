# Current Architectural Decisions Summary

This document summarizes all the architectural decisions made during our recent planning sessions.

## 🏗️ Service Architecture Patterns (Phase 2)

### **Clean Architecture Services (4 services)**:
- **user-service**: DDD with domain/application/infrastructure layers
- **inventory-service**: Hexagonal architecture with ports and adapters
- **order-service**: CQRS with clean architecture boundaries  
- **payment-service**: Event sourcing with clean architecture

### **Traditional MVC Service (1 service)**:
- **notification-service**: Controller/Service/Repository/Entity layers
- Purpose: Compare development velocity, testability, and complexity vs Clean Architecture

### **Modular Monolith (1 service)**:
- **bff-service**: 4 internal modules with direct imports + Spring Events
  - User Aggregation Module
  - Order Aggregation Module  
  - Inventory Aggregation Module
  - Analytics Aggregation Module

## 🔄 Transaction Patterns (Phase 6)

### **SAGA Pattern (Eventually Consistent)**:
- **Use cases**: Order fulfillment, user registration, business workflows
- **Benefits**: High availability, scalability, fault tolerance
- **Drawbacks**: Eventually consistent, complex compensation logic

### **Two-Phase Commit (Immediately Consistent)**:
- **Use cases**: Payment processing, financial operations, critical transactions
- **Benefits**: ACID consistency, immediate consistency, simple rollback
- **Drawbacks**: Blocking protocol, lower availability, performance overhead

### **Use Cases**:

**SAGA Pattern**:
- Order fulfillment workflow (inventory → payment → shipping → notification)
- User registration process (user creation → profile setup → email verification)
- Content publishing (upload → processing → moderation → publish)

**Two-Phase Commit**:
- Financial transactions (payment processing with immediate consistency)
- Account transfers (debit source → credit destination)
- Critical inventory operations (stock reservation with strict consistency)

## 📨 Messaging Strategy

### **RabbitMQ (Basic Messaging)**:
- **Service coordination**: order.*, payment.*, inventory.* events
- **Domain event publishing**: All microservice communication
- **SAGA coordination**: Choreography and compensation events
- **Use case**: Primary messaging for Phases 2-6

### **Kafka (Advanced Streaming)**:
- **Stream processing**: Real-time analytics and complex event processing
- **Advanced patterns**: Event correlation, window aggregations, stream joins
- **Use case**: Phase 6.3 advanced streaming patterns only

## 🛠️ Infrastructure as Code (Phase 7)

### **AWS CDK (TypeScript)**:
- **Use case**: Complex video processing infrastructure
- **Services**: video-processing-ec2-service, video-processing-fargate-service
- **Features**: Type safety, reusable constructs, full AWS service support

### **Terraform (HCL)**:
- **Use case**: Analytics services with state management
- **Features**: Multi-cloud, mature ecosystem, declarative syntax

### **SAM (YAML)**:
- **Use case**: Simple Lambda functions for notifications
- **Features**: Lambda-focused, quick deployment, serverless-first

## 🎬 Business-Driven Media Processing (Phase 7)

### **Image Upload Flow (Simple)**:
```
User creates product → Upload image → Direct S3 → Lambda thumbnail generation → Metadata sync to inventory-service
```

### **Video Upload Flow (Complex)**:
```
User creates product → Upload video → Lambda orchestrator → SQS → CDK-managed ECS processing → Metadata back to product catalog
```

### **Integration Points**:
- **Trigger**: inventory-service product creation/update
- **Processing**: AWS services (S3, Lambda, ECS, SQS, DynamoDB)
- **Feedback**: Metadata synced back to product catalog

## 🔐 Security & Configuration

### **Multi-Environment Secret Management**:
- **Files**: .env.dev, .env.staging, .env.prod (32 secrets each)
- **Naming conventions**: 
  - SERVICE_DATASOURCE_PASSWORD (for Spring datasources)
  - SERVICE_JDBC_PASSWORD (for JDBC connections)
  - SERVICE_TOKEN (for API tokens)

### **Container Management**:
- **Consistent ports**: 8081+8091, 8082+8092, etc. (app + management)
- **Health checks**: All services have proper health endpoints
- **Networks**: frankenstein-network bridge for service communication

## 📊 Complete Observability Stack

### **Logging (ELK Stack)**:
- **Elasticsearch**: Search and analytics database
- **Logstash**: Log processing with 3 input ports (5044: Filebeat, 5000: TCP, 5045: Spring Boot)
- **Kibana**: Web UI for log visualization
- **Filebeat**: Collects logs from all Docker containers (frankenstein-*)

### **Metrics (Prometheus + Grafana)**:
- **Prometheus**: Scrapes metrics from all management ports (:809X)
- **Grafana**: Dashboards for service health and performance comparisons

### **Tracing (Jaeger)**:
- **Distributed tracing**: Traces requests across all architectural patterns
- **Performance analysis**: Compare tracing across Clean Architecture vs MVC

## 🎓 Educational Benefits

This architecture provides hands-on experience with:

### **Pattern Comparisons**:
- **Development velocity**: MVC vs Clean Architecture implementation speed
- **Testability**: Unit testing approaches across patterns
- **Maintainability**: Long-term maintenance complexity analysis
- **Performance**: Response times and resource usage comparison

### **Real-world Decision Making**:
- **When to use** each architectural pattern
- **How to choose** between transaction patterns
- **Which IaC tool** for different use cases
- **Messaging strategy** selection criteria

### **Production Readiness**:
- **Complete observability** from day one
- **Multi-environment** deployment strategies  
- **Security best practices** with secret externalization
- **Business integration** with real e-commerce workflows

## 🚀 Next Steps

With Phase 1 complete, the project is ready for:

1. **Phase 2**: Implement all 6 services with their respective architectural patterns
2. **Phase 6**: Compare SAGA vs 2PC transaction patterns
3. **Phase 7**: Deploy video processing with CDK vs Terraform vs SAM comparison

This creates the most comprehensive Spring Boot learning platform available, with direct comparisons of all major architectural patterns and tools.
