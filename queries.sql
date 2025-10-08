USE Homework;

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

OrderCountPerCountry AS (
  SELECT country, COUNT(*) AS total_orders
  FROM ship_loc
  GROUP BY country
)


SELECT 
  name,
  surname,
  email,
  phone_num,
  country,
  city,
  product_name,
  serial_num,
  post_id,
  distr_id
FROM CustomerFullData
WHERE country IN (
  SELECT country FROM OrderCountPerCountry WHERE total_orders >= 1
)
GROUP BY name, surname, email, phone_num, country, city, product_name, serial_num, post_id, distr_id
HAVING COUNT(product_name) >= 1
ORDER BY surname ASC
LIMIT 4;