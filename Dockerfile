# Use the official rocker/shiny base image
FROM rocker/shiny:latest

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libuv1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
# Ensure shared libraries are updated and force reinstall 'fs' to link against libuv
RUN ldconfig && R -e "install.packages('fs', repos='https://cran.rstudio.com/')"

# Install remaining R packages and ensure they are all installed correctly
RUN R -e "pkgs <- c('tidyverse', 'ggrepel', 'DT', 'shinycssloaders', 'RCurl', 'readxl', 'ggiraph', 'htmlwidgets'); \
    install.packages(pkgs, repos='https://cran.rstudio.com/', Ncpus=parallel::detectCores()); \
    if (!all(pkgs %in% installed.packages())) stop('Some packages failed to install')"

# Copy the app files into the image
# Rocker/shiny looks for apps in /srv/shiny-server/
COPY . /srv/shiny-server/VolcaNoseR/

# Expose the default Shiny port
EXPOSE 3838

# The rocker/shiny image automatically starts the shiny server
# We just need to ensure the permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server/VolcaNoseR/

# Set environment variables to see logs in docker logs
ENV SHINY_LOG_STDERR=1

CMD ["/usr/bin/shiny-server"]
