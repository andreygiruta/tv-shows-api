# Database Index Documentation

## Index Strategy and Rationale

### Distributors Table
- **`tvmaze_id` (unique)**: Primary lookup field for idempotent operations. Ensures no duplicate networks from TVMaze API.
- **`name`**: Enables fast filtering by distributor/network name in API queries.
- **`country`**: Supports filtering by country in analytical queries and API endpoints.

### TV Shows Table  
- **`tvmaze_id` (unique)**: Primary lookup field for idempotent operations. Ensures no duplicate shows from TVMaze API.
- **`name`**: Enables fast text searches and sorting by show name in API responses.
- **`status`**: Critical for filtering active vs ended shows in API queries and analytics.
- **`premiered`**: Supports date range filtering for show premieres and temporal analytics.
- **`rating`**: Enables fast filtering and sorting by show ratings in API endpoints.
- **`[network_id, status]` (composite)**: Optimizes queries filtering shows by both network and status, common in analytics.

### Episodes Table
- **`tvmaze_id` (unique)**: Primary lookup field for idempotent operations. Ensures no duplicate episodes from TVMaze API.
- **`[tv_show_id, season, episode_number]` (unique composite)**: Enforces business rule preventing duplicate episodes within a show's season.
- **`season`**: Enables fast filtering by season number for API queries.
- **`episode_number`**: Supports sorting and filtering by episode number within seasons.

### Release Dates Table
- **`airdate`**: Most critical index for date range filtering in API endpoints (date_from/date_to parameters).
- **`[airdate, episode_id]` (unique composite)**: Prevents duplicate release dates for the same episode while optimizing date-based queries.
- **`[airdate, airtime]` (composite)**: Optimizes queries for daily schedules with specific time slots.

## Query Optimization Benefits

1. **API Endpoint Performance**: Date range queries (`date_from=...&date_to=...`) leverage `airdate` indexes for sub-second response times.

2. **Idempotent Operations**: Unique TVMaze ID indexes ensure O(1) lookup performance during data import.

3. **Analytical Queries**: Composite indexes on `[network_id, status]` and `[airdate, airtime]` eliminate full table scans for complex aggregations.

4. **Caching Strategy**: Deterministic ordering via indexed columns ensures consistent API responses suitable for HTTP caching.

The index strategy balances write performance (minimal overhead) with read optimization for the most common query patterns in TV schedule APIs.
