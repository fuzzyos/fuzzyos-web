#!/bin/sh
set -e

echo "=== Docker Entrypoint Starting ==="
echo "Node version: $(node --version)"
echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la

# Replace environment variables in env.js
if [ -f /app/public/env.js ]; then
  echo "Injecting runtime environment variables..."
  sed -i "s|__NEXT_PUBLIC_WORKOS_REDIRECT_URI__|${NEXT_PUBLIC_WORKOS_REDIRECT_URI}|g" /app/public/env.js
  sed -i "s|__NEXT_PUBLIC_API_URL__|${NEXT_PUBLIC_API_URL}|g" /app/public/env.js
  sed -i "s|__NEXT_PUBLIC_APP_URL__|${NEXT_PUBLIC_APP_URL}|g" /app/public/env.js
  echo "Environment variables injected successfully"
else
  echo "Warning: /app/public/env.js not found"
fi

# Validate required environment variables
echo "Validating environment variables..."
if [ -z "$WORKOS_API_KEY" ]; then
  echo "Error: WORKOS_API_KEY is not set"
  exit 1
fi

if [ -z "$WORKOS_CLIENT_ID" ]; then
  echo "Error: WORKOS_CLIENT_ID is not set"
  exit 1
fi

if [ -z "$NEXT_PUBLIC_WORKOS_REDIRECT_URI" ]; then
  echo "Error: NEXT_PUBLIC_WORKOS_REDIRECT_URI is not set"
  exit 1
fi

if [ -z "$WORKOS_COOKIE_PASSWORD" ]; then
  echo "Error: WORKOS_COOKIE_PASSWORD is not set"
  exit 1
fi

echo "All environment variables validated successfully"

# Check if server.js exists
if [ ! -f "server.js" ]; then
  echo "Error: server.js not found in $(pwd)"
  echo "Looking for server.js in common locations..."
  find /app -name "server.js" -type f
  exit 1
fi

echo "Starting Next.js server..."
echo "Port: ${PORT:-3000}"
echo "Public URL: ${NEXT_PUBLIC_APP_URL}"
echo "Redirect URI: ${NEXT_PUBLIC_WORKOS_REDIRECT_URI}"

# Start the Next.js server
# Server will bind to 0.0.0.0 by default and use incoming Host header for URL generation
exec node server.js
