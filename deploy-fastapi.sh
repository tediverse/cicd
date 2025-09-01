#!/bin/bash

set -e 

ALEMBIC_MIGRATE=${ALEMBIC_MIGRATE:-false}

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: SERVICE_NAME environment variable is not set."
    exit 1
fi

echo "--- Starting deployment for ${SERVICE_NAME} ---"

echo "Activating virtualenv..."
python3 -m venv .venv
source venv/bin/activate

echo "Installing/updating python dependencies..."
pip install -r requirements.txt

# --- Conditional Database Migrations ---
if [ "$ALEMBIC_MIGRATE" = "true" ]; then
    echo "Running alebmic migrations..."
    alembic upgrade head
else
    echo "Skipping alembic migrations."
fi

echo "Deactivating virtualenv..."
deactivate

echo "Restarting service: ${SERVICE_NAME}..."
# Remember to add the sudoers file with NOPASSWD
sudo /usr/bin/systemctl restart "${SERVICE_NAME}"

echo "Checking service status..."
sleep 1
sudo /usr/bin/systemctl status "${SERVICE_NAME}" --no-pager

echo "--- Deployment of ${SERVICE_NAME} complete ---"