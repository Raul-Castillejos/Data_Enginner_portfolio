-- Construccion de tabla fact_sales:
-- Primero, veamos lo que tenemos en staging
SELECT 
    invoice_no,
    invoice_date,
    shopping_mall,
    category,
    customer_id,
    quantity,
    price,
    payment_method
FROM staging_data 
LIMIT 5;
----------------------------------------------------------
-- Probar solo el JOIN con tiempo
SELECT 
    s.invoice_no,
    s.invoice_date,
    -- Normalizar fecha (igual que hicimos en dim_tiempo)
    TO_DATE(
        LPAD(SPLIT_PART(s.invoice_date, '/', 1), 2, '0') || '/' ||
        LPAD(SPLIT_PART(s.invoice_date, '/', 2), 2, '0') || '/' ||
        SPLIT_PART(s.invoice_date, '/', 3),
        'DD/MM/YYYY'
    ) as fecha_normalizada,
    t.id_date,
    t.day,
    t.month,
    t.year
FROM staging_data s
-- JOIN: fecha_normalizada debe coincidir con id_date en dim_time
INNER JOIN dim_time t ON TO_DATE(
    LPAD(SPLIT_PART(s.invoice_date, '/', 1), 2, '0') || '/' ||
    LPAD(SPLIT_PART(s.invoice_date, '/', 2), 2, '0') || '/' ||
    SPLIT_PART(s.invoice_date, '/', 3),
    'DD/MM/YYYY'
) = t.id_date
LIMIT 5;

----------------------------------------------
-- Ahora agregar JOIN con centros comerciales
SELECT 
    s.invoice_no,
    s.shopping_mall,
    m.id_mall,
    m.mall_name,
    m.city
FROM staging_data s
INNER JOIN dim_shopping_mall m ON TRIM(s.shopping_mall) = m.mall_name
LIMIT 5;

----------------------------------------------
-- JOIN con categorías
SELECT 
    s.invoice_no,
    s.category,
    c.id_category,
    c.category_name
FROM staging_data s
INNER JOIN dim_category c ON TRIM(s.category) = c.category_name
LIMIT 5;

---------------------------------------------
-- JOIN con clientes
SELECT 
    s.invoice_no,
    s.customer_id,
    c.id_customer,
    c.gender,
    c.age_group
FROM staging_data s
INNER JOIN dim_customer c ON s.customer_id = c.id_customer
LIMIT 5;

---------------------------------------------
--Unir todos los JOINS + CALCULO DE PRECIO UNITARIO

-- PRIMERA VERSIÓN: Solo mostrar las conversiones
SELECT 
    -- Datos originales
    s.invoice_no,
    s.quantity,
    s.price,
    s.payment_method,
    
    -- Cálculo importante: precio por unidad
    ROUND(s.price / NULLIF(s.quantity, 0), 2) as precio_unitario_calculado,
    
    -- IDs de dimensiones (lo que necesitamos para fact_sales)
    t.id_date,
    m.id_mall,
    c.id_category,
    cu.id_customer
    
FROM staging_data s

-- Los 4 JOINS
INNER JOIN dim_time t ON TO_DATE(
    LPAD(SPLIT_PART(s.invoice_date, '/', 1), 2, '0') || '/' ||
    LPAD(SPLIT_PART(s.invoice_date, '/', 2), 2, '0') || '/' ||
    SPLIT_PART(s.invoice_date, '/', 3),
    'DD/MM/YYYY'
) = t.id_date

INNER JOIN dim_shopping_mall m ON TRIM(s.shopping_mall) = m.mall_name
INNER JOIN dim_category c ON TRIM(s.category) = c.category_name
INNER JOIN dim_customer cu ON s.customer_id = cu.id_customer

-- Filtro básico de calidad
WHERE s.quantity > 0
  AND s.price > 0
  AND s.invoice_date IS NOT NULL

LIMIT 10;

----------------------------------------------------------------------------
-- CTE Final
-- CTE 1: Hacer todas las transformaciones y joins
WITH ventas_preparadas AS (
    SELECT 
        s.invoice_no,
        s.quantity,
        s.price,
        s.payment_method,
        
        -- Calcular precio unitario (con división por cero)
        CASE 
            WHEN s.quantity > 0 THEN ROUND(s.price / s.quantity, 2)
            ELSE 0  -- O NULL, dependiendo de tu política
        END as price_per_unit,
        
        -- IDs de dimensiones
        t.id_date,
        m.id_mall,
        cat.id_category,
        cu.id_customer
        
    FROM staging_data s
    
    -- JOINS
    INNER JOIN dim_time t ON TO_DATE(
        LPAD(SPLIT_PART(s.invoice_date, '/', 1), 2, '0') || '/' ||
        LPAD(SPLIT_PART(s.invoice_date, '/', 2), 2, '0') || '/' ||
        SPLIT_PART(s.invoice_date, '/', 3),
        'DD/MM/YYYY'
    ) = t.id_date
    
    INNER JOIN dim_shopping_mall m ON TRIM(s.shopping_mall) = m.mall_name
    
    INNER JOIN dim_category cat ON 
        CASE 
            WHEN TRIM(s.category) = 'Food & Beverage' THEN 'Food and Beverage' -- Importante porque se normalizó '&' > 'and'  
            -- ------------------------------------------------------------------- Se detectó +14000 filas faltantes entre staging y fact sales
            ---------------------------------------------------------------------- En el siguiente paso se revisó
            ELSE INITCAP(TRIM(s.category))
        END = cat.category_name

    INNER JOIN dim_customer cu ON s.customer_id = cu.id_customer
    
    -- Filtros importantes
    WHERE s.invoice_no IS NOT NULL
      AND s.invoice_date IS NOT NULL
      AND s.shopping_mall IS NOT NULL
      AND s.category IS NOT NULL
      AND s.customer_id IS NOT NULL
      AND s.quantity > 0
      AND s.price > 0
      AND s.invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4}$'  -- Formato fecha válido
)

-- CTE 2: Validación final antes de insertar
, ventas_validadas AS (
    SELECT 
        invoice_no,
        id_date,
        id_mall,
        id_category,
        id_customer,
        quantity,
        -- Validar que price_per_unit sea razonable
        CASE 
            WHEN price_per_unit BETWEEN 0.01 AND 10000 THEN price_per_unit
            ELSE NULL  -- Marcar como sospechoso
        END as price_per_unit_validado,
        payment_method,
        price as total_amount
    FROM ventas_preparadas
    WHERE price_per_unit IS NOT NULL
)

-- INSERT final en fact_sales
INSERT INTO fact_sales (
    invoice_no,
    id_date,
    id_mall,
    id_category,
    id_customer,
    quantity,
    price_per_unit,
    payment_method,
    total_amount
)
SELECT 
    invoice_no,
    id_date,
    id_mall,
    id_category,
    id_customer,
    quantity,
    price_per_unit_validado,
    payment_method,
    total_amount
FROM ventas_validadas
WHERE price_per_unit_validado IS NOT NULL  -- Solo insertar datos válidos
ORDER BY id_date, invoice_no;  -- Odenar para debugging

--- Revision de faltantes:
-- ¿Qué categorías hay en staging que no están en dim_category?
SELECT DISTINCT 
    TRIM(category) as categoria_faltante,
    COUNT(*) as frecuencia,
    COUNT(DISTINCT invoice_no) as transacciones_unicas
FROM staging_data s
WHERE TRIM(category) NOT IN (
    SELECT category_name FROM dim_category
)
  AND category IS NOT NULL
  AND category != ''
GROUP BY TRIM(category)
ORDER BY frecuencia DESC;

-- También verifica mayúsculas/minúsculas
SELECT 
    'Verificación mayúsculas' as tipo,
    COUNT(DISTINCT LOWER(TRIM(category))) as categorias_lower,
    COUNT(DISTINCT TRIM(category)) as categorias_original
FROM staging_data
WHERE category IS NOT NULL;
