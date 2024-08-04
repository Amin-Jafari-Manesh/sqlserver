FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

ARG UID=1000
ARG GID=1000

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

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/microsoft/msodbcsql17/lib64

RUN groupadd -g $GID -o app && \
    useradd -g $GID -u $UID -mr -d /home/app -o -s /bin/bash app

WORKDIR /home/app

COPY --chown=app:app ./requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir --upgrade -r requirements.txt

RUN chmod +x run.sh
COPY --chown=app:app . .
USER app
RUN bash -c 'chmod +x /home/app/run.sh'

ENV PATH "$PATH:/home/app/.local/bin"
CMD ["python", "/home/app/mssql_writer.py"]