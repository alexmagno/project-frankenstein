# Project Frankenstein 👨‍💻

> **A Comprehensive Microservices Learning Platform**

This project serves as a hands-on laboratory for exploring and understanding current tech stacks used in modern enterprise applications. It implements a complete microservices ecosystem with all the bells and whistles you'd expect in production systems.

## 🎯 What You'll Learn

### Modern Architecture Patterns
- **Microservices Architecture** with proper service boundaries
- **Event-Driven Architecture** with messaging and event sourcing
- **CQRS (Command Query Responsibility Segregation)** for scalable reads/writes
- **SAGA Pattern** for distributed transactions
- **Domain-Driven Design (DDD)** with rich domain models
- **Clean Architecture** principles with hexagonal architecture

### Technology Stack

### Backend (Java 21 LTS)
- **Spring Boot 3.2+** (Web, Data, Security, Cloud)
- **Spring Cloud** (Config, Gateway, Circuit Breaker)
- **PostgreSQL 18** (with UUID v7 support)
- **MongoDB** (Document store for read models)
- **Redis** (Caching and session management)
- **Apache Kafka** + **RabbitMQ** (Event streaming and messaging)

### Frontend (Next.js 14+)
- **React 18** with modern hooks and context
- **TypeScript** for type safety
- **Next.js App Router** with SSR/SSG capabilities
- **Tailwind CSS** for styling
- **Redux Toolkit** for state management

### Infrastructure & DevOps
- **Docker** + **Docker Compose** (Containerization)
- **Kubernetes** + **Helm** (Orchestration)
- **Terraform** (Infrastructure as Code)
- **GitHub Actions** (CI/CD)
- **Prometheus** + **Grafana** (Metrics and dashboards)
- **Jaeger** (Distributed tracing)
- **ELK Stack** (Centralized logging)
- **SonarQube** (Code quality)

### Cloud & AWS
- **AWS Lambda** (Serverless functions)
- **LocalStack** (AWS services simulation)
- **S3** (Object storage)
- **SQS** (Message queuing)
- **EventBridge** (Event routing)
- **DynamoDB** (NoSQL database)

### Testing & Quality
- **JUnit 5** + **TestContainers** (Integration testing)
- **Cucumber** (Behavior-driven development)
- **JMeter/Gatling** (Performance testing)
- **OWASP Dependency Check** (Security scanning)
- **JaCoCo** (Code coverage - 80% target)

### Modern Practices
- **GitOps** workflow with feature branches
- **Code Formatting**: Prettier, ESLint
- **Architecture Compliance**: ArchUnit

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Environments**: Dev, Staging, Prod
- **Strategies**: Blue-Green, Canary Deployments
- **Quality Gates**: Automated testing, security scans

## 🏛️ Architecture Principles

This project demonstrates **both architectural approaches** with their trade-offs:

### **Microservices Architecture**
- **Database Per Service**: Each microservice owns its data with PostgreSQL 18
- **Distributed Communication**: HTTP/REST APIs and messaging between services
- **Independent Deployment**: Services can be deployed separately
- **Technology Diversity**: Each service can use different tech stacks
- **Fault Isolation**: Service failures don't cascade

### **Modular Monolith Architecture (BFF Service)**
- **Shared Database**: Single database with module-specific schemas
- **Internal Communication**: Direct Java imports and Spring Events
- **Single Deployment**: All modules deployed together
- **Consistent Technology**: Unified tech stack across modules
- **ACID Transactions**: Cross-module transactions within single JVM

### **Common Patterns (Both Architectures)**
- **Event Sourcing**: Complete audit trail and event replay capabilities
- **CQRS**: Separate read/write models for optimal performance
- **SAGA Coordination**: Distributed transaction management
- **Clean Architecture**: Dependency inversion and testable code
- **Security First**: Multi-authentication (Basic, JWT, OAuth2)
- **Observability**: Comprehensive metrics, tracing, and logging
- **Resilience**: Circuit breakers, retry policies, bulkhead isolation

## 🏗️ Project Structure

```
project-frankenstein/
├── services/
│   ├── user-service/           # User management and authentication (Microservice)
│   ├── inventory-service/      # Product catalog and stock management (Microservice)
│   ├── order-service/          # Order processing and fulfillment (Microservice)
│   ├── payment-service/        # Payment processing and external integrations (Clean Architecture)
│   ├── notification-service/   # Multi-channel notifications (Traditional MVC Architecture)
│   ├── bff-service/           # **Modular Monolith** - Frontend aggregation with internal modules
│   │   ├── user-aggregation/   # User data aggregation and caching (internal module)
│   │   ├── order-aggregation/  # Order data aggregation and workflow (internal module)  
│   │   ├── inventory-aggregation/ # Product catalog aggregation (internal module)
│   │   └── analytics-aggregation/ # Cross-service analytics (internal module)
│   ├── frontend-service/       # Next.js React application (Phase 4)
│   ├── realtime-service/      # WebSocket and real-time features (Phase 6)
│   ├── video-processing-ec2-service/    # Video processing on EC2 (Phase 7)
│   └── video-processing-fargate-service/ # Serverless video processing (Phase 7)
├── aws-services/
│   ├── analytics-lambda/      # AWS Lambda functions (Phase 7)
│   ├── notification-lambda/   # Notification processing (Phase 7)
│   └── operations-lambda/     # Operational tasks (Phase 7)
├── infrastructure/
│   ├── docker/               # Database initialization and configs
│   ├── kubernetes/           # K8s manifests and Helm charts
│   ├── localstack/          # AWS services simulation + secrets management
│   ├── terraform/           # Infrastructure as Code
│   ├── monitoring/          # Prometheus, Grafana configs
│   └── service-mesh/        # Istio configurations
├── config/
│   ├── spring-cloud-config/  # Centralized configuration (Phase 3)
│   ├── dev/                  # Dev environment
│   ├── staging/              # Staging environment  
│   └── prod/                 # Prod environment
├── scripts/
│   ├── setup/               # Environment setup scripts
│   ├── deployment/          # Deployment automation
│   └── testing/             # Test execution scripts
├── docs/
│   ├── api/                 # API documentation
│   ├── architecture/        # Architecture decision records
│   └── deployment/          # Deployment guides
└── README.md
```

## 🚀 Getting Started

### Local Development Setup

1. **Prerequisites**: Docker, Docker Compose, Java 21, Maven, Node.js 18+

2. **Environment Setup** (Required):
```bash
# 1. Create environment secrets
cd infrastructure/localstack
./setup-env.sh dev        # Creates secrets.dev.env
# Edit secrets.dev.env and replace CHANGE_ME values with real passwords

# 2. Start project with environment
cd ../..
./scripts/start-with-env.sh dev
```


4. **Load Secrets into LocalStack**:
```bash
cd infrastructure/localstack
./secrets-setup.sh dev
```

## 🔐 Environment Management

**Environment-specific secrets** are managed securely:

### Create Environment Files:
```bash
cd infrastructure/localstack
./setup-env.sh dev      # Development environment
./setup-env.sh staging  # Staging environment
./setup-env.sh prod     # Production environment
```

### Start with Specific Environment:
```bash
./scripts/start-with-env.sh dev      # Development
./scripts/start-with-env.sh staging  # Staging  
./scripts/start-with-env.sh prod     # Production
```

### Security Features:
- ✅ **No hardcoded secrets** in committed code
- ✅ **Environment separation** (dev/staging/prod)
- ✅ **Automatic .env gitignore** protection
- ✅ **Strong password generation** guidance

## 🧪 Development

### Building
```bash
# Build all services
mvn clean compile

# Build specific service
cd services/user-service
mvn clean compile
```

### Testing
```bash
# Run all tests
mvn test

# Run with coverage
mvn test jacoco:report
```

### Code Quality
```bash
# Run SonarQube analysis
mvn sonar:sonar

# Check coverage threshold
mvn jacoco:check
```

## 🚀 Deployment

### Dev
```bash
./scripts/start-with-env.sh dev
```

### Staging
```bash
./scripts/start-with-env.sh staging
```

### Prod  
```bash
./scripts/start-with-env.sh prod
```

## 📚 Learning Objectives

By completing this project, you will gain hands-on experience with:

### Backend Development
- Spring Boot ecosystem and microservices patterns
- **Clean Architecture vs Traditional MVC comparison**
- **Modular monolith architecture with internal modules**
- **Direct imports vs HTTP communication trade-offs**
- **Internal messaging with Spring Events**
- **Layered architecture patterns and dependency management**
- Event-driven architecture and messaging (external and internal)
- Database design with PostgreSQL 18 and UUID v7
- CQRS and Event Sourcing implementation
- **Distributed transactions with SAGA and Two-Phase Commit (2PC) patterns**
- **Transaction consistency vs performance trade-offs**
- Multi-authentication strategies (Basic, JWT, OAuth2)

### Infrastructure & DevOps
- **Docker containerization** of Spring Boot services
- Container orchestration with Docker Compose
- **Infrastructure as Code comparison (AWS CDK vs Terraform vs SAM)**
- **AWS CDK for complex video processing infrastructure**
- CI/CD pipeline design and automation
- Comprehensive monitoring and observability

### Modern Java Features & Architecture Patterns
- **Java 21 LTS**: Records, Virtual Threads, Pattern Matching
- Structured Concurrency for coordinated processing
- String Templates and Sequenced Collections
- **Modular Monolith vs Microservices**: Direct comparison of architectural approaches
- **Internal vs External Communication**: Spring Events vs HTTP/Messaging

### Cloud Technologies
- AWS services simulation with LocalStack
- Serverless architecture with Lambda functions
- Message queuing and event processing
- Distributed system patterns and practices

## 🎯 Current Phase: Phase 2 - Core Services Development

**Phase 1 Completed** ✅:
- [x] Project structure and comprehensive documentation  
- [x] Maven multi-module build system with all dependencies
- [x] Complete Docker infrastructure stack (PostgreSQL, MongoDB, Redis, RabbitMQ, Kafka, LocalStack, ELK, Prometheus, Grafana, SonarQube)
- [x] Monitoring and observability configuration
- [x] **Environment-based secrets management** with dev/staging/prod separation
- [x] **Complete secret externalization** - zero hardcoded secrets
- [x] Dev environment automation

**Phase 2 Next Steps** 🔄:
- [ ] Domain design and entity modeling (DDD approach)
- [ ] **Modular monolith implementation** (platform-service with internal modules)
- [ ] **Microservices implementation** (distributed services with HTTP/messaging)
- [ ] **Architecture comparison** - direct imports vs distributed communication
- [ ] Database layer with Flyway migrations  
- [ ] Repository and service layer implementation
- [ ] **Docker containerization** of all Spring Boot services
- [ ] REST API development with OpenAPI documentation
- [ ] Multi-authentication security implementation
- [ ] **Centralized logging integration** (Spring Boot → ELK stack)
- [ ] Java 21 modern features integration
- [ ] Comprehensive testing with 80% code coverage

## 🔗 Useful Links

- **Documentation**: `/docs` directory for detailed guides
- **API Docs**: Available via Swagger UI (when services are running)
- **Monitoring**: Grafana dashboards for metrics and logs
- **Code Quality**: SonarQube reports for code analysis

## 🤝 Contributing

1. Follow the phase-based development approach
2. Maintain 80%+ test coverage
3. Use conventional commits
4. Update documentation for new features
5. **Never commit secrets** - use environment variables

---

**Ready to build something amazing? Let's get started with Phase 2!** 🚀