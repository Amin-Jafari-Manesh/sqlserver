#!/bin/bash
set -e

# Run odbcinst -j to verify ODBC installation
odbcinst -j

# Debug: Display the content of odbcinst.ini
cat /etc/odbcinst.ini

# Run the Python application
exec python /home/app/mssql_writer.py
