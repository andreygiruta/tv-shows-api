import { useState, useEffect, useMemo } from 'react';
import { format, addDays } from 'date-fns';
import { useApiData } from './useApiData';
import { useDebouncedFilters } from './useDebouncedFilters';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

export const useTvShows = () => {
  // Filter states
  const [filters, setFilters] = useState({
    dateFrom: format(new Date(), 'yyyy-MM-dd'),
    dateTo: format(addDays(new Date(), 7), 'yyyy-MM-dd'),
    distributor: '',
    country: '',
    rating: '',
    perPage: 12
  });

  const [currentPage, setCurrentPage] = useState(1);
  const [episodes, setEpisodes] = useState([]);
  const [pagination, setPagination] = useState(null);

  const { data, loading, error, fetchData, testConnection, setError } = useApiData(API_BASE_URL);
  const debouncedFilters = useDebouncedFilters(filters, 300);

  // Memoized filter params for API call
  const apiParams = useMemo(() => {
    const params = {
      date_from: debouncedFilters.dateFrom,
      date_to: debouncedFilters.dateTo,
      page: currentPage,
      per_page: debouncedFilters.perPage
    };

    if (debouncedFilters.distributor) params.distributor = debouncedFilters.distributor;
    if (debouncedFilters.country) params.country = debouncedFilters.country;
    if (debouncedFilters.rating) params.rating = debouncedFilters.rating;

    return params;
  }, [debouncedFilters, currentPage]);

  // Fetch episodes when params change
  useEffect(() => {
    const fetchEpisodes = async () => {
      try {
        await fetchData('/api/v1/tvshows', apiParams);
      } catch (err) {
        // Error is handled by useApiData hook
      }
    };

    fetchEpisodes();
  }, [fetchData, apiParams]);

  // Update local state when data changes
  useEffect(() => {
    if (data) {
      setEpisodes(data.data || []);
      setPagination(data.pagination || null);
    }
  }, [data]);

  // Reset to page 1 when filters change (except perPage)
  useEffect(() => {
    setCurrentPage(1);
  }, [
    debouncedFilters.dateFrom, 
    debouncedFilters.dateTo, 
    debouncedFilters.distributor, 
    debouncedFilters.country, 
    debouncedFilters.rating
  ]);

  const updateFilter = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const resetFilters = () => {
    setFilters({
      dateFrom: format(new Date(), 'yyyy-MM-dd'),
      dateTo: format(addDays(new Date(), 7), 'yyyy-MM-dd'),
      distributor: '',
      country: '',
      rating: '',
      perPage: 12
    });
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  return {
    // Data
    episodes,
    pagination,
    loading,
    error,
    
    // Filters
    filters,
    updateFilter,
    resetFilters,
    
    // Pagination
    currentPage,
    handlePageChange,
    
    // Actions
    testConnection,
    setError
  };
};