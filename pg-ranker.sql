WITH latest AS (
    SELECT a.*
    FROM feed AS a
    JOIN (
        SELECT id, MAX(version) AS mv
        FROM feed
        GROUP BY id
    ) AS b
      ON a.id = b.id
     AND a.version = b.mv
)
SELECT
    id AS feed_id,
    version AS latest_version,
    title AS feed_title,
    personalization_params
FROM latest
WHERE is_personalized
  AND personalization_params LIKE '%reorder: true%'
ORDER BY feed_title, feed_id DESC;
