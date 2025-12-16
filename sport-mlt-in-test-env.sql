-- get program ids from test environment
with sport as (
	select
	    id,
	    title,
	    type,
	    kids,
	    bundle,
	    genres,
	    duration
	from
	    program
	where true
		and bundle in ('sport', 'olympics', 'optussport', 'ppv')
	    and expiry_date > EXTRACT(epoch FROM NOW())
	    and genres::text like '%Sport%'
	    and genres::text not like '%Animation%'
	    and duration <> 0
	    --and kids = false
		--and type in ('movie', 'series', 'linear')
--	    and not ( false
--	    	or title like '%louis%'
--	    	or title like '%Tabiul%' 
--	    	or title like '%Test%'
--	    	or title like '%Yoyo%'
--	    	or title like '%/2025%'
--	    )

	    order by id
),
--select * from sport
mlt as (
	select a.id as id, array_agg(b.id) as like_this 
	from sport as a 
	join sport as b on a.id <> b.id
	where true
		and a.genres::text like '%Rugby%'
		and b.genres::text like '%Rugby%'
	group by 1
	union all
	select a.id as id, array_agg(b.id) as like_this 
	from sport as a 
	join sport as b on a.id <> b.id
	where true
		and a.genres::text like '%Football%'
		and b.genres::text like '%Football%'
	group by 1
	union all
	select a.id as id, array_agg(b.id) as like_this 
	from sport as a 
	join sport as b on a.id <> b.id
	where true
		and a.genres::text like '%Tennis%'
		and b.genres::text like '%Tennis%'
	group by 1
	union all
	select a.id as id, array_agg(b.id) as like_this 
	from sport as a 
	join sport as b on a.id <> b.id
	where true
		and a.genres::text like '%Combat%'
		and b.genres::text like '%Combat%'
	group by 1
)
select mlt.id, sport.title, like_this 
from mlt
join sport on mlt.id = sport.id

