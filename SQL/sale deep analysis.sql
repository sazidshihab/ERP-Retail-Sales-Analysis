use erpboss;
SELECT * FROM stock_selling_group
;


#making data for analyzing profit/loss table 
create or replace view stock_selling_group_ as 
select date_format(date1,'%Y-%m') as date1, stock_code, details, round(avg(average_cost),2) as average_cost, round(sum(total_sale),2) as total_sale , round(sum(quantity),2) as quantity, round(sum(tax),2) as tax, discontinue
from stock_selling_group
group by 1,2,3,8;
select * from stock_selling_group_;


create or replace view supplier_ as
with cte1 as(
select date_format(date1,'%Y-%m') as date_sup, stock_code, sum(quantity) as quantity, avg(unit_cost) as cost from supplier
where quantity not between  0 and 3
group by 1,2
), cte2 as(
select  date_sup,stock_code as stock_code_sup,quantity as quantity_sup, cost from cte1
) select * from cte2
;
select * from supplier_;



#creating pre profit/loss table 
create or replace view profit_loss_pre as
with main as (
select * from stock_selling_group_  left join supplier_
on stock_selling_group_.date1 = supplier_.date_sup and
stock_selling_group_.stock_code = supplier_.stock_code_sup
), __flag as (

select *, sum(cost is not null) over(partition by stock_code order by date1 ) as grp2 from main
), _flag as(

select date1, stock_code, details,average_cost, total_sale, quantity, tax,  cost, 
case when grp2=0 then 1 
  else grp2 end
as grp2 from __flag
)
, _final as (

select * , max(cost) over (partition by stock_code,  grp2 
    ) as cost2 from _flag
), final as (

select date1, stock_code, details,average_cost, total_sale, quantity, tax,  grp2, cost, (
case 
when average_cost is null then cost2
when cost2 is null then average_cost
when abs(total_sale/quantity - average_cost) < abs(total_sale/quantity - cost2) and total_sale/quantity > average_cost  and total_sale/quantity > cost2 then average_cost
when abs(total_sale/quantity - average_cost) > abs(total_sale/quantity - cost2) and total_sale/quantity > cost2 and total_sale/quantity > average_cost then cost2
when abs(total_sale/quantity - average_cost) < abs(total_sale/quantity - cost2) and total_sale/quantity < average_cost and total_sale/quantity < cost2 then average_cost
when abs(total_sale/quantity - average_cost) > abs(total_sale/quantity - cost2) and total_sale/quantity < average_cost and total_sale/quantity < cost2 then cost2
when average_cost > total_sale/quantity and cost2<total_sale/quantity then cost2
when average_cost < total_sale/quantity and cost2>total_sale/quantity then average_cost

end ) as f_cost from _final 

)
select * from final;
select * from profit_loss_pre;




#Creating final loss/profit table 
create or replace view profit_loss as
with cte1 as(
select  stock_code, details, 
round(sum(case when f_cost is not null then f_cost*quantity else average_cost*quantity end),2) as cost,
round(sum(total_sale),2) as sold from profit_loss_pre
group by 
1,2)
,
cte2 as(
select * ,
case when cost>sold then round(cost-sold, 2) else 0 end as gross_loss,
case when cost<sold then round(sold-cost,2) else 0 end as gross_profit
from cte1
) select * from cte2;


select sum(cost), sum(sold), sum(gross_loss), sum(gross_profit) from profit_loss;
/*
Total sold value = 8454831
Cost = 5464704.84
loss = 43240.37 (by products total, by 5+ products )
profit = 3029116.52 (by products total 85+ products)
Rest of the products are not contributing loss or profit.
*/


---------------------------------------------------------------------------------------------------------------------
#Top/Least performing products
select * from profit_loss
where gross_profit>5000 or gross_loss>500;


# products are effecting elements here, from them only 5 products are causing loss and rest of the  products are making money
/*
All was done using 'supplier', 'stock_sale' and 'stock' table by cross checking the cost data.
I use dynamic cost fixing system here as, there were,
       1. Not enough data on supplier table to accomodate all sale in stock_sale
       2. Most of the average_cost value in stock_table was incorrect
       3. So had to cross check between 'stock', 'stock_sale' and 'supplier' table 
       4. Use dynamic system to pick the minimum cost based on selling price!
       5. Almost all products are making money or stable number is sale, but data shows 5 products are not making money.



loss = '503', '22', '79','113' and '9421014520864' 
profit = ... top = '9421014525302', '9310797257220', '9421902692017','9414453905507','275','9421902692017','9421902692437','9414453904432','9421902692123','9421014525500','8725000639679','88'


*Analyzing the data it seems, most sold value resulting in more gross_profit. It's a good sign. If more selling caused loss then it 
might be concerning. But there are some products whose are bigger in terms of selling value, but less in gross_profit value.
*/
-------------------------------------------------------------------------------------------------------------------

#Time to analyze those selected products !!!

#Analyzing products those are causing loss:::

#no 1: stock_code = 503

select * from profit_loss_pre
where stock_code = '503';

select * from profit_loss
where stock_code = '503';

select year(date1), count(*) as encounter, sum(total_sale) as total_sale from stock_selling_group
where stock_code = '503'
group by 1
;

select * from stock_selling_group
where stock_code = '503';
/*
** We can say, only '503' had a loss sale analyzing the data. It had a short selling period of 2022->2023->2024. Cost was higher than selling rate.
** Sold = 2440 , Cost = 6138 

-----Conclusion: This product is not making money cause, it's selling price < product cost, this product is a continued product-----
*/

-------------------------------------------------------------------------------------------------------------------------------
#no 1: stock_code = 22

select * from profit_loss_pre
where stock_code = '22';

select * from profit_loss
where stock_code = '22';

select year(date1), count(*) as encounter, sum(total_sale) as total_sale from stock_selling_group
where stock_code = '22'
group by 1
;

select * from stock_selling_group
where stock_code = '22';

/*
Cost= 888 , sold = 145
** Same as here, causing loss as cost>selling price
** Selling timeline: 2013->2019->2018->2014

conclusion: Cost is higher than selling price. It is also a discontinued product.
*/

-----------------------------------------------------------------------------------------------------
# Stock_code = '79'

select * from profit_loss_pre
where stock_code = '79';

select * from profit_loss
where stock_code = '79';

select substring_index(date1, '-',1), count(*) as encounter, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '79'
group by 1
;

select * from stock_selling_group
where stock_code = '79';

/*
** Cost =  27626 , sold = 26902 , loss = 724 over year 2013 to 2019. 
** Selling timeline: 2018->2019->2016->2017->2015->2014->2013 
** 2013 year caused the actual loss. 
** After that graduallly profit increased. 
** This product is discontinued at 2019.

Colclusion: The year 2013 caused the loss. Selling price was lower than cost.
*/

-----------------------------------------------------------------------------------------------------------------
# Stock_code : '113'

select * from profit_loss_pre
where stock_code = '113';

select * from profit_loss
where stock_code = '113';

select substring_index(date1, '-',1), count(*) as encounter, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '113'
group by 1
;

select * from stock_selling_group
where stock_code = '113';

/*
** Cost = 694 , sold = 107, loss = 587
** Selling price was lower than cost
** 2013 year caused the actual loss
** Discontinued.

Conclusion: Some certain time selling price was lower than purchasing price, Discontinued.
*/

-------------------------------------------------------------------------------------------------------------
# Stock_code : '9421014520864'

select * from profit_loss_pre
where stock_code = '9421014520864';

select * from profit_loss
where stock_code = '9421014520864';

select substring_index(date1, '-',1), count(*) as encounter, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '9421014520864'
group by 1
;

select * from stock_selling_group
where stock_code = '9421014520864';

/*
** Cost = 3978.97 , sold = 3411, loss = 567.97
** 2013 and 2014 year was actual loss year
** Rest of the year revenue was positive
** Continued product

Conclusion: 2013 and 2014 caused losses, later years making revenue, though very low revenue margin.
*/

--------------------------------------------------------------------------------------------------------------------------

# Analyzing products those are making profit:::

# Stock_code: '9421014525302'

select * from profit_loss_pre
where stock_code = '9421014525302';

select * from profit_loss
where stock_code = '9421014525302';

select substring_index(date1, '-',1), sum(quantity) as quantity, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '9421014525302'
group by 1
order by 4 desc
;

select * from stock_selling_group
where stock_code = '9421014525302';

/*
** Cost = 1556905.52 , Sell = 2346550, profit= 789644.48 , selling_gross_profit_ratio = 33.6% [This product yield 33.6% revenue while sold at 100]

** Continued and most profit earning product
** Profit order: 2022->2021->2015->2023->2016->2019->2024->2020->2017->2018->2014->2013->2006->2007.
** Sale revenue flactuate over time, but clear pattern on covid pandemic time. low sale at 2020, but skyrocket at 2021 and 2022.
   gradually goes to median position.
** Price optimization (for maximum gross_profit) can be observed on 2021 and 2022 when demand was at it's peak.

Conclusion: This product is making the most gross_profit. But gross_profit is on negative trend from 2023->2024->2025!! 
          gross_profit share = 2496229.77 (total gross_profit)/ 789644.48 (this product gross_profit)
          = 31.6% 
*/

-------------------------------------------------------------------------------------------------------------
# Stock_code: '9310797257220'

select * from profit_loss_pre
where stock_code = '9310797257220';

select * from profit_loss
where stock_code = '9310797257220';

select substring_index(date1, '-',1), sum(quantity) as quantity, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '9310797257220'
group by 1
order by 4 desc
;

select * from stock_selling_group
where stock_code = '9310797257220';

/*
* Cost = 431863.84 , Sell = 545874 , Profit= 114010.16, selling_gross_profit_ratio = 21%
** This product contributed 2nd place at gross_profit generate
** But trend is falling since 2015, and gross_profit and quantity both dropping.
** No special flactuate, just falling by time! 

Conclusion : 2015 was most selling both in quantity and generate most revenue, but gradually falling over time. 
           gross_profit share = 2496229.77 (total_gross_profit)/ 114010.16 (this product gross_profit)
           = 4.5%
*/


----------------------------------------------------------------------------------------------------------------

#Stock_code: '9421902692017'

select * from profit_loss_pre
where stock_code = '9421902692017';

select * from profit_loss
where stock_code = '9421902692017';

select substring_index(date1, '-',1), sum(quantity) as quantity, sum(total_sale) as total_sale, sum(total_sale - f_cost*quantity) as gross_profit from profit_loss_pre
where stock_code = '9421902692017'
group by 1
order by 4 desc
;

select * from stock_selling_group
where stock_code = '9421902692017';

/*
** Cost= 443904.4 , sell= 555237 , profit= 111332.6 , selling_gross_profit_ratio= 20%
** 3rd most gross_profit contributed product, most contributed year was 2013
** After that gradually gross_profit and also selling quantity was dropping
** No special flactuate trend

Conclusion: Selling and gross_profit dropping by time,
          gross_profit share = 2496229.77 (total_gross_profit)/ 111332.6 (this product gross_profit)
          = 4.4%
*/

---------------------------------------------------------------------------------------------------------
#Creating table to get all info at once:cohort + rfm


with cte1 as (
select * from profit_loss_pre
) , cte2 as (select substring_index(date1,'-',1) as date1, stock_code, sum(quantity) as quantity, sum(total_sale) as revenue, sum(total_sale-quantity*f_cost) as gross_profit from cte1

group by 1,2),

cte3 as(
select  stock_code, 
max(date1) as recency,
count(distinct date1) as frequency,
sum(round(gross_profit)) as total_gross_profit,


concat(
case when max(date1) in ('2025' ,'2024') then 5
	 when max(date1) in ('2023' ,'2022','2021') then 4
     when max(date1) in ('2020' ,'2019','2018','2017')then 3
     when max(date1) in ('2016' ,'2015','2014','2013') then 2
     end ,
 case when count(distinct date1)>=13 then 5
      when count(distinct date1)>=10 and count(distinct date1)<13 then 4
      when count(distinct date1)>=8 and count(distinct date1)<10 then 3
      when count(distinct date1)<8 and count(distinct date1)>=5 then 2
      else 1 end ,
case when sum(gross_profit) >=95000 then 5
     when sum(gross_profit) < 95000 and sum(gross_profit) >= 50000 then 4
     when sum(gross_profit)< 50000 and sum(gross_profit)>= 20000 then 3
     when sum(gross_profit)<20000 and sum(gross_profit)>=1000 then 2
     when sum(gross_profit)<1000 and sum(gross_profit)>0 then 1
     else 0 end

) as rfm_score
,
sum(quantity) as total_quantity,
round(sum(revenue),2) as total_revenue,
round(sum(gross_profit)/sum(quantity),2) as gross_profit_per_product,
concat(round(sum(gross_profit)/sum(revenue)*100 ,2),'%') as gross_profit_margin,


sum(case when date1 = '2006' then quantity else 0 end) as 'quantity->1',
sum(case when date1 = '2006' then round(gross_profit) else 0 end) as '2006-profit',

sum(case when date1 = '2007' then quantity else 0 end) as 'quantity->2',
sum(case when date1 = '2007' then round(gross_profit) else 0 end) as '2007-profit',

sum(case when date1 = '2013' then quantity else 0 end) as 'quantity->3',
sum(case when date1 = '2013' then round(gross_profit) else 0 end) as '2013-profit',

sum(case when date1 = '2014' then quantity else 0 end) as 'quantity->4',
sum(case when date1 = '2014' then round(gross_profit) else 0 end) as '2014-profit',

sum(case when date1 = '2015' then quantity else 0 end) as 'quantity->5',
sum(case when date1 = '2015' then round(gross_profit) else 0 end) as '2015-profit',

sum(case when date1 = '2016' then quantity else 0 end) as 'quantity->6',
sum(case when date1 = '2016' then round(gross_profit) else 0 end) as '2016-profit',

sum(case when date1 = '2017' then quantity else 0 end) as 'quantity->7',
sum(case when date1 = '2017' then round(gross_profit) else 0 end) as '2017-profit', 

sum(case when date1 = '2018' then quantity else 0 end) as 'quantity->8',
sum(case when date1 = '2018' then round(gross_profit) else 0 end) as '2018-profit', 

sum(case when date1 = '2019' then quantity else 0 end) as 'quantity->9',
sum(case when date1 = '2019' then round(gross_profit) else 0 end) as '2019-profit', 

sum(case when date1 = '2020' then quantity else 0 end) as 'quantity->10',
sum(case when date1 = '2020' then round(gross_profit) else 0 end) as '2020-profit', 

sum(case when date1 = '2021' then quantity else 0 end) as 'quantity->11',
sum(case when date1 = '2021' then round(gross_profit) else 0 end) as '2021-profit', 

sum(case when date1 = '2022' then quantity else 0 end) as 'quantity->12',
sum(case when date1 = '2022' then round(gross_profit) else 0 end) as '2022-profit', 

sum(case when date1 = '2023' then quantity else 0 end) as 'quantity->13',
sum(case when date1 = '2023' then round(gross_profit) else 0 end) as '2023-profit',

sum(case when date1 = '2024' then quantity else 0 end) as 'quantity->14',
sum(case when date1 = '2024' then round(gross_profit) else 0 end) as '2024-profit', 

sum(case when date1 = '2025' then quantity else 0 end) as 'quantity->15',
sum(case when date1 = '2025' then round(gross_profit) else 0 end) as '2025-profit'

from cte2
group by 1) , 

cte4 as(
select stock_code, recency, frequency, total_gross_profit, rfm_score, total_quantity,total_revenue, gross_profit_per_product,gross_profit_margin,
`quantity->1`,`2006-profit`, concat(round((`2006-profit`-`2006-profit`)/`2006-profit`*100,2),'%') as '2006-YoY', 
`quantity->2`,`2007-profit`, concat(round((`2007-profit` - `2006-profit`)/`2006-profit`*100,2),'%') as '2007-YoY', 
`quantity->3`,`2013-profit`,concat(round((`2013-profit`-`2007-profit`)/`2007-profit`*100,2),'%') as '2013-YoY',
 `quantity->4`,`2014-profit`, concat(round((`2014-profit`-`2013-profit`)/`2013-profit`*100 ,2),'%') as '2014-YoY',
 `quantity->5`,`2015-profit`, concat(round((`2015-profit`-`2014-profit`)/`2014-profit`*100,2),'%') as '2015-YoY',
 `quantity->6`,`2016-profit`, concat(round((`2016-profit`-`2015-profit`)/`2015-profit`*100,2),'%') as '2016-YoY',
`quantity->7`,`2017-profit`, concat(round((`2017-profit`-`2016-profit`)/`2016-profit`*100,2),'%') as '2017-YoY',
`quantity->8`,`2018-profit`, concat(round((`2018-profit`-`2017-profit`)/`2017-profit`*100,2),'%') as '2018-YoY',
`quantity->9`,`2019-profit`,concat(round((`2019-profit`-`2018-profit`)/`2018-profit`*100,2),'%') as '2019-YoY' ,
`quantity->10`,`2020-profit`, concat(round((`2020-profit`-`2019-profit`)/`2019-profit`*100,2),'%') as '2020-YoY',
`quantity->11`,`2021-profit`, concat(round((`2021-profit`-`2020-profit`)/`2020-profit`*100,2),'%') as '2021-YoY',
`quantity->12`,`2022-profit`,concat(round((`2022-profit`-`2021-profit`)/`2021-profit`*100,2),'%') as '2022-YoY', 
`quantity->13`,`2023-profit`,concat(round((`2023-profit`-`2022-profit`)/`2022-profit`*100,2),'%') as '2023-YoY', 
`quantity->14`,`2024-profit`, concat(round((`2024-profit`-`2023-profit`)/`2023-profit`*100,2),'%') as '2024-YoY',
`quantity->15`,`2025-profit`,concat(round((`2025-profit`-`2024-profit`)/`2024-profit`*100,2),'%') as '2025-YoY'
 from cte3




where total_gross_profit < -100 or total_gross_profit>3000 )
,
 cte5 as (
select round(sum(gross_profit)) as grand_gross_profit from cte2),
cte6 as(
select cte4.*, 
case when total_gross_profit/grand_gross_profit*100 >0 then round(total_gross_profit/grand_gross_profit*100, 2) else 0 end as gross_profit_percentage,
sum(total_gross_profit) over (order by total_gross_profit desc) as cumulative_profit, concat(round(sum(total_gross_profit) over (order by total_gross_profit desc)/grand_gross_profit*100,2),'%') as cumulative_profit_percentage

 from cte4 join cte5),
 cte7 as (
 select * , 
 rank() over(order by rfm_score desc) as rfm_score_score,
 rank() over(order by total_revenue desc) as revenue_score, 
 rank() over(order by total_quantity desc) as quantity_score,
 rank () over(order by gross_profit_per_product desc)as gross_profit_per_product_score,
 rank () over(order by gross_profit_percentage desc)  as gross_profit_percentage_score
 from cte6
 
 
 ), cte8 as (
 select * , (rfm_score_score+revenue_score + gross_profit_per_product_score+gross_profit_percentage_score+quantity_score) as final_score from cte7
 order by final_score 
 )
 select * from cte8
;


/*
** This table will show each products sale by year and their sale quantity. Analyzing this table we can decide which product 
   is doing good over time and their trend!! 
*/

