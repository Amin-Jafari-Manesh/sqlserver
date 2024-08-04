FROM python:3.10-slim

# Set environment variables

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


# user uid and gid
ARG UID=1000
# from getent group docker
ARG GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends gcc unixodbc-dev g++ && rm -rf /var/lib/apt/lists/*

RUN groupadd -g $GID -o app && \
    useradd -g $GID -u $UID -mr -d /home/app -o -s /bin/bash app

# changing user to "app"
USER app

# set work directory.
WORKDIR /home/app

# add /home/app/.local/bin to PATH
ENV PATH "$PATH:/home/app/.local/bin"

# upgrading pip and installing dependencies.
RUN pip install --upgrade pip
COPY --chown=app:app ./requirements.txt .
RUN pip install --no-cache-dir --upgrade -r /home/app/requirements.txt

# copy project
COPY --chown=app:app * /home/app/

CMD ["python","/home/app/mssql_writer.py"]
