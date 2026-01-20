use erpboss;


-----------------------------------------------------------------------------------------------------
SET SQL_SAFE_UPDATES = 0;
update stock_sale
set line_total = abs(line_total);


select * from stock_sale;
select * from stock_selling_group;
drop view stock_selling_group;


#Top selling analyze

create or replace view stock_selling_group as 
with cte1 as(
select date1,stock_code, line_total ,  quantity
, tax_amount
from stock_sale

), cte2 as(

select id, details, department, average_cost, price1, price2, discontinue from
stock
) select date1, stock_code, details, department, round(sum(average_cost)) as average_cost, round(sum(line_total)) as total_sale, round(sum(quantity)) as quantity,
round(sum(tax_amount)) as tax, discontinue
 from cte1 left join cte2 on
cte1.stock_code = cte2.id
group by 1,2,3,4,9;

select * from stock_selling_group;
drop view stock_selling_group;


---------------------------------------------------------------------------------------------------

#Cohort/Time_series analyze of sale by product
#Product wise yearly analyze(quantity)

with cte1 as(
select stock_code, date_format(date1, '%Y-%m-01') as mod_date,
min(date_format(date1,'%Y-%m-01')) over (partition by stock_code) as first_purchase
from stock_sale),
cte2 as (
select stock_code, first_purchase, Year(mod_date)-Year(first_purchase) as next_purchase
from cte1
)
select stock_code, 
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 0 then 1 else 0 end
) as '2006',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 1 then 1 else 0 end
) as '2007',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 2 then 1 else 0 end
) as '2008',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 3 then 1 else 0 end
) as '2009',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 4 then 1 else 0 end
) as '2010',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 5 then 1 else 0 end
) as '2011',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 6 then 1 else 0 end
) as '2012',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 7 then 1 else 0 end
) as '2013',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 8 then 1 else 0 end
) as '2014',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 9 then 1 else 0 end
) as '2015',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 10 then 1 else 0 end
) as '2016',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 11 then 1 else 0 end
) as '2017',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 12 then 1 else 0 end
) as '2018',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 13 then 1 else 0 end
) as '2019',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 14 then 1 else 0 end
) as '2020',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 15 then 1 else 0 end
) as '2021',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 16 then 1 else 0 end
) as '2022',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 17 then 1 else 0 end
) as '2023',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 18 then 1 else 0 end
) as '2024',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 19 then 1 else 0 end
) as '2025'

 from cte2
 group by 1;


##Product wise yearly analyze(Sale value)

with cte1 as(
select stock_code,line_total, date_format(date1, '%Y-%m-01') as mod_date,
min(date_format(date1,'%Y-%m-01')) over (partition by stock_code) as first_purchase
from stock_sale),
cte2 as (
select stock_code, line_total, first_purchase, Year(mod_date)-Year(first_purchase) as next_purchase
from cte1
)
select stock_code, 
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 0 then line_total else 0 end
) as '2006',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 1 then line_total else 0 end
) as '2007',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 2 then line_total else 0 end
) as '2008',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 3 then line_total else 0 end
) as '2009',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 4 then line_total else 0 end
) as '2010',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 5 then line_total else 0 end
) as '2011',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 6 then line_total else 0 end
) as '2012',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 7 then line_total else 0 end
) as '2013',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 8 then line_total else 0 end
) as '2014',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 9 then line_total else 0 end
) as '2015',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 10 then line_total else 0 end
) as '2016',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 11 then line_total else 0 end
) as '2017',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 12 then line_total else 0 end
) as '2018',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 13 then line_total else 0 end
) as '2019',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 14 then line_total else 0 end
) as '2020',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 15 then line_total else 0 end
) as '2021',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 16 then line_total else 0 end
) as '2022',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 17 then line_total else 0 end
) as '2023',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 18 then line_total else 0 end
) as '2024',
sum(
 case when Year(first_purchase) - Year('2006-12-01') +next_purchase = 19 then line_total else 0 end
) as '2025'

 from cte2
 group by 1;


select  stock_code,  Year(date1), sum(line_total) from stock_sale
group by 1,2 ;


select * from stock_sale;