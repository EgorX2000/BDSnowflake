-- 1. география
insert into dim_geography (country, city, state, postal_code)
select distinct customer_country, null, null, customer_postal_code from raw_data
union
select distinct store_country, store_city, store_state, null from raw_data
union
select distinct supplier_country, supplier_city, null, null from raw_data;

-- 2. категории
insert into dim_categories (name, pet_type)
select distinct product_category, pet_category from raw_data;

-- 3. поставщики
insert into dim_suppliers (name, contact_person, email, phone, geo_id)
select distinct on (supplier_name) 
    supplier_name, supplier_contact, supplier_email, supplier_phone, g.geo_id
from raw_data r
join dim_geography g on r.supplier_country = g.country 
                    and r.supplier_city is not distinct from g.city;

-- 4. магазины
insert into dim_stores (name, phone, email, geo_id)
select distinct on (store_name) 
    store_name, store_phone, store_email, g.geo_id
from raw_data r
join dim_geography g on r.store_country = g.country 
                    and r.store_city is not distinct from g.city;

-- 5. товары
insert into dim_products (name, brand, category_id, supplier_id, price, weight, color, material)
select distinct on (product_name, product_brand) 
    product_name, product_brand, c.category_id, s.supplier_id, product_price, product_weight, product_color, product_material
from raw_data r
join dim_categories c on r.product_category = c.name and r.pet_category = c.pet_type
join dim_suppliers s on r.supplier_name = s.name;

-- 6. покупатели
insert into dim_customers (first_name, last_name, email, age, pet_name, pet_type, geo_id)
select distinct on (customer_email) 
    customer_first_name, customer_last_name, customer_email, customer_age, customer_pet_name, customer_pet_type, g.geo_id
from raw_data r
join dim_geography g on r.customer_country = g.country 
                    and r.customer_postal_code is not distinct from g.postal_code;

-- 7. факты продаж
insert into fact_sales (date, product_id, customer_id, store_id, quantity, total_price)
select 
    r.sale_date, 
    p.product_id, 
    c.customer_id, 
    st.store_id, 
    r.sale_quantity, 
    r.sale_total_price
from raw_data r
join dim_products p on r.product_name = p.name and r.product_brand = p.brand
join dim_customers c on r.customer_email = c.email
join dim_stores st on r.store_name = st.name;