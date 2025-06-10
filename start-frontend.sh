#!/bin/bash

echo "🚀 Starting TV Shows Frontend..."
echo ""

# Check if API is running
echo "📡 Checking if API is running..."
if curl -s http://localhost:3000/up > /dev/null; then
    echo "✅ API is running at http://localhost:3000"
else
    echo "❌ API is not running. Please start it first:"
    echo "   docker-compose up -d"
    echo "   docker-compose --profile import up import"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend && npm install
    cd ..
fi

echo ""
echo "🎨 Starting React development server..."
echo "Frontend will be available at: http://localhost:3001"
echo "Press Ctrl+C to stop"
echo ""

cd frontend && npm run dev
