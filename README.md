# Project Frankenstein 🧪

A comprehensive microservices learning platform demonstrating modern enterprise architecture patterns and technologies.

## 🎯 Project Overview

This project serves as a hands-on laboratory for exploring and understanding current tech stacks used in modern enterprise applications. It implements a complete microservices ecosystem with all the bells and whistles you'd expect in production systems.

## 🏗️ Architecture Overview

### Core Services
- **User Service** - User management, authentication, profiles
- **Product Service** - Product catalog, inventory management  
- **Order Service** - Order processing, payment integration
- **Frontend Service** - React application with modern UI

### AWS Lambda Services
- **Notification Service** (SAM) - Email/SMS notifications via SQS
- **Analytics Service** (Terraform) - Data processing and reporting

## 🚀 Technology Stack

### Backend Technologies
- **Framework**: Spring Boot 3.x with Spring WebFlux
- **Security**: OAuth 2.0, JWT, Social Login (Google, GitHub)
- **Architecture**: CQRS (Command Query Responsibility Segregation) + Event Sourcing
- **Data Architecture**: 
  - **Write Side (Commands)**: Shared PostgreSQL with schema separation + Event Store
  - **Read Side (Queries)**: MongoDB with optimized document views
  - **Event Streaming**: Apache Kafka for event-driven projections
  - **Migrations**: Flyway for PostgreSQL schema management
- **Resilience**: Resilience4j (Circuit Breaker, Bulkhead, Rate Limiter)
- **Communication**: 
  - Sync: OpenFeign, Load Balancer
  - Async: RabbitMQ, Apache Kafka, Event Sourcing
- **Caching**: Redis with Spring Cache
- **Batch Processing**: Spring Batch
- **API Documentation**: OpenAPI 3.0 (Swagger)

### Frontend Technologies
- **Framework**: React 18 with TypeScript
- **State Management**: Redux Toolkit
- **UI Library**: Material-UI / Ant Design
- **Authentication**: OAuth 2.0 integration
- **Feature Flags**: Unleash (self-hosted) for feature toggles and A/B testing

### Infrastructure & DevOps
- **Containerization**: Docker & Docker Compose
- **Orchestration**: Kubernetes (local with kind/minikube)
- **Service Mesh**: Istio
- **Package Management**: Helm Charts
- **Service Discovery**: Spring Cloud Eureka
- **Configuration**: Spring Cloud Config Server
- **API Gateway**: Spring Cloud Gateway

### Cloud & AWS Services
- **AWS Simulation**: LocalStack
- **Functions**: AWS Lambda (SAM & Terraform)
- **Messaging**: Amazon SQS
- **Infrastructure as Code**: Terraform, SAM CLI

### Observability & Monitoring
- **Metrics**: Prometheus + Grafana
- **Distributed Tracing**: Jaeger with OpenTelemetry
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **APM**: Custom metrics and spans

### Testing Strategy
- **Unit Tests**: JUnit 5, Mockito (80%+ coverage)
- **Integration Tests**: TestContainers, WireMock
- **Behavioral Tests**: Cucumber
- **End-to-End Tests**: Selenium/Cypress
- **Performance Tests**: JMeter/Gatling
- **Contract Tests**: Spring Cloud Contract

### Code Quality & Security
- **Static Analysis**: SonarQube
- **Security Scanning**: OWASP Dependency Check
- **Code Formatting**: Prettier, ESLint
- **Architecture Compliance**: ArchUnit

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Environments**: Development, Staging, Production
- **Strategies**: Blue-Green, Canary Deployments
- **Quality Gates**: Automated testing, security scans

## 🏛️ Architecture Principles

This project follows industry best practices and architectural patterns:

- **Clean Architecture**: Clear separation of concerns with hexagonal architecture
- **Domain-Driven Design (DDD)**: Rich domain models with bounded contexts
- **SOLID Principles**: Maintainable and extensible code
- **12-Factor App**: Cloud-native application principles
- **Event-Driven Architecture**: Loose coupling through async messaging
- **CQRS**: Command Query Responsibility Segregation where applicable
- **Modern Java 21**: Leveraging latest LTS features including Records, Virtual Threads, Pattern Matching, and String Templates

## 📁 Project Structure

```
project-frankenstein/
├── services/
│   ├── user-service/           # User management & authentication
│   ├── product-service/        # Product catalog & inventory
│   ├── order-service/          # Order processing & payments
│   └── frontend-service/       # React application
├── aws-services/
│   ├── notification-lambda/    # SAM-based notification service
│   └── analytics-lambda/       # Terraform-based analytics service
├── infrastructure/
│   ├── docker/                 # Docker configurations
│   ├── kubernetes/             # K8s manifests and Helm charts
│   ├── terraform/              # Infrastructure as Code
│   ├── monitoring/             # Prometheus, Grafana configs
│   └── service-mesh/           # Istio configurations
├── config/
│   ├── spring-cloud-config/    # Centralized configuration
│   ├── dev/                    # Development environment
│   ├── staging/                # Staging environment
│   └── prod/                   # Production environment
├── scripts/
│   ├── setup/                  # Environment setup scripts
│   ├── deployment/             # Deployment automation
│   └── testing/                # Test execution scripts
├── docs/
│   ├── architecture/           # Architecture documentation
│   ├── api/                    # API documentation
│   └── deployment/             # Deployment guides
└── .github/
    └── workflows/              # CI/CD pipelines
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Kubernetes (kind/minikube)
- **Java 21** (LTS) - Required for latest features
- Node.js 18+
- Helm 3
- AWS CLI (for LocalStack)

### Local Development Setup

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd project-frankenstein
   chmod +x scripts/setup/dev-setup.sh
   ./scripts/setup/dev-setup.sh
   ```

2. **Start Infrastructure**
   ```bash
   docker-compose up -d postgres mongodb redis rabbitmq kafka localstack
   ```

3. **Build and Run Services**
   ```bash
   # Build all services
   mvn clean install

   # Run specific service
   mvn spring-boot:run -pl services/user-service
   mvn spring-boot:run -pl services/product-service
   mvn spring-boot:run -pl services/order-service
   mvn spring-boot:run -pl config/spring-cloud-config
   ```

4. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f infrastructure/kubernetes/namespace.yaml
   helm install frankenstein-stack infrastructure/kubernetes/helm/
   ```

5. **Access Applications**
   - Frontend: http://localhost:3000
   - API Gateway: http://localhost:8080
   - Config Server: http://localhost:8888
   - Unleash (Feature Flags): http://localhost:4242
   - Grafana: http://localhost:3001
   - Kibana: http://localhost:5601

## 📊 Monitoring & Observability

- **Application Metrics**: http://localhost:3001 (Grafana)
- **Distributed Tracing**: http://localhost:16686 (Jaeger)
- **Logs**: http://localhost:5601 (Kibana)
- **API Documentation**: http://localhost:8080/swagger-ui.html

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run specific test suites
mvn test -Dtest="*UnitTest"
mvn test -Dtest="*IntegrationTest"

# Run integration tests
mvn verify -P integration-tests

# Run behavioral tests
mvn test -Dtest="*CucumberTest"

# Generate coverage report
mvn jacoco:report

# Check coverage
mvn jacoco:check
```

## 🚀 Deployment

### Development
```bash
./scripts/deployment/deploy-dev.sh
```

### Staging
```bash
./scripts/deployment/deploy-staging.sh
```

### Production
```bash
./scripts/deployment/deploy-prod.sh
```

## 📚 Learning Objectives

By working through this project, you'll gain hands-on experience with:

1. **Microservices Architecture**: Service decomposition, inter-service communication
2. **Spring Ecosystem**: Boot, Cloud, Security, Data, WebFlux
3. **Containerization**: Docker, Kubernetes, Helm
4. **Message-Driven Architecture**: RabbitMQ, Kafka, Event Sourcing
5. **Observability**: Metrics, Tracing, Logging, APM
6. **DevOps Practices**: CI/CD, Infrastructure as Code, Monitoring
7. **Cloud-Native Patterns**: Service Mesh, Configuration Management
8. **Testing Strategies**: Unit, Integration, Contract, E2E testing
9. **Security**: OAuth, JWT, OWASP compliance
10. **Performance**: Caching, Rate Limiting, Load Balancing

## 🤝 Contributing

This is a learning project! Feel free to:
- Add new features or services
- Experiment with different technologies
- Improve documentation
- Share your learnings and discoveries

## 📖 Documentation

Detailed documentation for each topic can be found in the `/docs` directory:
- [Java 21 LTS Features Guide](docs/JAVA_21_FEATURES.md) - Complete guide to Java 21 features used in the project
- [Database Architecture Analysis](docs/DATABASE_ARCHITECTURE_ANALYSIS.md) - Shared vs separated database trade-offs
- [Project Implementation Plan](docs/PROJECT_PLAN.md) - Detailed 10-phase roadmap
- [Architecture Decision Records](docs/architecture/ADRs.md)
- [API Documentation](docs/api/)
- [Deployment Guide](docs/deployment/)
- [Testing Strategy](docs/testing.md)
- [Monitoring Setup](docs/monitoring.md)

## 🎯 Current Phase: Phase 2 - Core Services Development

We've completed Phase 1 (Foundation & Infrastructure) ✅ and are now ready for Phase 2:

**Phase 1 Completed** ✅:
- [x] Project structure and comprehensive documentation  
- [x] Maven multi-module build system with all dependencies
- [x] Complete Docker infrastructure stack (PostgreSQL, MongoDB, Redis, RabbitMQ, Kafka, LocalStack, ELK, Prometheus, Grafana, SonarQube)
- [x] Monitoring and observability configuration
- [x] Development environment automation

**Phase 2 Next Steps** 🔄:
- [ ] Domain design and entity modeling (DDD approach)
- [ ] Database layer with Flyway migrations  
- [ ] Repository and service layer implementation
- [ ] REST API development with OpenAPI documentation
- [ ] Spring Security with OAuth2 integration
- [ ] Comprehensive testing with 80%+ coverage

📋 **Full Roadmap**: See [PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for the complete 10-phase implementation plan with detailed substeps.

---

*"It's alive! IT'S ALIVE!"* - Dr. Frankenstein (probably talking about microservices)

