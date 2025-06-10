# TV Shows API - Endpoint Examples

## Base Information

- **Base URL**: `http://localhost:3000` (local development)
- **Production URL**: `https://api.tvshows.example.com` (when deployed)
- **API Version**: v1
- **Content-Type**: `application/json`
- **Authentication**: HTTP Basic Auth (production) or open (development)

## 1. Health Check

### cURL Example
```bash
curl -X GET "http://localhost:3000/up" \
     -H "Accept: application/json"
```

### Expected Response
```json
{
  "status": "ok",
  "timestamp": "2025-06-09T13:30:00Z"
}
```

## 2. Get TV Shows - Basic Query

### cURL Example
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16" \
     -H "Accept: application/json" \
     -H "User-Agent: TV-Shows-Client/1.0"
```

### Postman Collection
```json
{
  "info": {
    "name": "TV Shows API",
    "description": "Collection for TV Shows API endpoints",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Get TV Shows - Date Range",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{base_url}}/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16",
          "host": ["{{base_url}}"],
          "path": ["api", "v1", "tvshows"],
          "query": [
            {
              "key": "date_from",
              "value": "2025-06-09"
            },
            {
              "key": "date_to", 
              "value": "2025-06-16"
            }
          ]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000"
    }
  ]
}
```

## 3. Filter by Network/Distributor

### cURL Example
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&distributor=HBO" \
     -H "Accept: application/json"
```

### Expected Response
```json
{
  "data": [
    {
      "id": 123,
      "name": "Episode Title",
      "season": 3,
      "episode_number": 5,
      "type": "regular",
      "runtime": 60,
      "rating": 8.5,
      "summary": "Episode description...",
      "airdate": "2025-06-10",
      "airtime": "21:00",
      "show": {
        "id": 456,
        "name": "Show Title",
        "type": "Scripted",
        "language": "English",
        "status": "Running",
        "rating": "8.2",
        "genres": ["Drama", "Thriller"],
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
    "total_pages": 2,
    "total_count": 35,
    "per_page": 25
  }
}
```

## 4. Filter by Country and Rating

### cURL Example
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&country=United%20States&rating=8.0" \
     -H "Accept: application/json"
```

### PowerShell Example
```powershell
$headers = @{
    'Accept' = 'application/json'
    'User-Agent' = 'TV-Shows-Client/1.0'
}

$response = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&country=United States&rating=8.0" -Headers $headers

$response | ConvertTo-Json -Depth 10
```

## 5. Pagination Example

### cURL Example
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16&page=2&per_page=10" \
     -H "Accept: application/json"
```

### JavaScript/Node.js Example
```javascript
const axios = require('axios');

async function fetchTVShows(page = 1, perPage = 25) {
  try {
    const response = await axios.get('http://localhost:3000/api/v1/tvshows', {
      params: {
        date_from: '2025-06-09',
        date_to: '2025-06-16',
        page: page,
        per_page: perPage
      },
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'TV-Shows-Client/1.0'
      }
    });
    
    console.log(`Found ${response.data.pagination.total_count} episodes`);
    console.log(`Page ${response.data.pagination.current_page} of ${response.data.pagination.total_pages}`);
    
    return response.data;
  } catch (error) {
    console.error('Error fetching TV shows:', error.response?.data || error.message);
  }
}

// Usage
fetchTVShows(2, 10);
```

## 6. Python Example

```python
import requests
from datetime import datetime, timedelta

def fetch_tv_shows(date_from, date_to, **filters):
    """
    Fetch TV shows from the API with optional filters
    """
    base_url = "http://localhost:3000/api/v1/tvshows"
    
    params = {
        'date_from': date_from,
        'date_to': date_to,
        **filters
    }
    
    headers = {
        'Accept': 'application/json',
        'User-Agent': 'TV-Shows-Python-Client/1.0'
    }
    
    try:
        response = requests.get(base_url, params=params, headers=headers)
        response.raise_for_status()
        
        data = response.json()
        print(f"Found {data['pagination']['total_count']} episodes")
        
        return data
        
    except requests.exceptions.RequestException as e:
        print(f"Error fetching TV shows: {e}")
        return None

# Example usage
today = datetime.now().strftime('%Y-%m-%d')
next_week = (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')

# Get all shows for next week
shows = fetch_tv_shows(today, next_week)

# Get HBO shows only
hbo_shows = fetch_tv_shows(today, next_week, distributor='HBO')

# Get high-rated US shows
us_shows = fetch_tv_shows(today, next_week, country='United States', rating='8.0')
```

## 7. Error Responses

### Missing Required Parameters
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows" \
     -H "Accept: application/json"
```

Response:
```json
{
  "error": "date_from and date_to parameters are required",
  "status": 400
}
```

### Invalid Date Format
```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=invalid-date&date_to=2025-06-16" \
     -H "Accept: application/json"
```

Response:
```json
{
  "error": "Invalid date format. Use YYYY-MM-DD",
  "status": 400
}
```

## 8. Production Authentication (When Deployed)

### With HTTP Basic Auth
```bash
curl -X GET "https://api.tvshows.example.com/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16" \
     -H "Accept: application/json" \
     -u "username:password"
```

### With API Key
```bash
curl -X GET "https://api.tvshows.example.com/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16" \
     -H "Accept: application/json" \
     -H "X-API-Key: your-api-key-here"
```

## 9. Complete Postman Environment

```json
{
  "id": "tv-shows-api-env",
  "name": "TV Shows API Environment",
  "values": [
    {
      "key": "base_url",
      "value": "http://localhost:3000",
      "enabled": true
    },
    {
      "key": "api_version",
      "value": "v1",
      "enabled": true
    },
    {
      "key": "auth_username",
      "value": "admin",
      "enabled": false
    },
    {
      "key": "auth_password",
      "value": "password",
      "enabled": false
    }
  ]
}
```

## 10. Rate Limiting

The API implements rate limiting. If you exceed the limits, you'll receive:

```json
{
  "error": "Rate limit exceeded. Try again in 60 seconds.",
  "status": 429,
  "retry_after": 60
}
```

## Response Time Benchmarks

- **Average Response Time**: < 500ms
- **95th Percentile**: < 1000ms
- **With Caching**: < 100ms for repeated requests

## Cache Headers

The API includes cache headers for better performance:

```
Cache-Control: public, max-age=3600
ETag: "abc123def456"
Vary: Accept
```

You can use `If-None-Match` header for conditional requests:

```bash
curl -X GET "http://localhost:3000/api/v1/tvshows?date_from=2025-06-09&date_to=2025-06-16" \
     -H "Accept: application/json" \
     -H "If-None-Match: \"abc123def456\""
```

If content hasn't changed, you'll receive a `304 Not Modified` response.