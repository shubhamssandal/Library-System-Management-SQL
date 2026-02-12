-- Library Management System Project 2

USE library_project_p2;

-- creating Branch table
create table branch
		(
			branch_id varchar(10) primary key, 
			manager_id varchar(10),
			branch_address varchar(10),
			contact_no varchar(10)
		);
        
ALTER TABLE branch
MODIFY branch_address VARCHAR(40);
ALTER TABLE branch
MODIFY contact_no VARCHAR(40);

        
create table employees
		(
			emp_id varchar(10) primary key,
			emp_name varchar(25),
			position varchar(25),
			salary	float,
			branch_id varchar(20)
		);

create table books
		(
			isbn varchar(25) primary key,
            book_title varchar(80),
            category varchar(25),
            rental_price float,
            status varchar(25),
            author	varchar(35),
            publisher varchar(55)
		);

create table members
		(
			member_id varchar(10) primary key,
            member_name varchar(25),
            member_address varchar(85),
            reg_date date
        );

create table issued_status
		(
        issued_id varchar(10) primary key,
        issued_member_id varchar(10),
        issued_book_name varchar(80),
        issued_date	date,
        issued_book_isbn varchar(25),
        issued_emp_id varchar(10)
        );

create table return_status
		(
        return_id varchar(10) primary key,
        issued_id varchar(10),
        return_book_name varchar(80),
        return_date	date,
        return_book_isbn varchar(20)
        );
	
-- Foreign Key

alter table issued_status
add constraint fk_members
foreign key(issued_member_id)
references members(member_id);  

-- SHOW TABLES;
-- DESCRIBE issued_status;
-- DESCRIBE member;
-- SHOW TABLE STATUS WHERE Name IN ('issued_status','member');

alter table issued_status
add constraint fk_books
foreign key(issued_book_isbn)
references books(isbn); 

alter table issued_status
add constraint fk_employees
foreign key(issued_emp_id)
references employees(emp_id); 

alter table employees
add constraint fk_branch
foreign key(branch_id)
references branch(branch_id); 

alter table return_status
add constraint fk_issued_status
foreign key(issued_id)
references issued_status(issued_id); 





								  