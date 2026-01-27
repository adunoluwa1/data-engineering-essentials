drop table books;
create table books (
	bookid serial primary key,
	title varchar(100),
	genre varchar(50),
	price decimal(5,2)
);

create table authors (
	authorid serial primary key,
	name varchar(100),
	birthdate date
);
drop table customers;
create table customers(
	customerid serial primary key,
	name varchar(100),
	email varchar(100)
);

create table purchases(
	purchaseid serial primary key,
	bookid int not null references books(bookid),
	customerid int not null references customers(customerid),
	purchasedate date
);

create table books_authors(
	bookid int not null references books(bookid),
	authorid int not null references authors(authorid)
);

alter table authors 
rename column name to authorname;

insert into authors(authorname,birthdate) values
('J.K. Rowling', '1965-07-31'),
('George Orwell', '1903-06-25');

update authors 
set birthdate='1963-06-03'
where authorid = 2;


ALTER TABLE  products
RENAME TO raw_products;