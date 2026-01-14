-- Look for expired tokens in the cloudwatch logged searches
with base as (
    select *
    from  read_csv('cloudwatch/search.2026.01.11.13.30.tsv', sep = '\t', header = true)
    where true
        and jwt_exp <> 'nil'
)
select count(*) as number_expired_tokens
from  base
where true
    and jwt_exp::double > event_serverTime::double
