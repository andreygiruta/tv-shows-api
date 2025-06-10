import { useState, useEffect } from 'react';

export const useDebouncedFilters = (filters, delay = 500) => {
  const [debouncedFilters, setDebouncedFilters] = useState(filters);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedFilters(filters);
    }, delay);

    return () => clearTimeout(timer);
  }, [filters, delay]);

  return debouncedFilters;
};