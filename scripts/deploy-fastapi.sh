#!/bin/bash
set -e

ALEMBIC_MIGRATE=${ALEMBIC_MIGRATE:-false}

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: SERVICE_NAME not set"
    exit 1
fi

echo "--- Deploying $SERVICE_NAME ---"

echo "Activating venv..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate

echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# --- Optional Alembic migrations ---
if [ "$ALEMBIC_MIGRATE" = "true" ]; then
    echo "Running migrations..."
    alembic upgrade head
else
    echo "Skipping migrations"
fi

echo "Deactivating venv..."
deactivate

echo "Restarting $SERVICE_NAME..."
# Remember to add the sudoers file with NOPASSWD
sudo /usr/bin/systemctl restart "$SERVICE_NAME"

echo "Checking $SERVICE_NAME status..."
sleep 1
sudo /usr/bin/systemctl status "$SERVICE_NAME" --no-pager

echo "--- Deployed $SERVICE_NAME ---