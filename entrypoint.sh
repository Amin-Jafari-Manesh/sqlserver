#!/usr/bin/bash

# Run the odbcinst
odbcinst -j

# Run the isql
python3 /home/app/mssql-writer.py