# TV Shows Frontend

A modern React frontend for the TV Shows API, built with Vite, Tailwind CSS, and Heroicons.

## Features

- **Responsive Design**: Works on desktop, tablet, and mobile
- **Real-time Filtering**: Filter by date range, network, country, and rating
- **Pagination**: Efficient browsing of large datasets
- **Modern UI**: Clean, accessible interface with Tailwind CSS
- **Error Handling**: Graceful error states and retry functionality
- **Loading States**: Smooth loading indicators

## Tech Stack

- **React 18**: Modern React with hooks
- **Vite**: Fast development and build tool
- **Tailwind CSS**: Utility-first CSS framework
- **Heroicons**: Beautiful SVG icons
- **Axios**: HTTP client for API requests
- **date-fns**: Date manipulation library

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- TV Shows API running on `http://localhost:3000`

### Installation

```bash
cd frontend
npm install
```

### Development

```bash
npm run dev
```

The frontend will start on `http://localhost:3001` with proxy to the API.

### Production Build

```bash
npm run build
npm run preview
```

## Environment Variables

Create a `.env` file:

```env
VITE_API_BASE_URL=http://localhost:3000
```

For production:
```env
VITE_API_BASE_URL=https://api.tvshows.example.com
```

## Features

### Date Range Picker
- Select custom date ranges for episode lookup
- Validates that end date is after start date
- Defaults to next 7 days

### Advanced Filtering
- **Network/Distributor**: Search for specific networks (HBO, Netflix, etc.)
- **Country**: Filter by distributor country
- **Minimum Rating**: Show only highly-rated content
- **Reset**: Clear all filters with one click

### Episode Cards
- **Show Information**: Title, season/episode, air date and time
- **Network Details**: Network name and country
- **Ratings**: Visual rating indicators with color coding
- **Genres**: Tag-based genre display
- **Summaries**: Episode descriptions (HTML-stripped)
- **Runtime**: Episode duration information

### Responsive Design
- Mobile-first approach
- Adaptive grid layouts
- Touch-friendly interface
- Accessible navigation

## API Integration

The frontend integrates with the TV Shows API:

```javascript
// Example API call
const response = await axios.get('/api/v1/tvshows', {
  params: {
    date_from: '2025-06-09',
    date_to: '2025-06-16',
    distributor: 'HBO',
    country: 'United States',
    rating: '8.0',
    page: 1,
    per_page: 12
  }
});
```

## Component Structure

```
src/
├── App.jsx              # Main application component
├── main.jsx             # React entry point
├── index.css            # Global styles and Tailwind imports
└── components/
    ├── TVShowCard.jsx        # Individual episode card
    ├── DateRangePicker.jsx   # Date range selection
    ├── FilterPanel.jsx       # Advanced filters
    └── LoadingSpinner.jsx    # Loading indicator
```

## Styling

The app uses Tailwind CSS with custom utilities:

- `line-clamp-1` and `line-clamp-3`: Text truncation
- Responsive grid system
- Color-coded ratings (green 8+, yellow 6+, red <6)
- Hover effects and transitions

## Performance

- **Pagination**: Loads 12 episodes per page for optimal performance
- **Debounced Filtering**: Efficient API calls when filters change
- **Image Fallbacks**: Graceful handling of missing show images
- **Error Boundaries**: Prevents crashes from API errors

## Accessibility

- Semantic HTML structure
- Keyboard navigation support
- Screen reader friendly
- High contrast ratios
- Focus indicators

## Docker Integration

The frontend can be served alongside the API:

```dockerfile
# Add to main Dockerfile for production
FROM node:18-alpine as frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build

# Serve with nginx or Rails static files
```

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Contributing

1. Follow the existing code structure
2. Use TypeScript-style prop documentation
3. Maintain responsive design principles
4. Test across different screen sizes
5. Ensure accessibility compliance