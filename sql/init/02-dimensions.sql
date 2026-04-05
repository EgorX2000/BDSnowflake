create table dim_geography (
    geo_id serial primary key,
    city text,
    state text,
    country text,
    postal_code text
);

create table dim_categories (
    category_id serial primary key,
    name text,
    pet_type text
);

create table dim_suppliers (
    supplier_id serial primary key,
    name text,
    contact_person text,
    email text,
    phone text,
    geo_id int references dim_geography(geo_id)
);

create table dim_products (
    product_id serial primary key,
    name text,
    brand text,
    category_id int references dim_categories(category_id),
    supplier_id int references dim_suppliers(supplier_id),
    price decimal,
    weight decimal,
    color text,
    material text
);

create table dim_customers (
    customer_id serial primary key,
    first_name text,
    last_name text,
    email text,
    age int,
    pet_name text,
    pet_type text,
    geo_id int references dim_geography(geo_id)
);

create table dim_stores (
    store_id serial primary key,
    name text,
    phone text,
    email text,
    geo_id int references dim_geography(geo_id)
);
