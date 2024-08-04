FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

# user uid and gid
ARG UID=1000
ARG GID=1000

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    unixodbc \
    unixodbc-dev \
    gnupg2 \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft repository and install ODBC driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Configure the ODBC driver
RUN echo "[ODBC Driver 17 for SQL Server]" >> /etc/odbcinst.ini \
    && echo "Description=Microsoft ODBC Driver 17 for SQL Server" >> /etc/odbcinst.ini \
    && echo "Driver=/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.10.so.2.1" >> /etc/odbcinst.ini \
    && echo "UsageCount=1" >> /etc/odbcinst.ini

# Set the library path
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/microsoft/msodbcsql17/lib64

# Create app user and group
RUN groupadd -g $GID -o app && \
    useradd -g $GID -u $UID -mr -d /home/app -o -s /bin/bash app

# Set work directory
WORKDIR /home/app

# Copy requirements file
COPY --chown=app:app ./requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --upgrade -r requirements.txt

RUN chmod +x run.sh
RUN chown app:app run.sh
RUN bash -c 'chmod +x /home/app/run.sh'
# Copy project files
COPY --chown=app:app . .
# Change to app user
USER app

# Add /home/app/.local/bin to PATH
ENV PATH "$PATH:/home/app/.local/bin"
CMD ["python", "/home/app/mssql_writer.py"]