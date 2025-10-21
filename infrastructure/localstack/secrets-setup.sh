#!/bin/bash

# AWS Secrets Manager setup for LocalStack
ENVIRONMENT="${1:-dev}"
echo "🔐 Setting up AWS Secrets Manager for $ENVIRONMENT environment..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECRETS_FILE="${PROJECT_ROOT}/.env.${ENVIRONMENT}"

# Validate environment
case "$ENVIRONMENT" in
    "dev"|"staging"|"prod") ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|staging|prod]"
        exit 1
        ;;
esac

# Load secrets
if [ -f "$SECRETS_FILE" ]; then
    echo "Loading secrets from .env.${ENVIRONMENT}..."
    source "$SECRETS_FILE"
else
    echo "❌ .env.${ENVIRONMENT} not found in project root!"
    echo "Run './setup-env.sh $ENVIRONMENT' first to create the environment file."
    exit 1
fi

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
until curl -f http://localhost:4566/health > /dev/null 2>&1; do
    sleep 5
done

# Configure AWS CLI for LocalStack (using environment variables)
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_ENDPOINT_URL=${LOCALSTACK_ENDPOINT}

echo "Creating secrets in LocalStack Secrets Manager..."

# Database Per Service secrets (PostgreSQL 18 with UUID v7)
aws secretsmanager create-secret \
    --name "frankenstein/database/user-service" \
    --description "User service database credentials" \
    --secret-string '{
        "host": "user-db",
        "port": "5432",
        "database": "user_service_db",
        "username": "user_service",
        "password": "'$USER_SERVICE_PASSWORD'",
        "sagaUsername": "user_saga_coordinator",
        "sagaPassword": "'$USER_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/inventory-service" \
    --description "Inventory service database credentials" \
    --secret-string '{
        "host": "inventory-db",
        "port": "5433",
        "database": "inventory_service_db",
        "username": "inventory_service",
        "password": "'$INVENTORY_SERVICE_PASSWORD'",
        "sagaUsername": "inventory_saga_coordinator",
        "sagaPassword": "'$INVENTORY_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/order-service" \
    --description "Order service database credentials" \
    --secret-string '{
        "host": "order-db",
        "port": "5434",
        "database": "order_service_db",
        "username": "order_service",
        "password": "'$ORDER_SERVICE_PASSWORD'",
        "sagaUsername": "order_saga_coordinator",
        "sagaPassword": "'$ORDER_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/payment-service" \
    --description "Payment service database credentials" \
    --secret-string '{
        "host": "payment-db",
        "port": "5435",
        "database": "payment_service_db",
        "username": "payment_service",
        "password": "'$PAYMENT_SERVICE_PASSWORD'",
        "sagaUsername": "payment_saga_coordinator",
        "sagaPassword": "'$PAYMENT_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/notification-service" \
    --description "Notification service database credentials" \
    --secret-string '{
        "host": "notification-db",
        "port": "5437",
        "database": "notification_service_db",
        "username": "notification_service",
        "password": "'$NOTIFICATION_SERVICE_PASSWORD'",
        "sagaUsername": "notification_saga_coordinator",
        "sagaPassword": "'$NOTIFICATION_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/analytics-service" \
    --description "Analytics service database credentials (OLAP)" \
    --secret-string '{
        "host": "analytics-db",
        "port": "5438",
        "database": "analytics_db",
        "username": "analytics_service",
        "password": "'$ANALYTICS_SERVICE_PASSWORD'",
        "sagaUsername": "analytics_saga_coordinator",
        "sagaPassword": "'$ANALYTICS_SAGA_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/infrastructure" \
    --description "Infrastructure database credentials (SonarQube, Unleash)" \
    --secret-string '{
        "host": "infrastructure-db",
        "port": "5439",
        "database": "infrastructure_db",
        "sonarqubeUsername": "sonarqube_user",
        "sonarqubeJdbcPassword": "'$SONARQUBE_JDBC_PASSWORD'",
        "unleashUsername": "unleash_user",
        "unleashJdbcPassword": "'$UNLEASH_JDBC_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/database/mongodb" \
    --description "MongoDB read models database credentials" \
    --secret-string '{
        "host": "mongodb",
        "port": "27017",
        "database": "frankenstein_read_models",
        "username": "frankenstein",
        "password": "'$MONGODB_PASSWORD'"
    }' \
    --endpoint-url=http://localhost:4566

# Infrastructure services secrets
aws secretsmanager create-secret \
    --name "frankenstein/infrastructure/redis" \
    --description "Redis cache credentials" \
    --secret-string '{
        "host": "redis",
        "port": "6379",
        "password": "",
        "database": "0"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/infrastructure/rabbitmq" \
    --description "RabbitMQ message broker credentials" \
    --secret-string '{
        "host": "rabbitmq",
        "port": "5672",
        "managementPort": "15672",
        "username": "guest",
        "password": "guest",
        "vhost": "/"
    }' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name "frankenstein/infrastructure/kafka" \
    --description "Apache Kafka message streaming credentials" \
    --secret-string '{
        "bootstrapServers": "kafka:9092",
        "zookeeperHost": "zookeeper:2181",
        "topics": {
            "userEvents": "user-events",
            "orderEvents": "order-events", 
            "inventoryEvents": "inventory-events",
            "paymentEvents": "payment-events",
            "sagaEvents": "saga-coordination"
        }
    }' \
    --endpoint-url=http://localhost:4566

# External API keys
aws secretsmanager create-secret \
    --name "frankenstein/apis/external" \
    --description "External API keys and tokens" \
    --secret-string '{
        "paymentProviderApiKey": "'$PAYMENT_PROVIDER_API_KEY'",
        "emailServiceApiKey": "'$EMAIL_SERVICE_API_KEY'",
        "smsServiceApiKey": "'$SMS_SERVICE_API_KEY'",
        "googleAnalyticsId": "'$GOOGLE_ANALYTICS_ID'"
    }' \
    --endpoint-url=http://localhost:4566

# JWT signing secrets
aws secretsmanager create-secret \
    --name "frankenstein/jwt/signing-key" \
    --description "JWT token signing key" \
    --secret-string '{
        "signingKey": "'$JWT_SIGNING_KEY'",
        "refreshSigningKey": "'$JWT_REFRESH_KEY'",
        "algorithm": "HS512",
        "expirationMinutes": 60,
        "refreshExpirationDays": 7
    }' \
    --endpoint-url=http://localhost:4566

# S3 and processing configuration
aws secretsmanager create-secret \
    --name "frankenstein/aws/processing" \
    --description "AWS processing configuration" \
    --secret-string '{
        "s3BucketName": "'$S3_IMAGES_BUCKET'",
        "s3VideoBucketName": "'$S3_VIDEOS_BUCKET'",
        "imageProcessingConfig": {
            "thumbnailSize": "150x150",
            "maxImageSize": "5MB",
            "allowedFormats": ["JPEG", "PNG", "WebP"]
        },
        "videoProcessingConfig": {
            "maxVideoSize": "500MB",
            "allowedFormats": ["MP4", "AVI", "MOV", "WebM"],
            "outputFormats": ["MP4", "WebM"],
            "resolutions": ["480p", "720p", "1080p"],
            "thumbnailCount": 5
        },
        "presignedUrlExpirationHours": 24
    }' \
    --endpoint-url=http://localhost:4566

# Video processing service secrets
aws secretsmanager create-secret \
    --name "frankenstein/video-services/config" \
    --description "Video processing services configuration" \
    --secret-string '{
        "fargate": {
            "maxConcurrentJobs": 5,
            "memoryOptimized": true,
            "cachingEnabled": false,
            "autoScaling": true
        },
        "ec2": {
            "maxConcurrentJobs": 10,
            "memoryOptimized": false, 
            "cachingEnabled": true,
            "persistentStorage": true,
            "connectionPoolSize": 20
        },
        "shared": {
            "videoQualitySettings": {
                "high": {"bitrate": "5000k", "fps": 30},
                "medium": {"bitrate": "2500k", "fps": 25},
                "low": {"bitrate": "1000k", "fps": 20}
            }
        }
    }' \
    --endpoint-url=http://localhost:4566

echo "✅ All secrets created successfully in LocalStack Secrets Manager!"

# List created secrets for verification
echo "Created secrets:"
aws secretsmanager list-secrets --endpoint-url=http://localhost:4566 --query 'SecretList[].Name' --output table
