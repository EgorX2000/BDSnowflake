-- Должно быть 10 000 в обеих таблицах. Это доказывает отсутствие потерь при трансформации.
SELECT 
    (SELECT count(*) FROM raw_data) as rows_in_raw,
    (SELECT count(*) FROM fact_sales) as rows_in_fact;


-- Сумма всех продаж в исходной таблице должна совпадать с суммой в таблице фактов.
SELECT 
    (SELECT round(sum(sale_total_price), 2) FROM raw_data) as total_revenue_raw,
    (SELECT round(sum(total_price), 2) FROM fact_sales) as total_revenue_snowflake;


-- Если запрос возвращает данные, значит все внешние ключи настроены правильно (имеем структуру снежинки).
SELECT 
    f.sale_id,
    c.first_name || ' ' || c.last_name as customer_full_name,
    cg_cust.country as customer_country,  -- dim_customers -> dim_geography
    p.name as product_name,
    cat.name as category_name,            -- dim_products -> dim_categories
    s.name as store_name,
    cg_store.city as store_city            -- dim_stores -> dim_geography
FROM fact_sales f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_geography cg_cust ON c.geo_id = cg_cust.geo_id
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_categories cat ON p.category_id = cat.category_id
JOIN dim_stores s ON f.store_id = s.store_id
JOIN dim_geography cg_store ON s.geo_id = cg_store.geo_id
LIMIT 10;


-- Проверяем, нет ли в таблице фактов записей, которые не привязались к измерениям. Все результаты должны быть 0.
SELECT 
    count(*) FILTER (WHERE product_id IS NULL) as facts_without_product,
    count(*) FILTER (WHERE customer_id IS NULL) as facts_without_customer,
    count(*) FILTER (WHERE store_id IS NULL) as facts_without_store
FROM fact_sales;


-- Проверка наполненности всех измерений.
SELECT 'dim_geography' as tbl, count(*) as cnt FROM dim_geography
UNION ALL
SELECT 'dim_customers', count(*) FROM dim_customers
UNION ALL
SELECT 'dim_products', count(*) FROM dim_products
UNION ALL
SELECT 'dim_suppliers', count(*) FROM dim_suppliers
UNION ALL
SELECT 'dim_stores', count(*) FROM dim_stores
UNION ALL
SELECT 'dim_categories', count(*) FROM dim_categories;


-- Демонстрирует готовность модели к реальной аналитике (используем связи снежинки).
SELECT 
    g.country, 
    sum(f.quantity) as total_items_sold,
    round(sum(f.total_price), 2) as total_revenue
FROM fact_sales f
JOIN dim_stores s ON f.store_id = s.store_id
JOIN dim_geography g ON s.geo_id = g.geo_id
GROUP BY g.country
ORDER BY total_revenue DESC
LIMIT 3;