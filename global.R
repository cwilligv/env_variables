# Load environment variables
# Only load .env file if not running on Cloud Run (K_SERVICE is set by Cloud Run)
if (Sys.getenv("K_SERVICE") == "") {
  dotenv::load_dot_env()
}

# Set R_CONFIG_ACTIVE to prod (can be overridden by environment variable)
if (Sys.getenv("R_CONFIG_ACTIVE") == "") {
  Sys.setenv(R_CONFIG_ACTIVE = "prod")
}

# Load required libraries
library(shiny)
library(config)
library(bslib)

# Get config based on R_CONFIG_ACTIVE environment variable
cfg <- config::get()

env_active <- Sys.getenv("R_CONFIG_ACTIVE", "default")
