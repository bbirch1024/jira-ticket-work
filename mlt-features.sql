with feats as (
  select
    e.event_eventType,
    case when e.param_feat <> 'nil' or e.jwt_feat is not null then 'has_feat' else '' end has_URL_feat, 
    case when e.param_feat <> 'nil' then 'URL_feat' else '' end has_URL_feat, 
    case when e.jwt_feat is null then '' else 'jwToken_feat' end as has_jwToken_feat,
    case when e.jwt_feat is not null and e.jwt_feat & 64 = 64 then 'FeatureSport' else '' end as has_JwtFeatureSport,    
    case when e.param_feat <> 'nil' and cast(e.param_feat as bigint) & 64 = 64 then 'FeatureSport' else '' end as has_ParamFeatureSport,    
    from 'data/cloudwatch/path=related-and-resultCount=0.tsv' as e
)

select 'mlt_event_with_zero_results', *
from feats 

