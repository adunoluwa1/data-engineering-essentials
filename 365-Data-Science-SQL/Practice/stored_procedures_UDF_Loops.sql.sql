/* Stored Procedure */
drop table if exists employees;
create table employees(
	id serial primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	department_id int not null,
	salary numeric(10,2) not null);

insert into employees (first_name, last_name, department_id, salary) values
('Alice','Smith',1, 50000),
('Bob','Johnson',2, 60000),
('Charlie','Brown',1, 55000);


create or replace procedure insert_employee(
	p_firstname varchar,
	p_lastname varchar,
	p_department_id integer,
	p_salary numeric ) 
language plpgsql
as $$
begin
	insert into employees (first_name, last_name, department_id, salary) values
	(p_firstname, p_lastname, p_department_id, p_salary); 
end;
$$;

select * from employees;

call insert_employee('David','Martinez',3,155000);

/* 	User defined function	*/
create or replace function average_salary(p_department_id integer)
returns numeric
language plpgsql
as $$
	declare v_avg_salary numeric;
	begin
		select avg(salary) into v_avg_salary
		from employees
		where department_id = p_department_id;
		return v_avg_salary;
	end;
$$;


select average_salary(1);  

create or replace function get_date()
returns date 
language plpgsql
as $$
declare date_value date;
begin
	select current_date into date_value;
	return date_value;
end;
$$;

/* transactions */
create table accounts(
	account_id serial primary key,
	balance decimal(10,2),
	account_name varchar(50),
	opened_on date default get_date() check (opened_on <= current_date)
);

insert into accounts (balance, account_name, opened_on) values
(1000.00, 'Savings Account','2021-01-01'),
(5000.00, 'Checkings Account','2022-06-15'),
(750.50, 'Investment Account','2023-02-28'),
(250.75, 'Credit Card Account','2020-12-01');

select * from accounts;

/*	using stored procedures for deposit	*/
create or replace procedure update_balance_deposit(p_account_id integer, amount numeric)
language plpgsql
as $$
begin
	update accounts set balance = balance + amount
	where account_id = p_account_id;
end;
$$;

/*	using stored procedures for withdrawal	*/
create or replace procedure update_balance_withdrawal(p_account_id integer, amount numeric)
language plpgsql
as $$
begin
	update accounts set balance = balance - amount
	where account_id = p_account_id;
end;
$$;

/* Calling stored procedures	*/
call update_balance_deposit(2,100);
call update_balance_withdrawal(1,100);

--Verifying
select * from accounts;



/* Transactions*/
begin transaction;

select * from accounts;
call update_balance_deposit(2,100);
call update_balance_withdrawal(1,100);
rollback;
commit;

end transaction;


-- Insert a new customer
begin transaction;

insert into accounts(account_name) values
('CDO');
-- end transaction;
-- create a savepoint
savepoint sp1;
-- insert a new customer
insert into accounts(account_name, opened_on) values
('CD', '2023-02-01');

select * from accounts;
-- if theres an issue roll back to sp1
rollback to sp1;

select * from accounts;
-- commit changes
commit;


/*	while loop	*/
do $$
declare acc_sum numeric := 0;
row record;
begin
	for row in 
	select * from accounts
	loop acc_sum := acc_sum + row.balance;
	raise notice 'sum of balance in row %',row.account_id ;
	raise notice 'is %', acc_sum;
end loop;
end;
$$;
