import { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

export const useFilterOptions = () => {
  const [networks, setNetworks] = useState([]);
  const [countries, setCountries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const ratingOptions = [
    { value: '', label: 'Any Rating' },
    { value: '9.0', label: '9.0+ Excellent' },
    { value: '8.0', label: '8.0+ Very Good' },
    { value: '7.0', label: '7.0+ Good' },
    { value: '6.0', label: '6.0+ Above Average' }
  ];

  useEffect(() => {
    const fetchFilterOptions = async () => {
      try {
        setLoading(true);
        
        const [networksResponse, countriesResponse] = await Promise.all([
          axios.get(`${API_BASE_URL}/api/v1/networks`),
          axios.get(`${API_BASE_URL}/api/v1/countries`)
        ]);

        setNetworks(networksResponse.data.data || []);
        setCountries(countriesResponse.data.data || []);
        setError(null);
      } catch (err) {
        console.error('Error fetching filter options:', err);
        setError(err.message);
        
        // Fallback to default values on error
        setNetworks([
          'HBO', 'Netflix', 'NBC', 'CBS', 'ABC', 'Fox', 'ESPN', 'CNN', 'MSNBC', 'Comedy Central'
        ]);
        setCountries([
          'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France'
        ]);
      } finally {
        setLoading(false);
      }
    };

    fetchFilterOptions();
  }, []);

  return {
    networks,
    countries,
    ratingOptions,
    loading,
    error
  };
};