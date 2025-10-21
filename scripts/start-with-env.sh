#!/bin/bash

# Start Frankenstein project with environment-specific configuration
echo "🚀 Starting Frankenstein Project with Environment Configuration"

# Helper functions
print_status() { echo "✅ $1"; }
print_error() { echo "❌ $1"; }
print_warning() { echo "⚠️  $1"; }

ENVIRONMENT="${1:-dev}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_FILE="${PROJECT_ROOT}/.env.${ENVIRONMENT}"

echo "🔍 Checking prerequisites..."

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

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi
print_status "Docker daemon is running"

# Validate environment
case "$ENVIRONMENT" in
    "dev"|"staging"|"prod") ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|staging|prod]"
        echo "Default: dev"
        exit 1
        ;;
esac

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "❌ Environment file not found: $SECRETS_FILE"
    echo "Run: cd infrastructure/localstack && ./setup-env.sh $ENVIRONMENT"
    exit 1
fi

echo "📁 Loading environment variables from secrets.${ENVIRONMENT}.env..."

# Load environment variables and start services
set -a  # Automatically export all variables
source "$SECRETS_FILE"
set +a  # Stop auto-export

echo "🐳 Starting Docker Compose for $ENVIRONMENT environment..."

# Start core infrastructure first
echo "Starting databases and infrastructure..."
docker-compose up -d user-db inventory-db order-db payment-db notification-db analytics-db infrastructure-db

# Start message queues and caching
echo "Starting messaging and cache..."
docker-compose up -d redis rabbitmq kafka zookeeper mongodb

# Start monitoring stack
echo "Starting monitoring stack..."
docker-compose up -d prometheus grafana jaeger elasticsearch kibana logstash filebeat

# Start development tools
echo "Starting development tools..."
docker-compose up -d localstack sonarqube unleash

# Start application services (when ready in Phase 2)
# docker-compose up -d user-service inventory-service order-service payment-service notification-service bff-service

echo ""
echo ""
echo "✅ Frankenstein project started for $ENVIRONMENT environment!"
echo ""
echo "🔗 Service URLs:"
echo "  • Grafana: http://localhost:3001 (admin / see .env.$ENVIRONMENT)"
echo "  • Prometheus: http://localhost:9090"
echo "  • Kibana: http://localhost:5601"
echo "  • Jaeger: http://localhost:16686"
echo "  • SonarQube: http://localhost:9000"
echo "  • Unleash: http://localhost:4242"
echo "  • RabbitMQ: http://localhost:15672 (credentials in .env.$ENVIRONMENT)"
echo "  • LocalStack: http://localhost:4566"
echo ""
echo "📝 Next steps:"
echo "  1. Check all services: docker-compose ps"
echo "  2. View logs: docker-compose logs -f [service-name]"
echo "  3. Load secrets to LocalStack: cd infrastructure/localstack && ./secrets-setup.sh $ENVIRONMENT"
echo ""
echo "🔧 Optional verification commands:"
echo "  • Check Java: java --version"
echo "  • Check Maven: mvn --version"
