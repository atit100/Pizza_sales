-- retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p USING (pizza_id);


-- Identify the TOP highest priced pizza
SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
ORDER BY price DESC
LIMIT 3;

-- identify the most common pizza size ordered

select size,count(order_details_id) as orders from pizzas
join order_details using(pizza_id)
group by 1
order by count(order_details_id) desc limit 1;

-- list the top 5 most ordered pizza types along with theie quantities.

SELECT 
    name, SUM(quantity)
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY name
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- find the total quantity of each pizza category
SELECT 
    pt.category, SUM(od.quantity) AS toal_quantity
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hour,
    COUNT(order_id) AS distribution_of_orders
FROM
    orders
GROUP BY HOUR(order_time);


-- find the category wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY 1;

-- group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    AVG(total_quantity)
FROM
    (SELECT 
        order_date, SUM(od.quantity) AS total_quantity
    FROM
        order_details od
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY order_date) AS order_quantity;

-- determine the top 3 most ordered pizza types based on revenue

SELECT 
    name, SUM(quantity * Price) AS total_rev
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY name
ORDER BY SUM(quantity * Price) DESC
LIMIT 3;

-- calculate the percentage contribution of each pizza type to total revenue

SELECT 
    name,
    SUM(price * quantity) AS total_rev,
    ROUND((SUM(price * quantity) * 100) / (SELECT 
                    ROUND(SUM(price * quantity), 2)
                FROM
                    order_details
                        JOIN
                    pizzas USING (pizza_id)),
            2) AS percent_growth
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY name;

-- percentage growth of each pizza category

SELECT 
    category,
    round(SUM(price * quantity),2) AS total_rev,
    ROUND((SUM(price * quantity) * 100) / (SELECT 
                    ROUND(SUM(price * quantity), 2)
                FROM
                    order_details
                        JOIN
                    pizzas USING (pizza_id)),
            2) AS percent_growth
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
    group by 1;


-- analyze the cumulative revenue generated over time.
with cte as
(select order_date,round(sum(price*quantity),2) as total_rev
from order_details 
join pizzas using(pizza_id)
join orders using(order_id)
group by 1)
select order_date,total_rev,round(sum(total_rev) over(order by total_rev),2)as cum_rev from cte
group by 1;


-- determine the top 3 most ordered pizza type based on revenue for each pizza category.

select category,name,total_sales,ranking from
(select category,name,total_sales,
rank() over(partition by category order by total_sales desc ) as ranking from
(
select category,name,round(sum(price*quantity),2) as total_sales
from order_details
join pizzas using(pizza_id)
join pizza_types using(pizza_type_id)
group by 1,2)as t) as t2
where ranking<=3;








