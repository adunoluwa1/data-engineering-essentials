SELECT CURRENT_TIME;

SELECT CURRENT_DATE;

SELECT NOW(),CURRENT_TIMESTAMP,
	DATE_TRUNC('Day',CURRENT_TIMESTAMP) Trunc,
	DATE_PART('MONTH',CURRENT_TIMESTAMP)  months,
	EXTRACT('MONTH' from CURRENT_TIMESTAMP) extract_date,
	TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM') charr;


select 	'15:30'::time,
		'2025-06-01'::timestamp,
		'15:30'::time - '12:30'::time as interval_exp,
		pg_typeof('15:30'::time - '12:30'::time) as interval_type,
		AGE(NOW(),'2025-02-14'::timestamp);

select current_setting('timezone');

/* Converting Timezones */
select 	'2025-02-14 10:30:00 -05'::timestamptz,
		'2025-02-14 8:30:00 -07'::timestamptz,
		'2025-02-14 10:30:00'::timestamptz at time zone 'America/Denver',
		timezone('America/Denver','2025-02-14 10:30:00 -05'::timestamptz),
		'2025-02-14 10:30:00'::timestamptz at time zone 'America/Los_Angeles';

/* Datetime keywords and functions */
select 'current_date' date_function, current_date :: varchar
union 
select 'current_time' date_function, current_time :: varchar
union 
select 'current_timestamp' date_function, current_timestamp :: varchar
union 
select 'now' date_function, now() :: varchar
union 
select 'now_timezone_convert' date_function, timezone('UTC',now()) :: varchar
union 
select 'localtime' date_function, localtime :: varchar
union 
select 'localtimestamp' date_function, localtimestamp :: varchar
union 
select 'time_of_day' date_function, timeofday() :: varchar;



select typname, typcategory 
from pg_type
where typcategory = 'E';