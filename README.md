
# Test the query 

```
$ streamco-env -env test pages bash
2025/12/12 16:11:24 forwarding localhost:5492 -> cms-pg17-data.cg5rzofe58xa.ap-southeast-2.rds.amazonaws.com:5432
2025/12/12 16:11:26 Port 5492 opened for sessionId bill.birch-zug428quy3zgju4icxql2oyeuq.

$ env | grep CMS
CMS_DATABASE_URL=postgres://pagesapi:REDACTED@localhost:5492/dbcmsv1?application_name=bill.birch

$ psql -f ../BS-2623-hubot-ranker-report/reordered-feeds.sql "${CMS_DATABASE_URL}"
 id  | latest_version |      feed_title      | number_of_pages 
-----+----------------+----------------------+-----------------
 659 |              9 | User Group Test Feed |               1
(1 row)
```

```
$ psql -f ../BS-2623-hubot-ranker-report/pg-ranker.sql "${CMS_DATABASE_URL}"
 feed_id | latest_version |      feed_title      |                    personalization_params                    
---------+----------------+----------------------+--------------------------------------------------------------
     659 |              9 | User Group Test Feed | UserIDBetween('3', '5') ? {reorder: true} : {skipFeed: true}
(1 row)
```

Prototype

```
$  streamco-env -env prod -tunnel CMS_DATABASE_URL hubot go1.24.4 run . -run="rec ranking order"
```

```
Feed ID  Version  Title                                              Pages  
2184     206      All Action                                         1536   
1677     40       Combat Fans: Enjoy More Entertainment on Stan      89     
121      560      Comedy TV                                          5877   
120      854      Drama TV                                           5887   
1674     53       Football Fans: Enjoy More Entertainment on Stan    322    
3508     24       Football Fans: Your End Of Season Sorted           81     
3792     15       For You: Football Replays                          8      
1675     32       Motorsport Fans: Enjoy More Entertainment on Stan  33     
2325     8        Olympics Fans: Enjoy More Entertainment on Stan    61     
1673     45       Rugby Fans: Enjoy More Entertainment on Stan       558    
123      536      Sci-Fi and Supernatural                            4783   
1802     40       Sports Documentaries                               448    
1676     32       Tennis Fans: Enjoy More Entertainment on Stan      295    
3588     14       Welcome To Stan: New & Hot                         182    
git status```
