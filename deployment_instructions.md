# Deployment Instructions for Google Cloud Run

## Prerequisites

1. Google Cloud SDK installed and configured
2. Docker installed locally
3. A Google Cloud Project with billing enabled
4. Required APIs enabled:
   - Cloud Run API
   - Secret Manager API
   - Container Registry API or Artifact Registry API

## Local Development Setup

### 1. Install Required R Packages

```r
install.packages(c("shiny", "config", "bslib"))
```

### 2. Set Up Environment Variables

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` and fill in your actual secret values.

### 3. Load Environment Variables and Run Locally

**On Windows (PowerShell):**
```powershell
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}
```

**On Unix/Mac/Linux:**
```bash
export $(cat .env | xargs)
```

**Run the app:**
```r
# In R console
R_CONFIG_ACTIVE=prod shiny::runApp()
```

Or from command line:
```bash
R -e "shiny::runApp(port=8080, host='0.0.0.0')"
```

## Google Cloud Run Deployment

### Step 1: Set Up Google Cloud Project

```bash
# Login to Google Cloud
gcloud auth login

# Set your project ID
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 2: Create Secrets in Google Secret Manager

Create each secret individually:

```bash
# Database secrets
echo -n "your-mysql-host" | gcloud secrets create MySQL_HOST --data-file=-
echo -n "your-mysql-user" | gcloud secrets create MySQL_USER --data-file=-
echo -n "your-mysql-password" | gcloud secrets create MySQL_PASS --data-file=-
echo -n "your-database-name" | gcloud secrets create MySQL_DB --data-file=-
echo -n "3306" | gcloud secrets create MySQL_PORT --data-file=-

# API secrets
echo -n "your-api-key" | gcloud secrets create P_API_KEY --data-file=-

# Email secrets
echo -n "your-email@example.com" | gcloud secrets create EMAIL_USERNAME --data-file=-
echo -n "your-email-password" | gcloud secrets create EMAIL_PWD --data-file=-
echo -n "pagos@example.com" | gcloud secrets create EMAIL_PAGOS_USER --data-file=-
echo -n "pagos-password" | gcloud secrets create EMAIL_PAGOS_PWD --data-file=-
echo -n "smtp.gmail.com" | gcloud secrets create EMAIL_SMTP --data-file=-

# Auth0 secrets
echo -n "your-auth0-user" | gcloud secrets create AUTH0_USER --data-file=-
echo -n "your-auth0-key" | gcloud secrets create AUTH0_KEY --data-file=-
echo -n "your-auth0-secret" | gcloud secrets create AUTH0_SECRET --data-file=-

# LLM API
echo -n "your-llm-api-key" | gcloud secrets create LLM_API --data-file=-
```

**Alternative: Bulk create from .env file**

```bash
# Read from .env and create secrets
while IFS='=' read -r key value; do
  # Skip comments and empty lines
  [[ "$key" =~ ^#.*$ ]] || [[ -z "$key" ]] && continue
  # Skip R_CONFIG_ACTIVE
  [[ "$key" == "R_CONFIG_ACTIVE" ]] && continue
  
  echo "Creating secret: $key"
  echo -n "$value" | gcloud secrets create "$key" --data-file=- 2>/dev/null || \
  echo -n "$value" | gcloud secrets versions add "$key" --data-file=-
done < .env
```

### Step 3: Build and Push Docker Image

**Option A: Using Google Container Registry (GCR)**

```bash
# Set image name
export IMAGE_NAME="gcr.io/$PROJECT_ID/env-variables-app"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker

# Push the image
docker push $IMAGE_NAME
```

**Option B: Using Google Artifact Registry (Recommended)**

```bash
# Create repository (one-time setup)
gcloud artifacts repositories create shiny-apps \
    --repository-format=docker \
    --location=us-central1 \
    --description="Shiny applications"

# Set image name
export REGION="us-central1"
export IMAGE_NAME="$REGION-docker.pkg.dev/$PROJECT_ID/shiny-apps/env-variables-app"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Configure Docker authentication
gcloud auth configure-docker $REGION-docker.pkg.dev

# Push the image
docker push $IMAGE_NAME
```

### Step 4: Deploy to Cloud Run

```bash
gcloud run deploy env-variables-app \
    --image=$IMAGE_NAME \
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --set-secrets="MySQL_HOST=MySQL_HOST:latest,\
MySQL_USER=MySQL_USER:latest,\
MySQL_PASS=MySQL_PASS:latest,\
MySQL_DB=MySQL_DB:latest,\
MySQL_PORT=MySQL_PORT:latest,\
P_API_KEY=P_API_KEY:latest,\
EMAIL_USERNAME=EMAIL_USERNAME:latest,\
EMAIL_PWD=EMAIL_PWD:latest,\
EMAIL_PAGOS_USER=EMAIL_PAGOS_USER:latest,\
EMAIL_PAGOS_PWD=EMAIL_PAGOS_PWD:latest,\
EMAIL_SMTP=EMAIL_SMTP:latest,\
AUTH0_USER=AUTH0_USER:latest,\
AUTH0_KEY=AUTH0_KEY:latest,\
AUTH0_SECRET=AUTH0_SECRET:latest,\
LLM_API=LLM_API:latest" \
    --set-env-vars="R_CONFIG_ACTIVE=prod" \
    --memory=1Gi \
    --cpu=1 \
    --timeout=300 \
    --max-instances=10 \
    --min-instances=0
```

**Note:** If you want to restrict access, remove `--allow-unauthenticated` and add authentication.

### Step 5: Verify Deployment

```bash
# Get the service URL
gcloud run services describe env-variables-app \
    --platform=managed \
    --region=us-central1 \
    --format='value(status.url)'
```

Visit the URL in your browser to see your application.

## Updating Secrets

To update a secret value:

```bash
echo -n "new-secret-value" | gcloud secrets versions add SECRET_NAME --data-file=-
```

Then redeploy the Cloud Run service to use the new secret version:

```bash
gcloud run services update env-variables-app \
    --region=us-central1 \
    --platform=managed
```

## Troubleshooting

### View Logs

```bash
gcloud run services logs read env-variables-app \
    --region=us-central1 \
    --limit=50
```

### Test Docker Image Locally with Secrets

```bash
docker run -p 8080:8080 \
    -e MySQL_HOST="localhost" \
    -e MySQL_USER="testuser" \
    -e MySQL_PASS="testpass" \
    -e MySQL_DB="testdb" \
    -e MySQL_PORT="3306" \
    -e P_API_KEY="test-key" \
    -e EMAIL_USERNAME="test@example.com" \
    -e EMAIL_PWD="testpwd" \
    -e EMAIL_PAGOS_USER="pagos@example.com" \
    -e EMAIL_PAGOS_PWD="pagospwd" \
    -e EMAIL_SMTP="smtp.gmail.com" \
    -e AUTH0_USER="auth0user" \
    -e AUTH0_KEY="auth0key" \
    -e AUTH0_SECRET="auth0secret" \
    -e LLM_API="llm-api-key" \
    -e R_CONFIG_ACTIVE="prod" \
    $IMAGE_NAME
```

Then visit http://localhost:8080

### Grant Service Account Access to Secrets

If you encounter permission errors, ensure the Cloud Run service account has access:

```bash
# Get the service account email
export SERVICE_ACCOUNT=$(gcloud run services describe env-variables-app \
    --region=us-central1 \
    --format='value(spec.template.spec.serviceAccountName)')

# Grant access to all secrets
for secret in MySQL_HOST MySQL_USER MySQL_PASS MySQL_DB MySQL_PORT P_API_KEY \
              EMAIL_USERNAME EMAIL_PWD EMAIL_PAGOS_USER EMAIL_PAGOS_PWD EMAIL_SMTP \
              AUTH0_USER AUTH0_KEY AUTH0_SECRET LLM_API; do
    gcloud secrets add-iam-policy-binding $secret \
        --member="serviceAccount:$SERVICE_ACCOUNT" \
        --role="roles/secretmanager.secretAccessor"
done
```

## Continuous Deployment

For CI/CD integration, you can use Cloud Build:

**cloudbuild.yaml:**
```yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/env-variables-app', '.']
  
  # Push the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/env-variables-app']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'env-variables-app'
      - '--image=gcr.io/$PROJECT_ID/env-variables-app'
      - '--region=us-central1'
      - '--platform=managed'
images:
  - 'gcr.io/$PROJECT_ID/env-variables-app'
```

## Security Best Practices

1. **Never commit `.env` files** - They contain sensitive data
2. **Use Secret Manager** - Store all secrets in Google Secret Manager, not environment variables directly
3. **Limit IAM permissions** - Only grant necessary permissions to service accounts
4. **Enable authentication** - Remove `--allow-unauthenticated` for production apps
5. **Rotate secrets regularly** - Update secrets periodically
6. **Monitor access** - Review Cloud Run and Secret Manager audit logs
7. **Use least privilege** - Grant minimal permissions to service accounts

## Cost Optimization

- Set `--min-instances=0` to scale to zero when not in use
- Set appropriate `--max-instances` to control costs
- Use `--cpu-throttling` for CPU allocation
- Monitor usage in Google Cloud Console

## Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [R Shiny Documentation](https://shiny.rstudio.com/)
- [Config Package Documentation](https://cran.r-project.org/web/packages/config/vignettes/introduction.html)
