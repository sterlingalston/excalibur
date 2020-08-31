/*creating database and connecting */

CREATE DATABASE dbPLCS;

\c dbPLCS

/* building PLCS tables */

create table borrowed (id BIGSERIAL NOT NULL PRIMARY KEY, borrower_id int8 NOT NULL, book_id int8 , book_dt date , book_dt_due date , book_return_dt date);
create table borrowers (id BIGSERIAL NOT NULL PRIMARY KEY, first_name text , last_name text , dob DATE , gender VARCHAR(1) , phone decimal check (phone > -1), email text , address text , city text , state VARCHAR(2) , zip decimal check (zip > 0 and zip < 100000));
create table books (id BIGSERIAL NOT NULL PRIMARY KEY, title text , pages decimal , isbn13 text , isbn10 text , pubdate date , author text , publisher text, subjects text , author_id  int8, subject_id  int8, publisher_id  int8);
create table authors (id BIGSERIAL NOT NULL PRIMARY KEY, author text );
create table publishers (id BIGSERIAL NOT NULL PRIMARY KEY, publisher text );
create table subjects (id BIGSERIAL NOT NULL PRIMARY KEY, subject text );

/* altering tables to add fk constraints */

alter table borrowed add constraint constr_borrower_id foreign key (borrower_id) references borrowers (id);
alter table borrowed add constraint constr_book_id foreign key (book_id) references books (id);

alter table books add constraint constr_author_id foreign key (author_id) references authors (id);
alter table books add constraint constr_publisher_id foreign key (publisher_id) references publishers (id);
alter table books add constraint constr_subject_id foreign key (subject_id) references subjects (id);

