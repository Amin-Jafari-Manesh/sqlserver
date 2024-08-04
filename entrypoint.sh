#!/bin/bash
set -e

# Run odbcinst -j to verify ODBC installation
odbcinst -j

# Run the Python application
exec python /home/app/mssql_writer.py
