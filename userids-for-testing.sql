with base as (
    select substr(event_userID, 1, 1) userID_first_char, event_userID, cast(jwt_feat as bigint) as feat, jwt_exp::timestamp, param_jwtoken
    from 'cloudwatch/search.2026.01.11.13.30.tsv'
    where true
        and jwt_feat != 'nil'
        and length(event_userID) >= 32
        and jwt_exp::timestamp > now()
)

select distinct *
from base
where not feat & (1<<1) and feat & (cast(1 as bigint)<<44)
--where feat & (1<<6)
order by 4