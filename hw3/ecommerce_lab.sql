drop table if exists orders;
drop table if exists customers;

create table customers (
    customer_id integer primary key,
    customername text not null,
    country text not null
);

create table orders (
    order_id integer primary key,
    customer_id integer not null,
    orderdate text not null,
    totalamount real not null,
    foreign key (customer_id) references customers(customer_id)
);

insert into customers (customer_id, customername, country) values
    (1, 'Alice', 'USA'),
    (2, 'Bob', 'UK'),
    (3, 'Charlie', 'USA'),
    (4, 'Diana', 'Canada'),
    (5, 'Eve', 'Australia');

insert into orders (order_id, customer_id, orderdate, totalamount) values
    (101, 1, '2024-01-15', 120.50),
    (102, 1, '2024-02-10', 80.00),
    (103, 2, '2024-01-20', 200.00),
    (104, 3, '2024-03-12', 150.00),
    (105, 4, '2024-02-05', 60.00),
    (106, 5, '2024-03-30', 90.00);

select 
    customers.customername,
    customers.country,
    orders.totalamount, 
    case 
        when orders.totalamount > 150 then 'high'
        when orders.totalamount between 100 and 150 then 'medium'
        else 'low'
    end as order_category
from customers
join orders on customers.customer_id = orders.customer_id

;

select 
    customers.country,
    count(orders.order_id) as total_orders
    from customers
    join orders
        on customers.customer_id = orders.customer_id
group by customers.country
having count(orders.order_id) > 1;

select 
    customers.customername,
    orders.order_id, 
    orders.totalamount
from customers
left join orders on customers.customer_id = orders.customer_id;

select
    customers.customername,
    orders.totalamount
from customers
join orders on customers.customer_id = orders.customer_id
where orders.totalamount > (select avg(totalamount) from orders);


with customeraverages as (
    select
        orders.customer_id, 
        avg(totalamount) as customer_avg
        from orders
        group by orders.customer_id
),
countryaverages as (
    select
        customers.country, 
        avg(orders.totalamount) as country_avg
        from customers
        join orders on customers.customer_id = orders.customer_id
        group by customers.country
)
select 
    customers.customername, 
    customers.country,
    customeraverages.customer_avg,
    countryaverages.country_avg
from customers
join customeraverages on customers.customer_id = customeraverages.customer_id
join countryaverages on customers.country = countryaverages.country
where customeraverages.customer_avg > countryaverages.country_avg;