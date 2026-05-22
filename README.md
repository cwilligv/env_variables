# Environment Variables R Shiny Application

A demonstration R Shiny application that displays environment variables using the `config` package, designed to work both locally and on Google Cloud Run with Google Secret Manager integration.

## Features

- **Local Development**: Uses `.env` file for local testing
- **Production Ready**: Integrates with Google Cloud Run and Secret Manager
- **Secure Display**: Masks sensitive values in the UI
- **Config Management**: Uses R `config` package for environment-specific settings
- **Docker Support**: Fully containerized for cloud deployment

## Project Structure

```
.
├── ui.R                          # Shiny UI definition
├── server.R                      # Shiny server logic
├── config.yml                    # Config file with environment-specific settings
├── Dockerfile                    # Container definition for Cloud Run
├── .dockerignore                 # Docker ignore patterns
├── .env.example                  # Example environment variables (safe to commit)
├── .env                          # Actual secrets (DO NOT COMMIT)
├── deployment_instructions.md    # Detailed deployment guide
└── README.md                     # This file
```

## Quick Start - Local Development

### 1. Install Dependencies

```r
install.packages(c("shiny", "config", "bslib", "dotenv"))
```

### 2. Set Up Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your actual values
# DO NOT commit this file!
```

### 3. Run the Application

**From R Console:**
```r
library(shiny)
runApp(port = 8080)
```

The `global.R` file automatically loads environment variables from `.env` when running locally.

**From Command Line:**
```bash
R -e "shiny::runApp(port=8080, host='0.0.0.0')"
```

### 4. Load Environment Variables

**Windows (PowerShell):**
```powershell
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}
```

**Unix/Mac/Linux:**
```bash
export $(cat .env | xargs)
R -e "shiny::runApp(port=8080)"
```

Visit http://localhost:8080 to view the application.

## Deployment to Google Cloud Run

See **[deployment_instructions.md](deployment_instructions.md)** for complete step-by-step instructions including:

- Setting up Google Cloud Project
- Creating secrets in Secret Manager
- Building and pushing Docker images
- Deploying to Cloud Run
- Troubleshooting and monitoring

### Quick Deploy Summary

```bash
# 1. Set up project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# 2. Create secrets (see deployment_instructions.md for details)
# 3. Build and push image
docker build -t gcr.io/$PROJECT_ID/env-variables-app .
docker push gcr.io/$PROJECT_ID/env-variables-app

# 4. Deploy to Cloud Run
gcloud run deploy env-variables-app \
    --image=gcr.io/$PROJECT_ID/env-variables-app \
    --platform=managed \
    --region=us-central1 \
    --set-secrets=... # (see full command in deployment_instructions.md)
```

## Environment Variables

The application reads the following environment variables:

### Database Configuration
- `MySQL_HOST` - MySQL server hostname
- `MySQL_USER` - MySQL username
- `MySQL_PASS` - MySQL password
- `MySQL_DB` - Database name
- `MySQL_PORT` - MySQL port (default: 3306)

### API Keys
- `P_API_KEY` - API key for external service

### Email Configuration
- `EMAIL_USERNAME` - Email account username
- `EMAIL_PWD` - Email account password
- `EMAIL_PAGOS_USER` - Payment notifications email
- `EMAIL_PAGOS_PWD` - Payment email password
- `EMAIL_SMTP` - SMTP server address

### Authentication
- `AUTH0_USER` - Auth0 username
- `AUTH0_KEY` - Auth0 API key
- `AUTH0_SECRET` - Auth0 secret

### AI/LLM
- `LLM_API` - LLM API key

### Application Environment
- `R_CONFIG_ACTIVE` - Config environment (`default` or `prod`)

## Security Notes

⚠️ **IMPORTANT**: 
- Never commit `.env` files to version control
- Use Google Secret Manager for production secrets
- The application masks displayed secrets for security
- Always use HTTPS in production
- Consider adding authentication for production deployments

## How It Works

1. **Local Development**: 
   - Reads secrets from environment variables (loaded from `.env`)
   - Uses `config.yml` with `R_CONFIG_ACTIVE=default` or `prod`

2. **Production (Cloud Run)**:
   - Google Secret Manager secrets are mounted as environment variables
   - Cloud Run service configuration maps secrets to environment variables
   - `config.yml` reads these via `Sys.getenv()`
   - Application displays masked values in the UI

## Config File Structure

The `config.yml` uses the R `config` package format:

```yaml
default:
  ENV: "d"
  
prod:
  ENV: "p"
  MySQL_HOST: !expr Sys.getenv("MySQL_HOST")
  # ... other variables
```

- `default`: Used for local development
- `prod`: Used in Cloud Run (set by `R_CONFIG_ACTIVE=prod`)
- `!expr Sys.getenv()`: Dynamically reads from environment variables

## Docker Container

The application runs in a Docker container based on `rocker/r-ver:4.3.2`:
- Installs required system dependencies
- Installs R packages: `shiny`, `config`, `shinydashboard`
- Exposes port 8080 (required by Cloud Run)
- Sets `R_CONFIG_ACTIVE=prod` by default

## Monitoring and Troubleshooting

### View Cloud Run Logs
```bash
gcloud run services logs read env-variables-app --region=us-central1 --limit=50
```

### Test Docker Locally
```bash
docker run -p 8080:8080 --env-file .env gcr.io/$PROJECT_ID/env-variables-app
```

### Check Secret Access
```bash
gcloud secrets get-iam-policy SECRET_NAME
```

## Contributing

1. Never commit actual secrets
2. Update `.env.example` when adding new variables
3. Update `config.yml` to include new variables
4. Update UI and server to display new variables
5. Test locally before deploying to Cloud Run

## License

[Add your license here]

## Support

For issues or questions:
- Check [deployment_instructions.md](deployment_instructions.md)
- Review Cloud Run logs
- Verify Secret Manager configuration
- Check IAM permissions

## References

- [R Shiny](https://shiny.rstudio.com/)
- [R Config Package](https://cran.r-project.org/web/packages/config/)
- [Google Cloud Run](https://cloud.google.com/run)
- [Google Secret Manager](https://cloud.google.com/secret-manager)
- [Docker Documentation](https://docs.docker.com/)
