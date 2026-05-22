# Use official R base image
FROM rocker/r-ver:4.3.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install R packages
RUN R -e "install.packages(c('shiny', 'config', 'bslib'), repos='https://cloud.r-project.org/')"

# Copy application files
COPY ui.R server.R config.yml ./

# Expose port for Cloud Run
EXPOSE 8080

# Set environment variable for production
ENV R_CONFIG_ACTIVE=prod

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=8080)"]
