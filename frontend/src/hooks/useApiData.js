import { useState, useCallback } from 'react';
import axios from 'axios';

export const useApiData = (baseUrl) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async (endpoint, params = {}) => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await axios.get(`${baseUrl}${endpoint}`, { params });
      setData(response.data);
      return response.data;
    } catch (err) {
      const errorMessage = err.response?.data?.error || 
                          err.message || 
                          'An unexpected error occurred';
      setError(errorMessage);
      console.error('API Error:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [baseUrl]);

  const testConnection = useCallback(async () => {
    try {
      const response = await axios.get(`${baseUrl}/up`);
      console.log('API Health Check:', response.status === 200 ? 'OK' : 'Failed');
      return response.status === 200;
    } catch (err) {
      console.error('API Health Check Failed:', err.message);
      return false;
    }
  }, [baseUrl]);

  return { 
    data, 
    loading, 
    error, 
    fetchData, 
    testConnection,
    setError 
  };
};