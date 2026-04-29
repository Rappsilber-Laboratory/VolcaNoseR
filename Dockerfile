# Use the official rocker/shiny base image
FROM rocker/shiny:latest

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('tidyverse', 'ggrepel', 'DT', 'shinycssloaders', 'RCurl', 'readxl', 'ggiraph', 'htmlwidgets'), repos='https://cran.rstudio.com/')"

# Copy the app files into the image
# Rocker/shiny looks for apps in /srv/shiny-server/
COPY . /srv/shiny-server/VolcaNoseR/

# Expose the default Shiny port
EXPOSE 3838

# The rocker/shiny image automatically starts the shiny server
# We just need to ensure the permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server/VolcaNoseR/

# Optional: Set environment variables if needed
# ENV SHINY_LOG_STDERR=1

CMD ["/usr/bin/shiny-server"]
