-- Analytical Queries for TV Shows API
-- These queries demonstrate CTE, window functions, and aggregates

-- 1. Top Networks by Show Count with Rolling 7-Day Episode Releases (Window Function + CTE)
WITH daily_releases AS (
  SELECT 
    d.name AS network_name,
    rd.airdate,
    COUNT(DISTINCT e.id) AS episodes_released,
    COUNT(DISTINCT ts.id) AS shows_active
  FROM distributors d
  JOIN tv_shows ts ON ts.network_id = d.id
  JOIN episodes e ON e.tv_show_id = ts.id
  JOIN release_dates rd ON rd.episode_id = e.id
  WHERE rd.airdate >= CURRENT_DATE - INTERVAL '30 days'
    AND rd.airdate <= CURRENT_DATE + INTERVAL '90 days'
  GROUP BY d.name, rd.airdate
),
network_rolling_stats AS (
  SELECT 
    network_name,
    airdate,
    episodes_released,
    shows_active,
    SUM(episodes_released) OVER (
      PARTITION BY network_name 
      ORDER BY airdate 
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7day_episodes,
    AVG(episodes_released::decimal) OVER (
      PARTITION BY network_name 
      ORDER BY airdate 
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_7day_episodes
  FROM daily_releases
)
SELECT 
  network_name,
  MAX(shows_active) as total_active_shows,
  SUM(episodes_released) as total_episodes,
  MAX(rolling_7day_episodes) as peak_7day_episodes,
  ROUND(AVG(avg_7day_episodes), 2) as avg_daily_episodes,
  RANK() OVER (ORDER BY SUM(episodes_released) DESC) as network_rank
FROM network_rolling_stats
GROUP BY network_name
ORDER BY total_episodes DESC
LIMIT 10;

-- 2. Show Performance Analysis by Genre and Rating (CTE + Aggregate)
WITH show_metrics AS (
  SELECT 
    ts.id,
    ts.name,
    ts.rating,
    ts.status,
    UNNEST(string_to_array(ts.genres, ', ')) AS genre,
    COUNT(e.id) AS total_episodes,
    COUNT(CASE WHEN rd.airdate >= CURRENT_DATE THEN 1 END) AS upcoming_episodes,
    MIN(rd.airdate) AS first_airdate,
    MAX(rd.airdate) AS last_airdate,
    AVG(e.rating) AS avg_episode_rating
  FROM tv_shows ts
  LEFT JOIN episodes e ON e.tv_show_id = ts.id
  LEFT JOIN release_dates rd ON rd.episode_id = e.id
  WHERE ts.genres IS NOT NULL AND ts.genres != ''
  GROUP BY ts.id, ts.name, ts.rating, ts.status, genre
),
genre_stats AS (
  SELECT 
    genre,
    COUNT(DISTINCT id) AS shows_count,
    ROUND(AVG(rating), 2) AS avg_show_rating,
    ROUND(AVG(avg_episode_rating), 2) AS avg_episode_rating,
    SUM(total_episodes) AS total_episodes,
    SUM(upcoming_episodes) AS upcoming_episodes,
    ROUND(AVG(total_episodes), 1) AS avg_episodes_per_show
  FROM show_metrics
  WHERE genre IS NOT NULL AND trim(genre) != ''
  GROUP BY genre
  HAVING COUNT(DISTINCT id) >= 3  -- Only genres with 3+ shows
)
SELECT 
  genre,
  shows_count,
  avg_show_rating,
  avg_episode_rating,
  total_episodes,
  upcoming_episodes,
  avg_episodes_per_show,
  ROUND(
    (upcoming_episodes::decimal / NULLIF(total_episodes, 0)) * 100, 
    1
  ) AS upcoming_percentage,
  NTILE(4) OVER (ORDER BY avg_show_rating) AS rating_quartile
FROM genre_stats
ORDER BY avg_show_rating DESC, shows_count DESC;

-- 3. Release Schedule Density Analysis (Window Function + CTE)
WITH daily_schedule AS (
  SELECT 
    rd.airdate,
    rd.airtime,
    COUNT(*) AS episodes_count,
    COUNT(DISTINCT ts.network_id) AS networks_count,
    COUNT(DISTINCT ts.id) AS shows_count,
    STRING_AGG(DISTINCT d.name, ', ' ORDER BY d.name) AS networks
  FROM release_dates rd
  JOIN episodes e ON e.id = rd.episode_id
  JOIN tv_shows ts ON ts.id = e.tv_show_id
  LEFT JOIN distributors d ON d.id = ts.network_id
  WHERE rd.airdate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
  GROUP BY rd.airdate, rd.airtime
),
schedule_with_density AS (
  SELECT 
    airdate,
    airtime,
    episodes_count,
    networks_count,
    shows_count,
    networks,
    LAG(episodes_count, 1, 0) OVER (ORDER BY airdate, airtime) AS prev_episodes,
    LEAD(episodes_count, 1, 0) OVER (ORDER BY airdate, airtime) AS next_episodes,
    SUM(episodes_count) OVER (
      ORDER BY airdate 
      ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS episodes_3hour_window,
    EXTRACT(dow FROM airdate) AS day_of_week,  -- 0=Sunday, 6=Saturday
    EXTRACT(hour FROM (airtime||':00')::time) AS hour_of_day
  FROM daily_schedule
),
peak_analysis AS (
  SELECT 
    *,
    CASE 
      WHEN episodes_count > prev_episodes AND episodes_count > next_episodes THEN 'Peak'
      WHEN episodes_count < prev_episodes AND episodes_count < next_episodes THEN 'Valley'
      ELSE 'Normal'
    END AS density_pattern,
    CASE 
      WHEN day_of_week IN (0, 6) THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type,
    CASE 
      WHEN hour_of_day BETWEEN 6 AND 11 THEN 'Morning'
      WHEN hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon'
      WHEN hour_of_day BETWEEN 18 AND 22 THEN 'Prime Time'
      ELSE 'Late Night/Early Morning'
    END AS time_slot
  FROM schedule_with_density
)
SELECT 
  day_type,
  time_slot,
  COUNT(*) AS slot_count,
  ROUND(AVG(episodes_count), 1) AS avg_episodes,
  MAX(episodes_count) AS max_episodes,
  ROUND(AVG(networks_count), 1) AS avg_networks,
  ROUND(AVG(episodes_3hour_window), 1) AS avg_3hour_density,
  COUNT(CASE WHEN density_pattern = 'Peak' THEN 1 END) AS peak_slots,
  ROUND(
    COUNT(CASE WHEN density_pattern = 'Peak' THEN 1 END)::decimal / COUNT(*) * 100, 
    1
  ) AS peak_percentage
FROM peak_analysis
GROUP BY day_type, time_slot
ORDER BY 
  CASE day_type WHEN 'Weekday' THEN 1 ELSE 2 END,
  CASE time_slot 
    WHEN 'Morning' THEN 1
    WHEN 'Afternoon' THEN 2
    WHEN 'Prime Time' THEN 3
    ELSE 4
  END;