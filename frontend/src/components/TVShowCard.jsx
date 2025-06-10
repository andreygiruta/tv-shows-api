import React, { memo } from 'react';
import { CalendarIcon, ClockIcon, StarIcon, TvIcon } from '@heroicons/react/24/outline';
import { format } from 'date-fns';

const TVShowCard = memo(({ episode }) => {
  // Determine the best image to use (episode image first, then show image)
  const getImageUrl = () => {
    return episode.image_medium || 
           episode.image_original || 
           episode.show.image_medium || 
           episode.show.image_original || 
           null;
  };

  const imageUrl = getImageUrl();

  const formatDate = (dateString) => {
    try {
      return format(new Date(dateString), 'MMM dd, yyyy');
    } catch {
      return dateString;
    }
  };

  const formatTime = (timeString) => {
    if (!timeString) return 'TBA';
    try {
      const [hours, minutes] = timeString.split(':');
      const date = new Date();
      date.setHours(parseInt(hours), parseInt(minutes));
      return format(date, 'h:mm a');
    } catch {
      return timeString;
    }
  };

  const getRatingColor = (rating) => {
    if (!rating || rating === 0) return 'text-gray-400';
    if (rating >= 8) return 'text-green-600';
    if (rating >= 6) return 'text-yellow-600';
    return 'text-red-600';
  };

  const stripHtml = (html) => {
    if (!html) return '';
    return html.replace(/<[^>]*>/g, '');
  };

  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200">
      {/* Show Image */}
      <div className="h-48 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-t-lg relative overflow-hidden">
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={episode.name || episode.show.name}
            className="absolute inset-0 w-full h-full object-contain bg-gray-100"
            onError={(e) => {
              e.target.style.display = 'none';
              e.target.nextElementSibling.style.display = 'flex';
            }}
          />
        ) : null}
        <div className={`absolute inset-0 flex flex-col items-center justify-center text-white ${imageUrl ? 'hidden' : 'flex'}`}>
          <TvIcon className="h-16 w-16 mb-2 opacity-80" />
          <span className="text-sm font-medium opacity-90">No Image</span>
        </div>
      </div>

      <div className="p-4">
        {/* Show Title */}
        <h3 className="font-semibold text-lg text-gray-900 mb-1 line-clamp-1">
          {episode.show.name}
        </h3>

        {/* Episode Info */}
        <div className="text-sm text-gray-600 mb-2">
          <span className="font-medium">S{episode.season}E{episode.episode_number}</span>
          {episode.name && episode.name !== episode.show.name && (
            <span className="ml-1">• {episode.name}</span>
          )}
        </div>

        {/* Air Date & Time */}
        <div className="flex items-center gap-4 text-sm text-gray-600 mb-3">
          <div className="flex items-center gap-1">
            <CalendarIcon className="h-4 w-4" />
            <span>{formatDate(episode.airdate)}</span>
          </div>
          <div className="flex items-center gap-1">
            <ClockIcon className="h-4 w-4" />
            <span>{formatTime(episode.airtime)}</span>
          </div>
        </div>

        {/* Network & Rating */}
        <div className="flex items-center justify-between mb-3">
          <div className="text-sm">
            <span className="font-medium text-gray-900">
              {episode.show.network?.name || 'Unknown Network'}
            </span>
            {episode.show.network?.country && (
              <span className="text-gray-500 ml-1">
                ({episode.show.network.country})
              </span>
            )}
          </div>
          
          {episode.show.rating && parseFloat(episode.show.rating) > 0 && (
            <div className="flex items-center gap-1">
              <StarIcon className={`h-4 w-4 ${getRatingColor(parseFloat(episode.show.rating))}`} />
              <span className={`text-sm font-medium ${getRatingColor(parseFloat(episode.show.rating))}`}>
                {parseFloat(episode.show.rating).toFixed(1)}
              </span>
            </div>
          )}
        </div>

        {/* Genres */}
        {episode.show.genres && episode.show.genres.length > 0 && (
          <div className="flex flex-wrap gap-1 mb-3">
            {episode.show.genres.slice(0, 3).map((genre, index) => (
              <span
                key={index}
                className="px-2 py-1 bg-indigo-100 text-indigo-700 text-xs font-medium rounded-full"
              >
                {genre}
              </span>
            ))}
            {episode.show.genres.length > 3 && (
              <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs font-medium rounded-full">
                +{episode.show.genres.length - 3}
              </span>
            )}
          </div>
        )}

        {/* Summary */}
        {episode.summary && (
          <p className="text-sm text-gray-600 line-clamp-3">
            {stripHtml(episode.summary)}
          </p>
        )}

        {/* Runtime */}
        {episode.runtime && (
          <div className="mt-3 pt-3 border-t border-gray-100 text-xs text-gray-500">
            Runtime: {episode.runtime} minutes
          </div>
        )}
      </div>
    </div>
  );
}, (prevProps, nextProps) => {
  // Only re-render if episode id changes
  return prevProps.episode.id === nextProps.episode.id;
});

TVShowCard.displayName = 'TVShowCard';

export default TVShowCard;