DROP DATABASE IF EXISTS Homework;
CREATE DATABASE Homework;
USE Homework;

CREATE TABLE customers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  surname varchar(30) NOT NULL
);

create table contacts(
	id int primary key auto_increment,
	customer_id INT,
    email varchar(50) unique,
    phone_num int UNSIGNED NULL unique,
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);

create table order_id(
	id int primary key auto_increment,
    customer_id INT,
    product_name varchar(60),
    serial_num int UNSIGNED NULL unique,
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);

create table ship_loc(
	id int primary key auto_increment,
    customer_id INT,
    country varchar(40),
	country_ch CHAR(2) NULL,
    city varchar(30),
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);

create table post_loc(
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  distr_id INT,
  post_id BIGINT,
  FOREIGN KEY (order_id) REFERENCES order_id(id)
);

