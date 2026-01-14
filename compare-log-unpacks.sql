select old.jwt_exp as oldexp, new.jwt_exp as newexp, strftime(TIMESTAMP 'epoch' + INTERVAL '1 second' * new.jwt_exp::double, '%Y-%m-%dT%H:%M:%SZ') as newts
from read_csv('bar.tsv', sep = '\t', header = true) new
join read_csv('cloudwatch/search.2026.01.11.13.30.tsv', sep = '\t', header = true) old
on new.event_serverTime = old.event_serverTime
where true
  and new.jwt_exp <> 'nil'
  and old.jwt_exp <> 'nil'
  and strftime(TIMESTAMP 'epoch' + INTERVAL '1 second' * new.jwt_exp::double, '%Y-%m-%dT%H:%M:%SZ') <> old.jwt_exp
order by 1,2

