create database BookMyShow;
use BookMyShow;


drop table if exists BookMyShow;

create table bms (seat_no int ,is_empty varchar(10));
insert into bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');

select * from bms;


-- write  a query 3 or more consecutive empty seats.
-- 4	Y	2	2	3
-- 5	Y	2	3	2
-- 6	Y	3	2	2
-- 8	Y	2	2	3
-- 9	Y	2	3	3
-- 10	Y	3	3	2
-- 11	Y	3	2	2

-- Approach 1 Using lag & lead method
with cte as (select *,
lag(is_empty) over (order by seat_no) as prv_one_day,
lag(is_empty,2) over (order by seat_no) as prv_two_day,
lead(is_empty) over (order by seat_no) as next_one_day,
lead(is_empty,2) over (order by seat_no) as next_two_day
from bms)
select seat_no,is_empty from 
cte 
where is_empty ='y' and prv_one_day='y' and prv_two_day='y'
or 
is_empty ='y' and next_one_day='y' and next_two_day='y'
 order by seat_no
;

-- Approach 2
with cte as (select*,
 row_number() over()as rn ,
  seat_no-row_number() over() as diff
 from bms
 where is_empty='y')
, cnt as (select diff, count(1) from cte 
-- where diff>=3 or diff<1
 group by 1
 having count(1)>=3)
  select *,seat_no-rn from cte
  where seat_no-rn >1 and seat_no-rn <4
   -- where diff in (select diff from cnt)
   ;
   
   
--    Approach 3
select * from ( select *,
sum(case when is_empty ='y' then 1 else 0 end ) over (rows between 2 preceding and current row) as rn,
sum(case when is_empty ='y' then 1 else 0 end ) over (rows between 1 preceding and 1 following) as rn1,
sum(case when is_empty ='y' then 1 else 0 end ) over (rows between current row and 2 following) as rn2
from bms) a
 where rn=3 or rn1=3 or rn2=3
   
  