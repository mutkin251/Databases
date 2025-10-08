USE Homework;

INSERT INTO customers (name, surname)
VALUES
  ('alice', 'swans'),
  ('bob',   'ross'),
  ('charlie',  'chaplin'),
  ('diana', 'blased'),
  ('edward', 'norton');
ALTER TABLE customers AUTO_INCREMENT = 6;
INSERT INTO customers (name, surname)
VALUES
	('tyler','durden');
Select * FROM customers;
  
INSERT INTO contacts (customer_id,email, phone_num)
VALUES
  (1,'aswans@example.com',   0980235802),
  (2,'bross@example.com',    0987324190),
  (3,'cchaplin@example.com', 0678142901),
  (4,'dblased@example.com',  0980432890),
  (5,'enorton@example.com',  0348672347),
  (6,'tdurden@example.com',  0234769221);
ALTER TABLE contacts AUTO_INCREMENT = 7;  
  
INSERT INTO order_id (customer_id,product_name, serial_num)
VALUES
  (1,'cereal', 123456789),
  (2,'canvas',  987654321),
  (3,'headphones',  975318642),
  (4,'bed', 135792468),
  (5,'sunglasses', 864297531),
  (6,'mayhem', 246813579);
ALTER TABLE order_id AUTO_INCREMENT = 7;  
  
  
INSERT INTO ship_loc (customer_id,country,country_ch, city)
VALUES
  (1,'USA','US', 'Quebec'),
  (2,'France','FR', 'Paris'),
  (3,'Germany','DE', 'Frankfurt'),
  (4,'Slovenia','SI', 'Kranj'),
  (5,'Ukrainian','UA', 'Poltava'),
  (6,'Russian','RU', 'Siberia');
ALTER TABLE ship_loc AUTO_INCREMENT = 7;  
  
INSERT INTO post_loc(order_id,distr_id , post_id)
VALUES
  (1,02151, 13),
  (2,89012, 14),
  (3,54745, 15),
  (4,47373, 166),
  (5,76963, 17),
  (6,47768, 18);
ALTER TABLE post_loc AUTO_INCREMENT = 7;  
