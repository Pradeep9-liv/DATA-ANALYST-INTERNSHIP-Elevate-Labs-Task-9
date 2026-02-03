
-- GLOBAL SUPERSTORE STAR SCHEMA SQL

-- DIMENSION TABLES
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    product_name TEXT,
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE dim_region (
    region_key SERIAL PRIMARY KEY,
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    market VARCHAR(50)
);

CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    year INT,
    weeknum INT
);

-- FACT TABLE
CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    order_id VARCHAR(50),
    customer_key INT REFERENCES dim_customer(customer_key),
    product_key INT REFERENCES dim_product(product_key),
    region_key INT REFERENCES dim_region(region_key),
    date_key INT REFERENCES dim_date(date_key),
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    shipping_cost DECIMAL(10,2)
);

-- INSERT DIMENSIONS
INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT "Customer.ID", "Customer.Name", Segment FROM superstore;

INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT "Product.ID", "Product.Name", Category, "Sub.Category" FROM superstore;

INSERT INTO dim_region (country, region, state, city, market)
SELECT DISTINCT Country, Region, State, City, Market FROM superstore;

INSERT INTO dim_date (order_date, ship_date, year, weeknum)
SELECT DISTINCT "Order.Date", "Ship.Date", Year, weeknum FROM superstore;

-- INSERT FACT
INSERT INTO fact_sales (
    order_id, customer_key, product_key, region_key, date_key,
    sales, profit, quantity, discount, shipping_cost
)
SELECT
    s."Order.ID",
    dc.customer_key,
    dp.product_key,
    dr.region_key,
    dd.date_key,
    s.Sales,
    s.Profit,
    s.Quantity,
    s.Discount,
    s."Shipping.Cost"
FROM superstore s
JOIN dim_customer dc ON s."Customer.ID" = dc.customer_id
JOIN dim_product dp ON s."Product.ID" = dp.product_id
JOIN dim_region dr 
    ON s.Country = dr.country 
   AND s.Region = dr.region 
   AND s.State = dr.state 
   AND s.City = dr.city
JOIN dim_date dd 
    ON s."Order.Date" = dd.order_date 
   AND s."Ship.Date" = dd.ship_date;

-- INDEXES
CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_product ON fact_sales(product_key);
CREATE INDEX idx_fact_region ON fact_sales(region_key);
CREATE INDEX idx_fact_date ON fact_sales(date_key);
