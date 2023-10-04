create database BookMyShow;
use BookMyShow;
show table status;
show tables;
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
WITH cte AS 
 (SELECT *,
   LAG(is_empty)  OVER (ORDER BY seat_no) AS prv_one_day,
   LAG(is_empty,2) OVER (ORDER BY seat_no) AS prv_two_day,
   LEAD(is_empty)  OVER (ORDER BY seat_no) AS next_one_day,
   LEAD(is_empty,2) OVER (ORDER BY seat_no) AS next_two_day
 FROM bms)
SELECT 
    seat_no, is_empty
FROM
    cte
WHERE
     is_empty = 'y' AND prv_one_day = 'y' AND prv_two_day = 'y'
     OR 
     is_empty = 'y' AND prv_one_day = 'y' AND next_one_day = 'y'
     OR 
     is_empty = 'y' AND next_one_day = 'y'AND next_two_day = 'y'
ORDER BY seat_no
;

-- Approach 2
WITH cte AS (
    SELECT *,
    ROW_NUMBER() OVER(ORDER BY seat_no) AS rn ,
    seat_no-ROW_NUMBER() OVER(ORDER BY seat_no) AS diff
    FROM bms
    WHERE is_empty='y'
  )
, cnt AS 
    (SELECT diff, COUNT(1)
    FROM
         cte
	GROUP BY 1
    )
SELECT  *
FROM
    cte
WHERE
    seat_no - rn > 1 AND seat_no - rn < 4
   ;
   
   
--    Approach 3
SELECT * FROM 
  ( SELECT *,
      SUM(CASE WHEN is_empty ='y' THEN 1 ELSE 0 END ) OVER (ROWS BETWEEN 2 PRECEDING and CURRENT ROW) as rn,
      SUM(CASE WHEN is_empty ='y' THEN 1 ELSE 0 END ) OVER (ROWS BETWEEN 1 PRECEDING and 1 FOLLOWING) as rn1,
      SUM(CASE WHEN is_empty ='y' THEN 1 ELSE 0 END ) OVER (ROWS BETWEEN CURRENT ROW and 2 FOLLOWING) as rn2
  FROM bms) a
 WHERE rn=3 OR rn1=3 OR rn2=3;
 
 
 --    Approach 4
 SELECT  is_empty,seat_no
FROM (
  SELECT is_empty,seat_no,
         LEAD(is_empty, 2) OVER (ORDER BY seat_no) AS next_num,
         LAG(is_empty, 1) OVER (ORDER BY seat_no) AS prev_num
  FROM bms
  WHERE is_empty='Y'
) AS temp
WHERE is_empty = next_num AND is_empty = prev_num;

