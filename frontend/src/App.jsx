import React from 'react';
import { CalendarDaysIcon, TvIcon, StarIcon } from '@heroicons/react/24/outline';
import TVShowCard from './components/TVShowCard';
import DateRangePicker from './components/DateRangePicker';
import FilterPanel from './components/FilterPanel';
import LoadingSpinner from './components/LoadingSpinner';
import { useTvShows } from './hooks/useTvShows';

function App() {
  const {
    episodes,
    pagination,
    loading,
    error,
    filters,
    updateFilter,
    resetFilters,
    currentPage,
    handlePageChange,
    testConnection,
    setError
  } = useTvShows();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center gap-3">
            <TvIcon className="h-8 w-8 text-indigo-600" />
            <h1 className="text-3xl font-bold text-gray-900">TV Shows Schedule</h1>
          </div>
          <p className="mt-2 text-gray-600">
            Discover upcoming TV episodes and shows
          </p>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Filters */}
        <div className="mb-8 bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <CalendarDaysIcon className="h-5 w-5" />
              Filters
            </h2>
            <button
              onClick={resetFilters}
              className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Clear filters
            </button>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
            <DateRangePicker
              dateFrom={filters.dateFrom}
              dateTo={filters.dateTo}
              onDateFromChange={(value) => updateFilter('dateFrom', value)}
              onDateToChange={(value) => updateFilter('dateTo', value)}
            />
            
            <FilterPanel
              distributor={filters.distributor}
              country={filters.country}
              rating={filters.rating}
              onDistributorChange={(value) => updateFilter('distributor', value)}
              onCountryChange={(value) => updateFilter('country', value)}
              onRatingChange={(value) => updateFilter('rating', value)}
              onReset={resetFilters}
            />
            
            <div className="flex flex-col">
              <label htmlFor="perPage" className="text-sm font-medium text-gray-700 mb-1">
                Shows per page
              </label>
              <select
                id="perPage"
                value={filters.perPage}
                onChange={(e) => updateFilter('perPage', Number(e.target.value))}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              >
                <option value={6}>6 shows</option>
                <option value={12}>12 shows</option>
                <option value={24}>24 shows</option>
                <option value={48}>48 shows</option>
                <option value={100}>100 shows</option>
              </select>
            </div>
          </div>
        </div>

        {/* Results */}
        {loading ? (
          <LoadingSpinner />
        ) : error ? (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <div className="text-red-600 font-semibold">Error</div>
            <div className="text-red-500 mt-1">{error}</div>
            <div className="mt-4 flex gap-2 justify-center">
              <button
                onClick={() => setError(null)}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
              >
                Retry
              </button>
              <button
                onClick={testConnection}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Test API Connection
              </button>
            </div>
          </div>
        ) : (
          <>
            {/* Results Header */}
            {pagination && (
              <div className="mb-6 flex items-center justify-between">
                <div className="text-gray-600">
                  Showing {episodes.length} of {pagination.total_count} episodes
                </div>
                {pagination.total_count > 0 && (
                  <div className="flex items-center gap-2 text-sm text-gray-500">
                    <StarIcon className="h-4 w-4" />
                    Page {pagination.current_page} of {pagination.total_pages}
                  </div>
                )}
              </div>
            )}

            {/* Episodes Grid */}
            {episodes.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {episodes.map((episode) => (
                  <TVShowCard key={episode.id} episode={episode} />
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <TvIcon className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  No episodes found
                </h3>
                <p className="text-gray-600 mb-4">
                  Try adjusting your filters or date range
                </p>
                <button
                  onClick={resetFilters}
                  className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
                >
                  Reset Filters
                </button>
              </div>
            )}

            {/* Pagination */}
            {pagination && pagination.total_pages > 1 && (
              <div className="mt-8 flex justify-center">
                <nav className="flex items-center gap-2">
                  <button
                    onClick={() => handlePageChange(currentPage - 1)}
                    disabled={currentPage <= 1}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Previous
                  </button>
                  
                  {[...Array(Math.min(5, pagination.total_pages))].map((_, i) => {
                    const pageNum = i + 1;
                    return (
                      <button
                        key={pageNum}
                        onClick={() => handlePageChange(pageNum)}
                        className={`px-4 py-2 text-sm font-medium rounded-lg transition-colors ${
                          currentPage === pageNum
                            ? 'bg-indigo-600 text-white'
                            : 'text-gray-700 bg-white border border-gray-300 hover:bg-gray-50'
                        }`}
                      >
                        {pageNum}
                      </button>
                    );
                  })}
                  
                  <button
                    onClick={() => handlePageChange(currentPage + 1)}
                    disabled={currentPage >= pagination.total_pages}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Next
                  </button>
                </nav>
              </div>
            )}
          </>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="text-center text-gray-600">
            <p>TV Shows API Frontend • Built with React & Tailwind CSS</p>
            <p className="text-sm mt-1">
              Data provided by{' '}
              <a 
                href="https://www.tvmaze.com/" 
                target="_blank" 
                rel="noopener noreferrer"
                className="text-indigo-600 hover:text-indigo-700"
              >
                TVMaze
              </a>
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;