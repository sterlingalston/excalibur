/*import the books */
--need to alter pubdate to change back later
alter table books alter column pubdate type text;

--copy data from books csv
\COPY books(title, pages, isbn13, isbn10, pubdate, author, publisher, subjects) FROM './export_data_csvs/books.csv' DELIMITER ',' CSV HEADER;

--set blank dates to null (sorry the data in the csv was using a formula to cover to valid postgres date format and resulted in extra '--')
update books set pubdate = null where pubdate like '%--%';

--change pubdate back to date
alter table books alter column pubdate type date using to_date(pubdate,'yyyy-mm-dd');

--import the borrowers next
\COPY borrowers(first_name, last_name, dob, gender, phone, email, address, city, state, zip) FROM './export_data_csvs/borrowers.csv' DELIMITER ',' CSV HEADER;

--import authors
\COPY authors(author) FROM './export_data_csvs/authors.csv' DELIMITER ',' CSV HEADER;

--import subjects
\COPY subjects(subject) FROM './export_data_csvs/subjects.csv' DELIMITER ',' CSV HEADER;

--publishers
\COPY publishers(publisher) FROM './export_data_csvs/publishers.csv' DELIMITER ',' CSV HEADER;

--borrowing records
\COPY borrowed(borrower_id, book_id, book_dt, book_dt_due, book_return_dt) FROM './export_data_csvs/borrowing_records.csv' DELIMITER ',' CSV HEADER;

--delete borrow records where this is no data for the book/ for some reason book data was incomplete
delete from borrowed using  books where  borrowed.book_id = books.id and  books.publisher is null;

--created function to be used within the stored procedure
create or replace function func_most_borrowed_authors(year_brw int4)
returns table (author text, borrow_count int8)
as $$
begin
return query
select books.author, brw.borrow_count from (select br.book_id, count(br.*) as
borrow_count from borrowed br where date_part('year',book_dt) = year_brw group
by br.book_id order by borrow_count desc limit 5)
brw left join books on brw.book_id = books.id;
end;
$$ LANGUAGE 'plpgsql'
;

--create stored procedure to return 5 most borrowed authors in year
create procedure most_borrowed_authors(year_brw int4 DEFAULT 2020, INOUT _val text DEFAULT '')
LANGUAGE plpgsql AS
$proc$

DECLARE

thestr text;
rower record;

BEGIN

for rower in 
select author from func_most_borrowed_authors(year_brw)
loop
_val := _val || ',' || rower;
end loop;

return;
END
$proc$;

--create function for number of borrower materials by specified members based on month

create or replace function func_borrowed_materials(year_brw int4, month_brw int4)
returns table (last_name text, first_name text, borrow_count int8)
as $$
begin
return query
select borrowers.last_name, borrowers.first_name, count(b.*) from borrowed b 
inner join borrowers on b.borrower_id = borrowers.id where 
date_part('year',book_dt) = year_brw and date_part('month',book_dt) = month_brw group by borrowers.last_name, borrowers.first_name;
end;
$$ LANGUAGE 'plpgsql'
;

