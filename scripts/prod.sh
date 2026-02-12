
echo "🚀 Starting Acquisition App in Production Mode"
echo "==============================================="

if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production file not found!"
    echo "   Please create .env.production with your production environment variables."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

echo "📦 Building and starting production container..."
echo "   - Using Neon Cloud Database (no local proxy)"
echo "   - Running in optimized production mode"
echo ""

docker compose -f docker-compose.prod.yml up --build -d

echo "⏳ Waiting for Neon Local to be ready..."
sleep 5

echo "📜 Applying latest schema with Drizzle..."
npm run db:migrate

echo ""
echo "🎉 Production environment started!"
echo "   Application: http://localhost:3000"
echo "   Logs: docker logs acquisition-app-prod"
echo ""
echo "Useful commands:"
echo "   View logs: docker logs -f acquisition-app-prod"
echo "   Stop app: docker compose -f docker-compose.prod.yml down"