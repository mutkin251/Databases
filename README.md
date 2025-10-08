# Databases
Homeworks and other staff 

So well, where do I start.

First things first I make 5 tables and fill them with some variables.The main idea 
is **someone is ordering something from somewhere** and in file insert_data.sql I specify what customers 
I have, where they live, etc. Some properties in create_tables.sql can be unlnown like foreign key, in short
it makes some kind of a link between tables so after the join nothing will collapse. 

```{sql}
WITH CustomerFullData AS (
  SELECT
    c.id AS customer_id,
    c.name,
    c.surname,
    con.email,
    con.phone_num,
    o.product_name,
    o.serial_num,
    s.country,
    s.city,
    p.distr_id,
    p.post_id
  FROM Customers c
  JOIN Contacts con ON con.customer_id = c.id
  JOIN order_id o ON o.customer_id = c.id
  JOIN ship_loc s ON s.customer_id = c.id
  JOIN post_loc p ON p.order_id = o.id
),

``` Here I initialise all of my variables to work with them later ,and then we calculate
from what countries we have the most orders. Then we show our table where we can see 4 candidates 
with a base filter (Here we select only those customers who live in countries where there
was at least one order.) After that we have a sort by last name (alphabetical order)
and display only the first 4 customers.

That`s it, thanks for the attention.