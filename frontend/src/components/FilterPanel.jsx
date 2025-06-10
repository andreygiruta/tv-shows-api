import React, { memo } from 'react';
import { useFilterOptions } from '../hooks/useFilterOptions';

const FilterPanel = memo(({
  distributor,
  country,
  rating,
  onDistributorChange,
  onCountryChange,
  onRatingChange,
  onReset
}) => {
  const { networks, countries, ratingOptions, loading, error } = useFilterOptions();

  if (error) {
    console.warn('Failed to load filter options from API, using fallback data:', error);
  }

  return (
    <>
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Network/Distributor
        </label>
        <input
          type="text"
          value={distributor}
          onChange={(e) => onDistributorChange(e.target.value)}
          placeholder={loading ? "Loading networks..." : "e.g., HBO, Netflix, NBC"}
          list="networks"
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          disabled={loading}
        />
        <datalist id="networks">
          {networks.map((network) => (
            <option key={network} value={network} />
          ))}
        </datalist>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Country
        </label>
        <select
          value={country}
          onChange={(e) => onCountryChange(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          disabled={loading}
        >
          <option value="">All Countries</option>
          {countries.map((countryOption) => (
            <option key={countryOption} value={countryOption}>
              {countryOption}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Min Rating
        </label>
        <select
          value={rating}
          onChange={(e) => onRatingChange(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
        >
          {ratingOptions.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </div>
    </>
  );
});

FilterPanel.displayName = 'FilterPanel';

export default FilterPanel;