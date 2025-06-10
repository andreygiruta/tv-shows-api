# TV Shows API

A Ruby on Rails API service that continuously imports TV show data from TVMaze and provides a REST API for querying upcoming TV releases.

## Features

- **Data Import**: Daily scheduled import of TV show data from TVMaze API
- **REST API**: Clean JSON endpoints with filtering, pagination, and caching
- **Database**: PostgreSQL with optimized indexes for fast queries
- **Background Jobs**: Sidekiq for scheduled data processing
- **Analytics**: Complex SQL queries with CTEs, window functions, and aggregates
- **Testing**: Comprehensive test suite with 88.43% coverage (exceeds 70% requirement)

## Quick Start

### Using Docker (Recommended)

#### Development Mode
1. **Start all services (backend + frontend):**
   ```bash
   docker-compose up -d
   ```
   This starts:
   - Backend API at `http://localhost:3000`
   - React frontend at `http://localhost:3001`
   - PostgreSQL database
   - Redis
   - Sidekiq worker

2. **Run initial data import:**
   ```bash
   docker-compose --profile import up import
   ```

3. **Access the services:**
   ```bash
   # Test the API
   curl "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16"
   
   # Visit the frontend
   open http://localhost:3001
   ```

#### Production Mode
1. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your production values
   ```

2. **Deploy with production optimizations:**
   ```bash
   # Quick deployment
   ./scripts/deploy.sh --with-data
   
   # Or manual deployment
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Local Development

1. **Prerequisites:**
   - Ruby 3.2+
   - PostgreSQL 15+
   - Redis 7+
   - Node.js 18+ (for frontend)

2. **Setup:**
   ```bash
   bundle install
   rails db:create db:migrate
   ```

3. **Start services:**
   ```bash
   # Terminal 1: Rails server
   rails server

   # Terminal 2: Sidekiq
   bundle exec sidekiq

   # Terminal 3: Initial data load
   rails runner "TvmazeImportService.new.import_upcoming_episodes(days: 30)"
   
   # Terminal 4: React frontend (optional)
   cd frontend && npm install && npm run dev
   ```

## Frontend (React Web App)

A modern React frontend is available in the `frontend/` directory, providing a user-friendly interface for browsing TV shows.

### Features

- **Responsive Design**: Works on desktop, tablet, and mobile
- **Real-time Filtering**: Filter by date range, network, country, and rating
- **Pagination**: Efficient browsing of large datasets with customizable per-page options (6, 12, 24, 48, 100)
- **Image Display**: Show and episode images with smart fallback handling
- **Modern UI**: Clean interface built with Tailwind CSS and Heroicons
- **Error Handling**: Graceful error states and retry functionality

### Quick Start

```bash
# Start both backend and frontend together
docker-compose up -d
docker-compose --profile import up import
```

Visit `http://localhost:3001` to use the web interface.

### Tech Stack

- **React 18** with modern hooks
- **Vite** for fast development and builds
- **Tailwind CSS** for responsive styling
- **Heroicons** for beautiful icons
- **Axios** for API communication

### Screenshots

The frontend provides:
- Date range picker for custom episode schedules
- Network/distributor filtering (HBO, Netflix, NBC, etc.)
- Country-based filtering (US, UK, Canada, etc.)
- Minimum rating filters (8.0+, 7.0+, etc.)
- Per-page options (6, 12, 24, 48, 100 shows)
- Responsive episode cards with show details and images
- Pagination for large result sets
- Clear filters functionality

See `frontend/README.md` for detailed setup and development instructions.

## API Documentation

### Endpoints

**GET** `/api/v1/tvshows`

Retrieves TV episodes scheduled for release within a date range.

**GET** `/api/v1/shows`

Retrieves a list of all TV shows with episodes in the database.

**GET** `/api/v1/shows/:id/episodes`

Retrieves all episodes for a specific TV show.

**GET** `/api/v1/networks`

Retrieves a list of all networks/distributors from the database.

**GET** `/api/v1/countries`

Retrieves a list of all countries from the database.

#### `/api/v1/tvshows` Parameters
**Required:**
- `date_from` (string): Start date in YYYY-MM-DD format
- `date_to` (string): End date in YYYY-MM-DD format

**Optional:**
- `distributor` (string): Filter by network/distributor name
- `country` (string): Filter by distributor country
- `rating` (float): Minimum show rating threshold
- `page` (integer): Page number for pagination (default: 1)
- `per_page` (integer): Items per page, max 100 (default: 25)

#### `/api/v1/shows` Parameters
**Optional:**
- `page` (integer): Page number for pagination (default: 1)
- `per_page` (integer): Items per page, max 100 (default: 50)

#### `/api/v1/shows/:id/episodes` Parameters
**Required:**
- `id` (integer): TV show ID

**Optional:**
- `page` (integer): Page number for pagination (default: 1)
- `per_page` (integer): Items per page, max 100 (default: 25)

#### Example Response
```json
{
  "data": [
    {
      "id": 123,
      "name": "Episode Title",
      "season": 1,
      "episode_number": 5,
      "type": "regular",
      "runtime": 60,
      "rating": 8.5,
      "summary": "Episode description...",
      "airdate": "2025-06-09",
      "airtime": "20:00",
      "show": {
        "id": 456,
        "name": "Show Title",
        "type": "Scripted",
        "language": "English",
        "status": "Running",
        "rating": 8.2,
        "genres": ["Drama", "Comedy"],
        "network": {
          "id": 789,
          "name": "HBO",
          "country": "United States"
        }
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 120,
    "per_page": 25
  }
}
```

#### Example Queries

```bash
# Get episodes for date range
curl "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16"

# Filter episodes by HBO shows only
curl "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&distributor=HBO"

# High-rated shows from US networks
curl "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&country=United%20States&rating=8.0"

# Get all TV shows
curl "http://localhost:3000/api/v1/shows"

# Get episodes for a specific show (show ID 87)
curl "http://localhost:3000/api/v1/shows/87/episodes"

# Get episodes with pagination
curl "http://localhost:3000/api/v1/shows/87/episodes?page=2&per_page=10"

# Get available networks for filtering
curl "http://localhost:3000/api/v1/networks"

# Get available countries for filtering
curl "http://localhost:3000/api/v1/countries"
```

## Database Schema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   distributors  │    │    tv_shows     │    │    episodes     │    │  release_dates  │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ id              │◄──┐│ id              │◄──┐│ id              │◄──┐│ id              │
│ tvmaze_id (UNQ) │   ││ tvmaze_id (UNQ) │   ││ tvmaze_id (UNQ) │   ││ airdate         │
│ name            │   ││ name            │   ││ name            │   ││ airtime         │
│ country         │   ││ show_type       │   ││ season          │   ││ episode_id (FK) │
│ official_site   │   ││ language        │   ││ episode_number  │   ││ created_at      │
│ created_at      │   ││ status          │   ││ episode_type    │   ││ updated_at      │
│ updated_at      │   ││ runtime         │   ││ runtime         │   │└─────────────────┘
└─────────────────┘   ││ premiered       │   ││ rating          │   │
                      ││ ended           │   ││ image_medium    │   │
                      ││ official_site   │   ││ image_original  │   │
                      ││ rating          │   ││ summary         │   │
                      ││ genres          │   ││ tv_show_id (FK) │───┘
                      ││ schedule_time   │   ││ created_at      │
                      ││ schedule_days   │   ││ updated_at      │
                      ││ image_medium    │   │└─────────────────┘
                      ││ image_original  │   │
                      ││ summary         │   │
                      ││ network_id (FK) │───┘
                      ││ created_at      │
                      ││ updated_at      │
                      │└─────────────────┘
                      │
Relationships:
• distributors (1) ──< tv_shows (many)     [network_id]
• tv_shows (1) ──< episodes (many)         [tv_show_id]  
• episodes (1) ──< release_dates (many)    [episode_id]

Key Indexes:
• tvmaze_id (unique) on all tables for idempotent operations
• airdate on release_dates for date range queries
• (tv_show_id, season, episode_number) unique on episodes
• (airdate, episode_id) unique on release_dates
• name, country, status, rating for filtering
```

### Key Indexes
- Primary lookups: `tvmaze_id` unique indexes for idempotent operations
- API performance: `airdate` indexes for date range queries
- Filtering: `name`, `country`, `status`, `rating` indexes
- Analytics: Composite indexes like `[network_id, status]`

See [db/INDEX_DOCUMENTATION.md](db/INDEX_DOCUMENTATION.md) for detailed rationale.

## Analytics

The service includes three sample analytical queries in [db/analytical_queries.sql](db/analytical_queries.sql):

1. **Network Performance Analysis**: Rolling 7-day episode releases with window functions
2. **Genre Performance by Rating**: Show metrics aggregated by genre with CTEs
3. **Release Schedule Density**: Peak time analysis with temporal patterns

Run directly in PostgreSQL:
```bash
docker-compose exec db psql -U postgres -d tv_shows_api_development -f /app/db/analytical_queries.sql
```

## Background Jobs

### Daily Import
- **Schedule**: Daily at 2 AM UTC via sidekiq-cron
- **Scope**: Fetches upcoming episodes for next 90 days
- **Idempotency**: Updates existing records, creates new ones
- **Rate Limiting**: Respects TVMaze API limits (20 calls/10 seconds)

### Manual Import
```bash
# Import next 30 days
rails runner "TvmazeImportService.new.import_upcoming_episodes(days: 30)"

# Specific country
rails runner "TvmazeImportService.new.import_upcoming_episodes(days: 90, country: 'CA')"
```

## Testing

```bash
# Run all tests with coverage
bundle exec rails test

# Run linting
bundle exec rubocop

# Security scanning
bundle exec brakeman

# Run specific test files
rails test test/controllers/api/v1/tv_shows_controller_test.rb
rails test test/services/tvmaze_import_service_test.rb
```

### Quality Metrics
- **Test Coverage**: 88.43% (exceeds 70% requirement)
- **RuboCop**: All style violations resolved
- **Security**: Brakeman security scanning passed

## Recent Improvements

### Performance Optimizations
- **React Memoization**: Components use `React.memo()` to prevent unnecessary re-renders
- **Debounced Filters**: User input is debounced to reduce API calls
- **Custom Hooks**: Centralized state management and API logic
- **Service Layer**: Backend business logic extracted from controllers

### Error Handling
- **Error Boundaries**: Frontend gracefully handles React errors
- **Centralized Error Handling**: Backend uses consistent error responses
- **Improved UX**: Better error messages and retry functionality

### Production Ready
- **Multi-stage Docker**: Optimized production builds with nginx
- **Environment Configs**: Separate dev/staging/prod configurations
- **Health Checks**: Docker health checks for all services
- **Security Headers**: Nginx security headers and CSP

### Code Quality
- **Serializers**: Clean API response formatting
- **Concerns**: Reusable error handling patterns
- **Date Utility Service**: Centralized date parsing with error handling
- **TypeScript Ready**: Components structured for easy TS migration

## Architecture Decisions & Trade-offs

### Idempotency
All TVMaze data uses `tvmaze_id` as the primary identifier, allowing for safe re-import and updates without duplicates.

**Trade-off**: Slight overhead in lookups vs. guaranteed data consistency and safe re-runs.

### Caching Strategy
- API responses include `Cache-Control: public, max-age=3600`
- Deterministic ordering ensures consistent responses suitable for HTTP caching
- Database indexes optimize for common query patterns

**Trade-off**: 1-hour cache means slightly stale data vs. reduced API load and faster responses.

### Database Design
- **Normalized Schema**: Separate tables for distributors, shows, episodes, and release dates
- **Trade-off**: Multiple joins required vs. data consistency and storage efficiency
- **Indexes**: Strategic indexes on frequently queried fields
- **Trade-off**: Storage overhead and slower writes vs. fast read performance

### Error Handling
- Rate limiting with exponential backoff for TVMaze API
- Graceful degradation for missing data
- Comprehensive logging for monitoring

**Trade-off**: Slower import during errors vs. respecting API limits and avoiding bans.

### Background Processing
- **Sidekiq**: Asynchronous job processing with Redis
- **Daily Schedule**: 90-day rolling window of upcoming episodes
- **Trade-off**: Eventual consistency vs. real-time updates

### Performance Choices
- Optimized joins and includes to prevent N+1 queries
- Strategic database indexes for sub-second API responses
- Pagination to handle large result sets
- **Trade-off**: Memory usage for includes vs. query performance

### Technology Stack
- **Rails API**: Fast development, robust ecosystem
- **PostgreSQL**: ACID compliance, complex queries, JSON support
- **Redis**: Fast job queue, simple caching
- **Docker**: Consistent deployment, easy scaling

**Trade-offs**:
- Rails: Rapid development vs. potential overhead for high-scale
- PostgreSQL: Feature-rich vs. operational complexity
- Monolithic: Simple deployment vs. scaling limitations

### Service Layer Architecture
- **DateUtilityService**: Centralized date parsing with comprehensive error handling
  - `parse_date()`: Safe parsing that returns nil on error
  - `parse_date!()`: Strict parsing that raises ArgumentError on invalid dates
  - `safe_date_range()`: Validates date ranges and prevents logic errors
  - Used across: TvShowsQueryService, TvmazeImportService, and all models
  - **Trade-off**: Slight overhead vs. consistent error handling and logging

### API Design
- **REST**: Standard, predictable interface
- **Date Range Required**: Prevents unbounded queries
- **Pagination**: Handles large datasets
- **Trade-off**: More API calls for large datasets vs. performance and UX

## Production Considerations

1. **Environment Variables:**
   - `DATABASE_URL`: PostgreSQL connection string
   - `REDIS_URL`: Redis connection for Sidekiq
   - `RAILS_ENV`: Set to `production`

2. **Monitoring:**
   - Monitor Sidekiq queue health
   - Track API response times
   - Watch for TVMaze rate limit errors

3. **Scaling:**
   - Add read replicas for analytical queries
   - Consider CDN for API responses with long cache times
   - Scale Sidekiq workers for faster import
