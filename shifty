#!/bin/bash

# エラーが起きたら停止
set -e

# backend 起動
echo "--- Backend: Starting ---"
cd backend
./vendor/bin/sail up -d --remove-orphans

# frontend 起動
echo "--- Frontend: Starting ---"
cd ../frontend
docker compose up -d --remove-orphans

echo "--- All Done! ---"
echo "Backend: http://localhost (or your APP_PORT)"
echo "Frontend: http://localhost:5174"
