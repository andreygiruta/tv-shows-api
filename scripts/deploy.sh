#!/bin/bash

# Deployment script for TV Shows API
set -e

echo "🚀 Starting deployment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Source environment variables
source .env

# Validate required environment variables
if [ -z "$SECRET_KEY_BASE" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    echo "❌ Required environment variables are missing. Please check your .env file."
    exit 1
fi

echo "📦 Building and starting services..."

# Build and start production services
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to be ready..."
sleep 30

# Run database migrations
echo "🗄️ Running database setup..."
docker-compose -f docker-compose.prod.yml exec web bundle exec rails db:create db:migrate

# Optional: Load sample data
if [ "$1" = "--with-data" ]; then
    echo "📊 Loading sample data..."
    docker-compose -f docker-compose.prod.yml exec web bundle exec rails runner "TvmazeImportService.new.import_upcoming_episodes(days: 30)"
fi

echo "✅ Deployment complete!"
echo ""
echo "🌐 Services available at:"
echo "   Frontend: http://localhost"
echo "   API:      http://localhost/api/v1/tvshows"
echo "   Traefik:  http://localhost:8080 (if using --profile proxy)"
echo ""
echo "📊 To check logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"