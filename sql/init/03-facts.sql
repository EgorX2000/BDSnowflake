create table fact_sales (
    sale_id serial primary key,
    date date,
    product_id int references dim_products(product_id),
    customer_id int references dim_customers(customer_id),
    store_id int references dim_stores(store_id),
    quantity int,
    total_price decimal
);
