FROM ubuntu:18.04

# Install curl, powershell, mssql-tools, unixodbc-dev
RUN apt-get update \
    && apt-get install -y curl \
    && curl https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb --output packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && apt-get install -y unixodbc-dev \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools \
    && rm -rf /var/lib/apt/lists/* \
    && rm packages-microsoft-prod.deb \
    && apt-get clean

ENV PATH="$PATH:/opt/mssql-tools/bin"

# Set working directory
WORKDIR /app

# Copy script files to container image
COPY src/ ./src/

# Install SqlServer module
RUN pwsh -Command "Install-Module SqlServer -RequiredVersion 21.1.18256 -Force"

# Run PowerShell Core script
CMD ["pwsh", "-File", "./src/DataIntegration.ps1"]