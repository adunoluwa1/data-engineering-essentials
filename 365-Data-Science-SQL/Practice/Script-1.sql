-- create database sql_tutorials;

-- create user sql_tutorial_user with encrypted password '0001';

-- grant all on database sql_tutorials to sql_tutorial_user;

-- alter database sql_tutorials owner to sql_tutorial_user;

/*	Arrarys	*/
create table array_table (
	id SERIAL primary key,
	myarray INTEGER[]
);

select * from array_table;

insert into array_table(myarray) values
(array[1,2,3,4,5,6]);

insert into array_table(myarray) values
(array[1,4,5,6]);

insert into array_table(myarray) values
(array[9,14,25,36]);

select * from array_table
where 2 = ANY(myarray);

select * from array_table
where array[1,4,5,6]::integer[] = myarray;



select id, unnest(myarray) unnested_array
from array_table;

/*	Ranges	*/

create table job_board (
	id serial primary key,
	job text,
	salary numeric,
	salary_numrange numrange,
	salary_intrange int4range);

insert  into job_board (job, salary, salary_numrange, salary_intrange) values
('Engineer I', 120000, NUMRANGE(95000,130000), INT4RANGE(95000,130000)),
('Engineer II', 150000, NUMRANGE(135000,170000), INT4RANGE(135000,170000)),
('Engineer III', 210000, NUMRANGE(185000,250000), INT4RANGE(185000,250000));

select * from job_board;


select * from job_board
where salary_intrange  @> 100000;

select * from job_board
where salary_numrange  @> 100000;

select * from job_board
where salary_numrange  @> 100000::numeric;


/*	Nested Data	*/
create table customers (
	id serial primary key,
	name text,
	address JSONB );

insert into customers (name, address) values
('John Doe','{"street":"123 Main St", "city":"New York", "state":"NY","zip":"10001"}')

select name,
address-> 'zip' AS zip,
address->> 'city' AS city,
address->> 'state' AS state
from customers;


create index idx_customers_address_city on customers((address->>'city'));

update customers
set address = jsonb_set(address, '{city}','"Los Angeles"')
where name = 'John Doe';


select * from customers;


/* window functions	*/
create table orders( 
	order_id serial primary key,
	customer_id integer not null,
	order_date date not null,
	order_total decimal(10,2) not null
);

insert into orders (customer_id, order_date, order_total) values 
(1, '2022-01-01', 100.00),
(1, '2022-02-01', 50.00),
(1, '2022-03-01', 75.00),
(2, '2022-01-15', 200.00),
(2, '2022-02-15', 150.00),
(3, '2022-01-31', 75.00),
(3, '2022-02-28', 100.00),
(3, '2022-03-31', 50.00);

select * from orders;

select customer_id, order_total,
sum(order_total) over(order by customer_id, order_date) running_order_total,
sum(order_total) over(partition by customer_id order by customer_id, order_date) customer_running_order_total
from orders
order by 1, order_date;

select customer_id, order_total
from orders
qualify row_number() over(partition by customer_id order by order_total desc) = 1;
-- order by 1, order_date;
 

/*	joins	*/
create table users (
	user_id serial primary key,
	username varchar(50) not null,
	email varchar(50) not null
	);

insert into users (username, email) values
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com');

drop table if exists orders;

create table orders( 
	order_id serial primary key,
	user_id integer not null references users(user_id),
	order_date date not null,
	total_amount numeric(10,2) not null
);

insert into orders (user_id, order_date, total_amount) values 
(1, '2022-04-01', 50.00),
(1, '2022-03-15', 25.00),
(2, '2022-04-02', 100.00),
(3, '2022-04-01', 75.00),
(3, '2022-03-20', 30.00),
(3, '2022-03-01', 20.00);


--normal
select * from users;

select * from orders;

select  u.username, u.email, o.order_id, max(o.order_date) latest_order
from orders o 
right join users u
using(user_id)
group by 1,2,3
order by 1;

--lateral join
select u.username, order_id, order_date
from users u 
left join lateral(
	select order_id, order_date
	from orders 
	where user_id = u.user_id
	order by order_date desc
	limit 1
	) o
on true;

-- first_value() window function
select distinct u.username,
first_value(o.order_id) over(partition by o.user_id order by order_date desc) latest_order_id,
first_value(o.order_date) over(partition by o.user_id order by order_date desc) latest_order_id
from users u 
left join orders o 
using(user_id);

/* Cross join lateral  */
select c.student_id, c.advisor, c.room, t.*
from class_unnormalized c
cross join lateral (
	values 
		(c.class1, 'class1'),
		(c.class2, 'class2'),
		(c.class3, 'class3')
	) as t --(subject,class_num)
order by student_id;

/*	recursive cte	*/
with recursive date_table as (

	--non recursive part
	select '2025-01-01'::date da_date
	union all 
	--recursive part
	select (da_date + interval '1 month')::date
	from date_table
	--end condition
	where da_date < '2025-12-01'::date )
	
select * 
from date_table;
	
	
/*	recursive cte	*/
drop table employees;

create table employees( 
	title varchar,
	employee_id integer,
	manager_id integer
);

insert into employees (title, employee_id, manager_id) values 
('The Boss', 1, null),
('Vice President Procurement', 10,1),
('Senior Manager Strategic Sourcing', 100,10),
('Vice President Engineering', 20, 1),
('Data Science Engineer', 200, 20),
('Software Engineer', 201, 20),
('QA Engineer', 202, 20);

select * from employees;

/*	recursive cte	*/
--with recursive employee as (
	select e.title, e.employee_id, e2.title manager 
	from employees e
	left join employees e2
	on e.manager_id = e2.employee_id;
	
with recursive managers as (
	select '' as hierarchy_lvl, employee_ID, manager_ID, title as employee_title
	from employees
	where title = 'The Boss'
	union all
	select hierarchy_lvl ||'-',
	e.employee_ID, e.manager_ID, e.title
	from employees e join managers m
	on e.manager_id = m.employee_id)
	
select * from managers;
;


/* Normalization	*/
create table class_unnormalized ( 
	student_id serial,
	advisor varchar,
	room varchar,
	class1 varchar,
	class2 varchar,
	class3 varchar
);

insert into class_unnormalized (advisor, room, class1, class2, class3 ) values
('Jones', 123, 'Biology','Chemistry','Physics'),
('Smith', 131, 'English','Math','Library Science');

select * from class_unnormalized cu ;

/* pivoting
create extension if not exists tablefunc;

select * from crosstab($$
	select student_id,
		class1,
		class2,
		class3
	from class_unnormalized
	order by 1;
$$) as ct(student_id int, class1 varchar); */

/* unpivot for First Normal Form */
select c.student_id, c.advisor, c.room, t.*
from class_unnormalized c
cross join lateral (
	values 
		(c.class1, 'class1'),
		(c.class2, 'class2'),
		(c.class3, 'class3')
	) as t (subject,class_num)
order by student_id;

create view fnf as 
(select c.student_id, c.advisor, c.room, t.*
from class_unnormalized c
cross join lateral (
	values 
		(c.class1, 'class1'),
		(c.class2, 'class2'),
		(c.class3, 'class3')
	) as t (subject,class_num)
order by student_id);


/* Second Normal Form */
-- Students
select distinct student_id, advisor, room
from fnf;

--registrations 
select distinct student_id, class_num
from fnf;

/* Third Normal Form */
select distinct student_id, advisor
from fnf;

--Faculty
select distinct advisor, room, '342' as dept
from fnf;

