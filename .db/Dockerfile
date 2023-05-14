FROM mcr.microsoft.com/mssql/server:2019-latest

# Copy initialization scripts to custom directory
RUN mkdir -p /usr/init
WORKDIR /usr/init
COPY init/ .

# Run entrypoint script
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]

