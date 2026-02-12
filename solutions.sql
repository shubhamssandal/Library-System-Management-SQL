-- Project Tasks
select * from books;
select * from members;
select * from issued_status;
--  Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Update an Existing Member's Address

update members
set member_address = '125 Main St'
where member_id = 'C101';
select * from members;

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where issued_id = 'IS121';
select * from issued_status;

-- Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id, count(*)
from issued_status
group by issued_emp_id
having count(*)>1;

-- CTAS
-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

create table book_cnts
as 
select 
	b.isbn,
    b.book_title,
    count(ist.issued_id) as no_issues
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1,2;

select * from book_cnts;

-- Retrieve All Books in a Specific Category

select * from books
where category = 'classic';

-- Find Total Rental Income by Category:

select 
b.category,
sum(b.rental_price),
count(*)
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1;

-- List Members Who Registered in the Last 180 Days:

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 DAY;

-- List Employees with Their Branch Manager's Name and their branch details:
select * from branch;
select * from employees;

select 
e1.*,
b.manager_id,
e2.emp_name as manager
from employees as e1
join branch as b
on b.branch_id = e1.branch_id
join employees as e2
on b.manager_id = e2.emp_id;

-- Create a Table of Books with Rental Price Above a Certain Threshold:

create table expensive_books as
select * from books
where rental_price > 7;

-- Retrieve the List of Books Not Yet Returned

select 
distinct ist.issued_book_name
from issued_status as ist
left join 
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null;

-- Identify Members with Overdue Books, Write a query to identify members who have overdue books 
-- (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

select 
	ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
   -- rs.return_date,
    current_date - ist.issued_date as over_due_days
    
from issued_status as ist
join 
members as m
on m.member_id = ist.issued_member_id
join books as bk
on bk.isbn = ist.issued_book_isbn
left join return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_date is null
and ( current_date - ist.issued_date) > 30;

-- Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned 
-- (based on entries in the return_status table).

DELIMITER $$

CREATE PROCEDURE add_return_records (
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(25);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Fetch ISBN and book name from issued_status
    SELECT
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- MySQL does not support RAISE NOTICE
    -- Use SELECT to return a message instead
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END$$

DELIMITER ;

/* Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

select * from branch;
select * from issued_status;
select * from employees;
select * from books;
select * from return_status;


create table branch_report
as
select 
	b.branch_id,
    b.manager_id,
    count(ist.issued_id) as no_of_book_issued,
    count(rs.return_id) no_of_book_returned,
    sum(bk.rental_price) as total_revenue
from issued_status as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join branch as b
on e.branch_id = e.branch_id
left join return_status as rs
on rs.issued_id = ist.issued_id
join books as bk
on ist.issued_book_isbn = bk.isbn
group by 1,2;

/*CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 24 months.
*/

create table active_member as
select * from members
		where member_id in (
					SELECT distinct(issued_member_id)
					FROM issued_status
					WHERE issued_date > CURDATE() - INTERVAL 24 MONTH
        );

/*Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2;












