#!/bin/bash

echo "🧪 Project Frankenstein - Development Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check prerequisites
print_header "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_status "Docker found: $(docker --version)"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_status "Docker Compose found: $(docker-compose --version)"

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java 17+ is required. Please install Java first."
    exit 1
fi
print_status "Java found: $(java -version 2>&1 | head -1)"

# Check Maven
if ! command -v mvn &> /dev/null; then
    print_error "Maven is not installed. Please install Maven first."
    exit 1
fi
print_status "Maven found: $(mvn -version | head -1)"

# Check kubectl (optional)
if command -v kubectl &> /dev/null; then
    print_status "Kubectl found: $(kubectl version --client --short 2>/dev/null || echo 'kubectl available')"
else
    print_warning "kubectl not found. Kubernetes features will not be available."
fi

# Check Helm (optional)
if command -v helm &> /dev/null; then
    print_status "Helm found: $(helm version --short 2>/dev/null || echo 'helm available')"
else
    print_warning "Helm not found. Helm charts will not be deployable."
fi

print_header "Setting up development environment..."

# Create necessary directories
print_status "Creating directories..."
mkdir -p logs data/postgres data/mongodb data/redis

# Set permissions
print_status "Setting permissions..."
chmod +x scripts/deployment/*.sh
chmod +x scripts/testing/*.sh

# Start infrastructure services
print_status "Starting infrastructure services..."
docker-compose up -d postgres mongodb redis rabbitmq zookeeper kafka localstack

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check service health
print_header "Checking service health..."

# PostgreSQL
if docker-compose exec -T postgres pg_isready -U frankenstein >/dev/null 2>&1; then
    print_status "PostgreSQL is ready"
else
    print_warning "PostgreSQL might not be ready yet"
fi

# MongoDB
if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
    print_status "MongoDB is ready"
else
    print_warning "MongoDB might not be ready yet"
fi

# Redis
if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
    print_status "Redis is ready"
else
    print_warning "Redis might not be ready yet"
fi

# RabbitMQ
if docker-compose exec -T rabbitmq rabbitmq-diagnostics -q ping >/dev/null 2>&1; then
    print_status "RabbitMQ is ready"
else
    print_warning "RabbitMQ might not be ready yet"
fi

# Build the project
print_header "Building the project..."
if mvn clean compile -q; then
    print_status "Project built successfully"
else
    print_error "Failed to build project"
    exit 1
fi

print_header "Development environment setup completed!"
echo
print_status "Services available at:"
echo "  • PostgreSQL: localhost:5432"
echo "  • MongoDB: localhost:27017"
echo "  • Redis: localhost:6379"
echo "  • RabbitMQ Management: http://localhost:15672 (frankenstein/frankenstein123)"
echo "  • Kafka: localhost:9092"
echo "  • LocalStack: http://localhost:4566"
echo
print_status "To start the monitoring stack:"
echo "  docker-compose up -d prometheus grafana jaeger elasticsearch kibana logstash"
echo
print_status "To start a service:"
echo "  mvn spring-boot:run -pl services/user-service"
echo "  mvn spring-boot:run -pl services/product-service"
echo "  mvn spring-boot:run -pl services/order-service"
echo "  mvn spring-boot:run -pl config/spring-cloud-config"
echo
print_status "Happy coding! 🚀"
