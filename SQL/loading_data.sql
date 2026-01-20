create database erpboss;
use erpboss;

create table stock(
id int primary key,
details text, 
department int,
standart_cost float,
last_cost float,
average_cost float,
price1 float,
price2 float,
supplier int,
discontinue text
);


create table stock_sale(
date1 text,
pos int,
stock_code bigint,
price_level int,
quantity int,
unit_price float,
line_total float,
tax_lable text,
tax_amount float
);

create table supplier(
name1 text,
date1 text,
invoice bigint,
stock_code bigint,
quantity int,
unit_cost float,
discount float,
line_total float,
tax_lable text,
tax_amount float
);

drop table supplier;

create table dept_sale(
date1 text,
pos int,
dept_no int,
quantity int,
unit_price float,
line_total int,
tax_lable text,
tax_amount float
);




load data LOCAL infile '/Users/sazid/Documents/ERPBoss/ERPboss/ERPBoss_Analysis/Data from ERP server/stksal.csv'
into table stock_sale
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;






select * from stock_sale;
select * from stock;
select * from supplier;
select * from dept_sale;


update stock_sale
set date1=str_to_date(date1,'%Y-%m-%d');

alter table stock_sale
modify date1 date;


update dept_sale
set date1=str_to_date(date1,'%Y-%m-%d');

alter table dept_sale
modify date1 date;


update supplier
set date1=str_to_date(date1,'%d/%m/%Y');

alter table supplier
modify date1 date;

