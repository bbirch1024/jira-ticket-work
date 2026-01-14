with tots as (select count(*) as number from 'cloudwatch/search.2026.01.11.13.30.tsv' where event_userID != 'nil' )

select substr(event_userID, 1, 1) userID_first_char, round(100*count(*)/(select number from tots), 2) as percentage
from 'cloudwatch/search.2026.01.11.13.30.tsv'
where event_userID != 'nil'
group by 1 order by 1
