# Use official R base image
FROM rocker/r-ver:4.3.2

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff-dev \
    libjpeg-dev \
    libuv1-dev \
    libcairo2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install R packages
RUN R -e "install.packages(c('shiny', 'config', 'bslib', 'dotenv'), repos='https://cloud.r-project.org/', dependencies = TRUE)"

# Copy application files
COPY ui.R server.R global.R config.yml ./

# Expose port for Cloud Run
EXPOSE 8080

# Set environment variable for production
ENV R_CONFIG_ACTIVE=prod

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=8080)"]
