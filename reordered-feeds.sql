-- BS-2623 Re-ordered feeds from cms_public feed table which have pages linked in page_feed
--
with latest_feed as (
    select a.*
    from feed as A
    join  (
      select id, max(version) as mv
      from feed -- should be exact copy of cms database. This db handles the layout of pages & what feed is positione where
      group by id
    ) as B
    on A.id = B.id and A.version = B.mv
    order by id, version
),
pages as (
 select feed_id as fid, count(id) as number_of_pages
 from page_feed
 group by feed_id
)
select
    lf.id,
    version as latest_version,
    title as feed_title,
    pages.number_of_pages
    --  type as feedDisplayType,
    --  source as feedSource,
from latest_feed lf
left outer join pages
on lf.id = pages.fid
where true
and is_personalized
and personalization_params like '%reorder: true%'
order by feed_title, lf.id desc

