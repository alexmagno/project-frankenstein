# LocalStack Secrets Management

Environment-specific secrets management for the Frankenstein project.

## 🔒 Approach

- **Environment separation**: Different secrets per environment  
- **Project-wide usage**: Environment files in project root (not LocalStack-specific)
- **Template-based**: Scripts create templates, you add real secrets
- **Git-safe**: No secrets in committed code

## 🚀 Quick Start

### 1. Create Environment Files (in project root)
```bash
./setup-env.sh dev      # Creates ../../.env.dev
./setup-env.sh staging  # Creates ../../.env.staging  
./setup-env.sh prod     # Creates ../../.env.prod
```

### 2. Edit Your Secrets (in project root)
```bash
# Go to project root
cd ../..
vim .env.dev            # Edit development secrets
vim .env.staging        # Edit staging secrets
vim .env.prod           # Edit production secrets
```

### 3. Start Project with Environment
```bash
# From project root
./scripts/start-with-env.sh dev      # Development
./scripts/start-with-env.sh staging  # Staging
./scripts/start-with-env.sh prod     # Production
```

### 4. Load Secrets into LocalStack
```bash
# From LocalStack directory
cd infrastructure/localstack
./secrets-setup.sh dev      # Load dev secrets
./secrets-setup.sh staging  # Load staging secrets
./secrets-setup.sh prod     # Load prod secrets
```

## 📁 Files

- **`setup-env.sh`** - Creates .env.{environment} files in project root
- **`secrets-setup.sh`** - Loads environment files into LocalStack  
- **`../../.env.dev`** - Dev environment secrets (gitignored)
- **`../../.env.staging`** - Staging environment secrets (gitignored) 
- **`../../.env.prod`** - Prod environment secrets (gitignored)

## 🔐 Usage Across Project

**Environment files are used by:**
- ✅ **docker-compose.yml** - Database passwords, service configs
- ✅ **PostgreSQL init scripts** - Database user creation
- ✅ **LocalStack setup** - AWS secrets management
- ✅ **Spring Boot services** - Application configuration
- ✅ **All infrastructure** - Unified secret management

## 🛡️ Security

✅ **Safe to commit:**
- `setup-env.sh` - Only creates templates with 'CHANGE_ME' placeholders
- `secrets-setup.sh` - Loads variables, contains no secrets

❌ **Never commit:**
- `../../.env.dev` - Contains real dev secrets
- `../../.env.staging` - Contains real staging secrets  
- `../../.env.prod` - Contains real prod secrets

## 🔧 Generate Secure Passwords

```bash
# Single password
openssl rand -base64 32

# Multiple passwords
for i in {1..10}; do echo "Password $i: $(openssl rand -base64 32)"; done
```

## 🔍 Verify Secrets in LocalStack

```bash
# List secrets
aws secretsmanager list-secrets --endpoint-url=http://localhost:4566

# Get specific secret
aws secretsmanager get-secret-value \
  --secret-id "frankenstein/database/user-service" \
  --endpoint-url=http://localhost:4566
```