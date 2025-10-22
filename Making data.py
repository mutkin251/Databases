import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
Faker.seed(42)
np.random.seed(42)
random.seed(42)

# Increase data volumes to meet requirements
NUM_PERSONS = 1_000_000
NUM_PRODUCTS = 1_000_000
NUM_ORDERS = 1_000_000

# Countries and cities
countries_cities = {
    'USA': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa'],
    'UK': ['London', 'Manchester', 'Birmingham', 'Leeds', 'Glasgow'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
    'Germany': ['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt']
}

product_categories = ['Electronics', 'Home & Garden', 'Fashion', 'Sports', 'Books', 
                     'Toys', 'Food', 'Health', 'Automotive', 'Office']

product_names = ['Laptop', 'Mattress', 'Ring', 'Smartphone', 'Headphones', 'Backpack',
                 'Camera', 'Coffee Machine', 'Watch', 'Desk Lamp', 'Tablet', 'Speaker',
                 'Monitor', 'Keyboard', 'Mouse', 'Charger', 'Cable', 'Case', 'Stand', 'Adapter']

print("Generating Persons table...")
# Generate Persons with unique PersonID
person_ids = np.arange(1, NUM_PERSONS + 1)
names = []
surnames = []
emails = []
countries = []
cities = []
registration_dates = []

start_date = datetime(2020, 1, 1)
end_date = datetime(2025, 10, 22)
date_range_sec = (end_date - start_date).total_seconds()

for i in range(NUM_PERSONS):
    if i % 100000 == 0:
        print(f"  Generated {i:,} persons...")
    
    # Add some duplicate "John Smith" for realistic scenario
    if random.random() < 0.001:  # ~1000 John Smiths
        names.append("John")
        surnames.append("Smith")
        country = "USA"
        city = random.choice(countries_cities["USA"])
    else:
        names.append(fake.first_name())
        surnames.append(fake.last_name())
        country = random.choice(list(countries_cities.keys()))
        city = random.choice(countries_cities[country])
    
    emails.append(fake.email())
    countries.append(country)
    cities.append(city)
    registration_dates.append(start_date + timedelta(seconds=random.randint(0, int(date_range_sec))))

df_persons = pd.DataFrame({
    'PersonID': person_ids,
    'Name': names,
    'Surname': surnames,
    'Email': emails,
    'Country': countries,
    'City': cities,
    'RegistrationDate': registration_dates
})

print("Saving Persons.csv...")
df_persons.to_csv(r'D:\\SQL_WORKS\\Homework2\\Persons.csv', index=False)
print(f"✓ Persons.csv created: {len(df_persons):,} rows\n")

print("Generating Products table...")
# Generate Products with unique ProductID
product_ids = np.arange(1, NUM_PRODUCTS + 1)
products = []
categories = []
prices = []
stock_quantities = []
product_dates = []

for i in range(NUM_PRODUCTS):
    if i % 100000 == 0:
        print(f"  Generated {i:,} products...")
    
    products.append(f"{random.choice(product_names)} {fake.word().title()}")
    categories.append(random.choice(product_categories))
    prices.append(round(random.uniform(5, 2000), 2))
    stock_quantities.append(random.randint(0, 500))
    product_dates.append(start_date + timedelta(seconds=random.randint(0, int(date_range_sec))))

df_products = pd.DataFrame({
    'ProductID': product_ids,
    'ProductName': products,
    'Category': categories,
    'BasePrice': prices,
    'StockQuantity': stock_quantities,
    'AddedDate': product_dates
})

print("Saving Products.csv...")
df_products.to_csv(r'D:\\SQL_WORKS\\Homework2\\Products.csv', index=False)
print(f"✓ Products.csv created: {len(df_products):,} rows\n")

print("Generating Orders table...")
# Generate Orders with proper foreign keys
order_ids = np.arange(1, NUM_ORDERS + 1)
order_person_ids = np.random.choice(person_ids, size=NUM_ORDERS)
order_product_ids = np.random.choice(product_ids, size=NUM_ORDERS)

# Price can vary slightly from base price (discounts/surcharges)
order_prices = []
order_quantities = []
order_statuses = []
order_dates = []

statuses = ['Pending', 'Shipped', 'Delivered', 'Cancelled', 'Returned']
status_weights = [0.1, 0.2, 0.6, 0.05, 0.05]

for i in range(NUM_ORDERS):
    if i % 100000 == 0:
        print(f"  Generated {i:,} orders...")
    
    base_price = df_products.loc[df_products['ProductID'] == order_product_ids[i], 'BasePrice'].values[0]
    discount = random.uniform(0.8, 1.2)  # ±20% variation
    order_prices.append(round(base_price * discount, 2))
    
    order_quantities.append(random.randint(1, 5))
    order_statuses.append(random.choices(statuses, weights=status_weights)[0])
    order_dates.append(start_date + timedelta(seconds=random.randint(0, int(date_range_sec))))

df_orders = pd.DataFrame({
    'OrderID': order_ids,
    'PersonID': order_person_ids,
    'ProductID': order_product_ids,
    'Price': order_prices,
    'Quantity': order_quantities,
    'Status': order_statuses,
    'OrderDate': order_dates
})

print("Saving Orders.csv...")
df_orders.to_csv(r'D:\\SQL_WORKS\\Homework2\\Orders.csv', index=False)
print(f"✓ Orders.csv created: {len(df_orders):,} rows\n")

print("="*60)
print("Summary:")
print(f"  Persons:  {len(df_persons):,} rows")
print(f"  Products: {len(df_products):,} rows")
print(f"  Orders:   {len(df_orders):,} rows")
print("="*60)
print("\n✓ All CSV files generated successfully!")