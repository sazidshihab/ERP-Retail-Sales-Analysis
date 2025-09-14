use erpboss;

SET SQL_SAFE_UPDATES = 0;

update stock_sale
set date1 = str_to_date(date1,'%Y-%m-%d');

alter table stock_sale
modify date1 date;


update dept_sale
set date1 = str_to_date(date1,'%d/%m/%Y');

alter table dept_sale
modify date1 date;

select * from dept_sale
where  date1 between '2006-12-03' and '2024-04-17';
select * from stock_sale
where  date1 between '2006-12-03' and '2024-04-17';





select * from stock_sale;
select * from stock;





select distinct department from stock;

create or replace view dept_stock as 
select distinct department from stock;

create or replace view stock_sale_for_dept as
select  distinct department from stock_sale left join stock on
stock_sale.stock_code = stock.id
where id is not null and date1 between '2006-12-03' and '2024-04-17';


select * from stock_sale_for_dept;
select * from dept_stock;




select  sum(line_total) from dept_sale left join stock_sale_for_dept on
dept_sale.dept_no = stock_sale_for_dept.department
where  date1 between '2006-12-03' and '2024-04-17';

select sum(line_total) from dept_sale
where date1 between '2006-12-03' and '2024-04-17';




select  sum(line_total) from stock_sale left join stock on
stock_sale.stock_code = stock.id
where  date1 between '2006-12-03' and '2024-04-17';

select sum(line_total) from stock_sale
where date1 between '2006-12-03' and '2024-04-17';


select * from supplier;
select * from stock;
select * from stock_sale;








