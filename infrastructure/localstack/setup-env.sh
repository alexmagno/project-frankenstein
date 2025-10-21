#!/bin/bash

# Create environment-specific secrets files for Frankenstein project
echo "🔐 Setting up secrets for environment..."

ENVIRONMENT="${1:-dev}"
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

# Check if file exists
if [ -f "$SECRETS_FILE" ]; then
    echo "⚠️  .env.${ENVIRONMENT} already exists!"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
fi

# Create environment-specific template
if [ "$ENVIRONMENT" = "dev" ]; then
    cat > "$SECRETS_FILE" << 'EOF'
# Frankenstein Project Secrets - DEV Environment
# Ready-to-use development passwords

# Database Datasource Passwords - Dev environment
USER_SERVICE_DATASOURCE_PASSWORD=userservice123
INVENTORY_SERVICE_DATASOURCE_PASSWORD=inventoryservice123
ORDER_SERVICE_DATASOURCE_PASSWORD=orderservice123
PAYMENT_SERVICE_DATASOURCE_PASSWORD=paymentservice123
NOTIFICATION_SERVICE_DATASOURCE_PASSWORD=notificationservice123
ANALYTICS_SERVICE_DATASOURCE_PASSWORD=analytics123

# SAGA Passwords - Dev environment
USER_SAGA_PASSWORD=usersaga123
INVENTORY_SAGA_PASSWORD=inventorysaga123
ORDER_SAGA_PASSWORD=ordersaga123
PAYMENT_SAGA_PASSWORD=paymentsaga123
NOTIFICATION_SAGA_PASSWORD=notificationsaga123
ANALYTICS_SAGA_PASSWORD=analyticssaga123

# Infrastructure - Dev environment  
SONARQUBE_JDBC_PASSWORD=sonarqube123
UNLEASH_JDBC_PASSWORD=unleash123
UNLEASH_FRONTEND_TOKEN=default:dev.unleash-insecure-frontend-api-token
UNLEASH_CLIENT_TOKEN=default:dev.unleash-insecure-api-token
MONGODB_PASSWORD=frankenstein123
GRAFANA_ADMIN_PASSWORD=admin123
INFRASTRUCTURE_DB_PASSWORD=postgres123
SAGA_COORDINATOR_PASSWORD=coordinator123
SAGA_PARTICIPANT_PASSWORD=participant123

# Infrastructure Secrets Only
RABBITMQ_PASSWORD=guest

# External APIs - Use test keys for dev
PAYMENT_PROVIDER_API_KEY=pk_test_dev_51234567890
EMAIL_SERVICE_API_KEY=sg_dev_12345abcdef
SMS_SERVICE_API_KEY=AC_dev_1234567890abcdef
GOOGLE_ANALYTICS_ID=GA_DEV_MEASUREMENT_ID

# JWT Keys - Dev keys (not secure)
JWT_SIGNING_KEY=dev-jwt-signing-key-not-secure
JWT_REFRESH_KEY=dev-refresh-token-key-not-secure

# AWS/LocalStack Configuration
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_REGION=us-east-1
LOCALSTACK_ENDPOINT=http://localhost:4566
S3_IMAGES_BUCKET=frankenstein-dev-images
S3_VIDEOS_BUCKET=frankenstein-dev-videos
EOF

elif [ "$ENVIRONMENT" = "staging" ]; then
    cat > "$SECRETS_FILE" << 'EOF'
# Frankenstein Project Secrets - STAGING Environment
# Production-like strong passwords

# Database Datasource Passwords - Staging environment
USER_SERVICE_DATASOURCE_PASSWORD=stg_user_67f8e9a2b3c4d5e6f7a8b9c0
INVENTORY_SERVICE_DATASOURCE_PASSWORD=stg_inventory_89b0c1d2e3f4a5b6c7d8e9f0
ORDER_SERVICE_DATASOURCE_PASSWORD=stg_order_01d2e3f4a5b6c7d8e9f0a1b2
PAYMENT_SERVICE_DATASOURCE_PASSWORD=stg_payment_23f4a5b6c7d8e9f0a1b2c3d4
NOTIFICATION_SERVICE_DATASOURCE_PASSWORD=stg_notification_45b6c7d8e9f0a1b2c3d4e5f6
ANALYTICS_SERVICE_DATASOURCE_PASSWORD=stg_analytics_67d8e9f0a1b2c3d4e5f6a7b8

# SAGA Passwords - Staging environment
USER_SAGA_PASSWORD=stg_saga_user_78a9b0c1d2e3f4a5b6c7d8e9
INVENTORY_SAGA_PASSWORD=stg_saga_inventory_90c1d2e3f4a5b6c7d8e9f0a1
ORDER_SAGA_PASSWORD=stg_saga_order_12e3f4a5b6c7d8e9f0a1b2c3
PAYMENT_SAGA_PASSWORD=stg_saga_payment_34a5b6c7d8e9f0a1b2c3d4e5
NOTIFICATION_SAGA_PASSWORD=stg_saga_notification_56c7d8e9f0a1b2c3d4e5f6a7
ANALYTICS_SAGA_PASSWORD=stg_saga_analytics_78e9f0a1b2c3d4e5f6a7b8c9

# Infrastructure - Staging environment  
SONARQUBE_JDBC_PASSWORD=stg_sonar_89f0a1b2c3d4e5f6a7b8c9d0
UNLEASH_JDBC_PASSWORD=stg_unleash_90a1b2c3d4e5f6a7b8c9d0e1
UNLEASH_FRONTEND_TOKEN=default:staging.unleash-secure-frontend-token
UNLEASH_CLIENT_TOKEN=default:staging.unleash-secure-client-token
MONGODB_PASSWORD=stg_mongo_01b2c3d4e5f6a7b8c9d0e1f2
GRAFANA_ADMIN_PASSWORD=stg_grafana_b2c3d4e5f6a7b8c9d0e1f2a3
INFRASTRUCTURE_DB_PASSWORD=stg_postgres_c3d4e5f6a7b8c9d0e1f2a3b4
SAGA_COORDINATOR_PASSWORD=stg_saga_coord_d4e5f6a7b8c9d0e1f2a3b4c5
SAGA_PARTICIPANT_PASSWORD=stg_saga_part_e5f6a7b8c9d0e1f2a3b4c5d6

# Infrastructure Secrets Only
RABBITMQ_PASSWORD=stg_rabbit_f6a7b8c9d0e1f2a3b4c5d6e7

# External APIs - Staging keys
PAYMENT_PROVIDER_API_KEY=pk_test_staging_abcdef123456
EMAIL_SERVICE_API_KEY=sg_staging_fedcba654321
SMS_SERVICE_API_KEY=AC_staging_123456abcdef
GOOGLE_ANALYTICS_ID=GA_STAGING_MEASUREMENT_ID

# JWT Keys - Staging security
JWT_SIGNING_KEY=staging-jwt-key-b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7
JWT_REFRESH_KEY=staging-refresh-key-c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8

# AWS/LocalStack Configuration
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_REGION=us-east-1
LOCALSTACK_ENDPOINT=http://staging-localstack:4566
S3_IMAGES_BUCKET=frankenstein-staging-images
S3_VIDEOS_BUCKET=frankenstein-staging-videos
EOF

else # prod environment
    cat > "$SECRETS_FILE" << 'EOF'
# Frankenstein Project Secrets - PROD Environment
# CHANGE ALL PASSWORDS TO STRONG VALUES BEFORE USE!

# Database Datasource Passwords - Production (GENERATE STRONG PASSWORDS!)
USER_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
INVENTORY_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
ORDER_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
PAYMENT_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
NOTIFICATION_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
ANALYTICS_SERVICE_DATASOURCE_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS

# SAGA Passwords - Production (GENERATE STRONG PASSWORDS!)
USER_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
INVENTORY_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
ORDER_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
PAYMENT_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
NOTIFICATION_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
ANALYTICS_SAGA_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS

# Infrastructure - Production (GENERATE STRONG PASSWORDS!)
SONARQUBE_JDBC_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
UNLEASH_JDBC_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
UNLEASH_FRONTEND_TOKEN=default:prod.unleash-GENERATE-SECURE-FRONTEND-TOKEN
UNLEASH_CLIENT_TOKEN=default:prod.unleash-GENERATE-SECURE-CLIENT-TOKEN
MONGODB_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
GRAFANA_ADMIN_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
INFRASTRUCTURE_DB_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
SAGA_COORDINATOR_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS
SAGA_PARTICIPANT_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS

# Infrastructure Secrets Only
RABBITMQ_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32_CHARS

# External APIs - Production (REAL API KEYS!)
PAYMENT_PROVIDER_API_KEY=pk_live_REAL_PRODUCTION_KEY
EMAIL_SERVICE_API_KEY=sg_REAL_SENDGRID_PRODUCTION_KEY
SMS_SERVICE_API_KEY=AC_REAL_TWILIO_PRODUCTION_KEY
GOOGLE_ANALYTICS_ID=GA_REAL_PRODUCTION_MEASUREMENT_ID

# JWT Keys - Production (STRONG KEYS - 256 bits minimum)
JWT_SIGNING_KEY=CHANGE_ME_PRODUCTION_JWT_SIGNING_KEY_256_BITS
JWT_REFRESH_KEY=CHANGE_ME_PRODUCTION_REFRESH_KEY_256_BITS

# AWS Configuration - Production (Real AWS credentials needed)
AWS_ACCESS_KEY_ID=CHANGE_ME_REAL_AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=CHANGE_ME_REAL_AWS_SECRET_KEY
AWS_REGION=us-east-1
LOCALSTACK_ENDPOINT=
S3_IMAGES_BUCKET=frankenstein-prod-images
S3_VIDEOS_BUCKET=frankenstein-prod-videos

# Production Security Reminders:
# 1. Generate all passwords with: openssl rand -base64 32
# 2. Use real API keys from providers
# 3. Enable MFA on all accounts
# 4. Rotate secrets every 90 days
# 5. Never use LocalStack in production
EOF
fi

echo "✅ Created .env.${ENVIRONMENT} in project root"
echo "📝 IMPORTANT: Replace ALL 'CHANGE_ME' values with actual secrets"
echo "🔧 Generate passwords: openssl rand -base64 32"
