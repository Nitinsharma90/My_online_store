-- PROJECT : E COMMERCE SALES AND CUSTOMER DATA ANALYSIS
create database if not exists my_online_store ;
use my_online_store ;
create table customer_detail(
customer_id int auto_increment primary key,
customer_name varchar(300) not null,
phone_no varchar(100) , 
email varchar(300) not null unique,
city varchar(200)
);
create table product_info(
product_id int auto_increment primary key , 
product_name varchar(100) not null ,
category enum ("Electronics","Furniture","clothing & Fashion") default "Electronics",
customer_id int , 
price decimal(10,2) not null, 
stock_quantity int default 0
);
create table orders (
order_id int auto_increment primary key ,  
order_date date not null , 
quantity int not null default 1, 
customer_id int , 
product_id int , 
foreign key (customer_id ) references customer_detail(customer_id),
foreign key (product_id ) references product_info (product_id)
);
INSERT INTO customer_detail (customer_name, phone_no, email, city) VALUES
('Rahul Sharma', '9876543210', 'rahul.sharma@gmail.com', 'Delhi'),
('Priya Patel', '9823456789', 'priya.patel@yahoo.com', 'Mumbai'),
('Amit Kumar', '9712345678', 'amit.k@outlook.com', 'Bangalore'),
('Sneha Singh', '9654321876', 'sneha.singh@gmail.com', 'Delhi'),
('Vikas Verma', '9543216789', 'vikas.v@gmail.com', 'Pune');
INSERT INTO product_info (product_name, category, price, stock_quantity) VALUES
('Laptop HP 15', 'Electronics', 45000.00, 15),
('Wireless Mouse', 'Electronics', 699.00, 50),
('Office Chair', 'Furniture', 4999.00, 20),
('Study Table', 'Furniture', 3500.00, 10),
('Cotton T-Shirt', 'Clothing & Fashion', 499.00, 100),
('Denim Jacket', 'Clothing & Fashion', 1999.00, 30);
INSERT INTO orders (order_date, quantity, customer_id, product_id) VALUES
('2024-01-10', 1, 1, 1),   
('2024-01-12', 2, 1, 2),   
('2024-01-15', 1, 2, 3),   
('2024-01-18', 3, 3, 5),   
('2024-02-01', 1, 4, 4),  
('2024-02-05', 1, 5, 6),   
('2024-02-10', 1, 2, 1),   
('2024-02-15', 2, 3, 2);


select * from customer_detail ;
select * from product_info ;
select * from orders;
-- : "Aapki dukaan ne ab tak kul kitne rupaye kamaye?" (Total Revenue)
select count(o.order_id) as total_orders_placed ,
sum(o.quantity) as total_item_sale ,
sum(o.quantity * p.price) as total_revenue 

from orders o
join product_info p on o.product_id = p.product_id;
-- : Har Customer ka Poora Bill (Invoice View)
select 
		c.customer_id , 
        c.customer_name ,
        c.city ,
        o.order_id , 
        o.order_date,
        o.quantity , 
        p.product_name , 
        p.category ,
        (o.quantity*p.price) as Total_sales 
        from orders o
        join customer_detail c on  c.customer_id = o.customer_id 
        join product_info p on p.product_id = o.product_id ;
	
-- Q1. Delhi ke Customers
-- Business Requirement: Marketing team ko Delhi ke sabhi customers ke naam, phone number, aur email ID chahiye.
select customer_name ,city, phone_no , email from customer_detail 
where city = "Delhi";
-- Q2. Stock Quantity Check
-- Business Requirement: Inventory manager ko wo products dekhne hain jinka stock 20 se kam bacha hai, taaki naya stock order kiya ja sake.
select product_id , product_name , stock_quantity from product_info
where stock_quantity < 20 ;
-- Q3. Highest Price Product
-- Business Requirement: Sabse mehnga product kaun sa hai aur uski price kya hai?
select product_name , category , price from product_info 
order by price desc 
limit 1 ;
-- Q4. Category-wise Total Revenue
-- Business Requirement: Management ko dekhna hai ki "Electronics", "Furniture", aur "Clothing & Fashion" mein se sabse zyada kamai kis category ne karke di hai.
select 
	  p.category  as CATEGORY, sum(o.quantity * p.price ) as Total_Revenue from orders o 
     join product_info p on p.product_id = o.product_id 
     group by CATEGORY
     order by Total_Revenue desc
     limit 2 ;
-- Q5. Customer Sales Summary (CLV - Customer Lifetime Value)
-- Business Requirement: Har customer ka naam, unki city, aur unhone ab tak kul kitne rupaye ka saaman khareeda hai (total_spent) dikhao.
select 
c.customer_id ,c.customer_name as Name , c.city AS CITY ,sum(o.quantity * p.price ) as Total_spend from orders o 
join customer_detail c on c.customer_id = o.customer_id 
join product_info p  on p.product_id = o.product_id 
group by 
c.customer_id ,c.customer_name , c.city 
order by Total_spend desc;
-- Q6. Month-wise Sales Performance
-- Business Requirement: January 2024 aur February 2024 mein se kis mahine mein zyada sales hui?
select 
date_format(o.order_date , '%M %Y') as ORDER_MONTH,
count(o.order_id) as Total_orders ,
sum(o.quantity * p.price) as Total_sales from orders o join product_info p on p.product_id = o.product_id 
where o.order_date between '2024-01-01' and  '2024-02-29'
group by date_format(o.order_date , '%M %Y') 
order by Total_sales desc;
-- Q7. City-wise Revenue Ranking
-- Business Requirement: Har shehar (City) se kitni total kamai hui hai, aur sabse zyada kamai dene wale shehar ko sabse upar dikhao.
select 
c.city ,
sum(o.quantity * p.price ) as Total_income 
from orders o 
join customer_detail c on c.customer_id = o.customer_id 
join product_info p on p.product_id = o.product_id 
group by 
c.city
order by Total_income desc;
-- Q8. Repeat Customers (Loyal Customers)
-- Business Requirement: Un customers ke naam aur unke total order count dikhao jinhone 1 se zyada baar (more than 1 order) purchase kiya hai.
select 
c.customer_name , 
count(o.order_id) as Total_count from orders o 
join customer_detail c on c.customer_id = o.customer_id
group by 
 c.customer_id,c.customer_name
having count(o.order_id )>1
order by Total_count desc;
-- Unsold Products (In-Active Inventory)
-- Business Requirement: Kya koi aisa product hai jo ab tak ek baar bhi nahi bika (orders table mein uski entry nahi hai)?
select 
p.product_id , 
p.product_name 
from product_info p
left join orders o on o.product_id = p.product_id
where o.product_id is null ; 
use my_online_store ;
create view vw_sales_dashboards as 
select 
o.order_id ,
o.order_date ,
c.customer_name ,
c.city, 
p.product_name ,
o.quantity,
p.price as unit_price ,
(o.quantity * p.price ) as Total_bill
from orders o
join customer_detail c on c.customer_id = o.customer_id 
join product_info p  on p.product_id = o.product_id ;
select * from vw_sales_dashboards ;

DELIMITER //
CREATE PROCEDURE CUSTOMER_DATA (IN INPUT_CUSTOMER_ID INT )
BEGIN
	SELECT 
		c.customer_id,
        c.customer_name,
        c.city,
        o.order_id,
        o.order_date,
        p.product_name,
        o.quantity,
        p.price AS unit_price,
        (o.quantity * p.price) AS total_bill
        FROM orders o 
        join customer_detail c on c.customer_id = o.customer_id 
        join product_info p on p.product_id = o.product_id 
        where c.customer_id = input_customer_id;
	end //
    
    DELIMITER ;
    CALL CUSTOMER_DATA(1);
        
