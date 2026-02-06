-- ============================================
-- Creacion de tabla staging para carga de datos desde CSV
-- ============================================

CREATE TABLE staging_data (
    invoice_no VARCHAR(50),
    customer_id VARCHAR(50),
    gender VARCHAR(10),
    age INTEGER,
    category VARCHAR(100),
    quantity INTEGER,
    price DECIMAL(10,2),
    payment_method VARCHAR(50),
    invoice_date VARCHAR(20),  -- VARCHAR primero, luego convertiremos
    shopping_mall VARCHAR(150)
);

-- ============================================
-- CTE's para llenar tablas dim y fact
-- ============================================

-- DIM_CATEGORY
WITH categorias_limpias AS ( 
  SELECT DISTINCT 
    CASE
      WHEN TRIM(category) = 'Food & Beverage' THEN 'Food and Beverage' -- Estandariza &
      ELSE INITACP(TRIM(category)) -- Estandariza primer mayuscula    ---------------------!!!!!!!! Aquí falló la transformacion era INITCAP no INITACP
    END as category_name_limpio
  FROM staging_data
  WHERE category IS NOT NULL AND LENGTH(TRIM(category)) > 0
  ORDER BY category
)

INSERT INTO dim_category(category_name)
SELECT category_name_limpio 
FROM categorias_limpias 
ON CONFLICT(category_name) DO NOTHING;

-- DIM_SHOPPING_MALL
WITH
  -- CTE malls unicos
  shopping_mall_unicos AS (
    SELECT DISTINCT
      TRIM(shopping_mall) AS mall_name_limpio
    FROM
      staging_data
    WHERE
      shopping_mall IS NOT NULL
      AND LENGTH(shopping_mall) > 0
  ),
  -- CTE malls enriquecidos
  shopping_mall_enriquecido AS (
    SELECT
      mall_name_limpio,
      CASE
        WHEN mall_name_limpio = 'Metrocity' THEN 'Sisli'
        WHEN mall_name_limpio = 'Kanyon' THEN 'Istanbul'
        WHEN mall_name_limpio = 'Mall of Istanbul' THEN 'Istanbul'
        WHEN mall_name_limpio = 'Viaport Outlet' THEN 'Istanbul'
        WHEN mall_name_limpio = 'Cevahir AVM' THEN 'Sisli'
        WHEN mall_name_limpio = 'Istinye Park' THEN 'Sariyer'
        WHEN mall_name_limpio = 'Emaar Square Mall' THEN 'Uskudar'
        WHEN mall_name_limpio = 'Zorlu Center' THEN 'Besiktas'
        WHEN mall_name_limpio = 'Metropol AVM' THEN 'Atasehir'
        WHEN mall_name_limpio = 'Forum Istanbul' THEN 'Istanbul'
        ELSE 'Unknown'
      END AS city_enriquecido,
      CASE
        WHEN mall_name_limpio = 'Metrocity' THEN 'Istanbul Provinzia'
        WHEN mall_name_limpio = 'Kanyon' THEN 'Istanbul Center'
        WHEN mall_name_limpio = 'Mall of Istanbul' THEN 'Istanbul Center'
        WHEN mall_name_limpio = 'Viaport Outlet' THEN 'Asian Side'
        WHEN mall_name_limpio = 'Cevahir AVM' THEN 'Istanbul Center'
        WHEN mall_name_limpio = 'Istinye Park' THEN 'European Side'
        WHEN mall_name_limpio = 'Emaar Square Mall' THEN 'Asian Side'
        WHEN mall_name_limpio = 'Zorlu Center' THEN 'Istanbul Center'
        WHEN mall_name_limpio = 'Metropol AVM' THEN 'Istanbul Provinzia'
        WHEN mall_name_limpio = 'Forum Istanbul' THEN 'Istanbul Center'
        ELSE 'Unknown'
      END AS region_enriquecido
    FROM
      shopping_mall_unicos
  )
INSERT INTO dim_shopping_mall (mall_name, city, region)
SELECT
  mall_name_limpio,
  city_enriquecido,
  region_enriquecido
FROM
  shopping_mall_enriquecido
  ON CONFLICT (mall_name) DO NOTHING; -- Se agregó CONSTRAINT UNIQUE a mall_name


--DIM_TIME
--CTE Para normalizar fechas validas
WITH fechas_normalizadas AS (
    SELECT DISTINCT
        -- Normalizar formato inconsistente (6/1/2021 -> 06/01/2021)
        TO_DATE(
            LPAD(SPLIT_PART(invoice_date, '/', 1), 2, '0') || '/' ||
            LPAD(SPLIT_PART(invoice_date, '/', 2), 2, '0') || '/' ||
            SPLIT_PART(invoice_date, '/', 3),
            'DD/MM/YYYY'
        ) as fecha_limpia
    FROM staging_data
    WHERE invoice_date IS NOT NULL
      AND invoice_date ~ '^\d{1,2}/\d{1,2}/\d{4}$'  -- Filtra fechas válidas
),
tiempo_enriquecido AS (
    SELECT
        fecha_limpia,
        EXTRACT(DAY FROM fecha_limpia) as dia,
        EXTRACT(MONTH FROM fecha_limpia) as mes,
        EXTRACT(YEAR FROM fecha_limpia) as año,
        EXTRACT(QUARTER FROM fecha_limpia) as trimestre,
        TO_CHAR(fecha_limpia, 'Day') as nombre_dia,
        -- ISODOW: 1=Lunes, 7=Domingo
        EXTRACT(ISODOW FROM fecha_limpia) IN (6, 7) as es_fin_semana
    FROM fechas_normalizadas
    WHERE fecha_limpia IS NOT NULL
)
INSERT INTO dim_tiempo (date_id, day, month, year, quarter, day_of_week, is_weekend)
SELECT 
    fecha_limpia as date_id,
    dia,
    mes,
    año,
    trimestre,
    TRIM(nombre_dia) as day_of_week,  -- TRIM quita espacios extra
    es_fin_semana as is_weekend
FROM tiempo_enriquecido
ORDER BY fecha_limpia;

--DIM_CUSTOMER
-- CTE para limpiar y normalizar clientes
-- 3. CTE CORREGIDO para gender
WITH clientes_unicos AS (
    SELECT DISTINCT
        customer_id,
        -- CORRECCIÓN: Gender corregido
        CASE 
            WHEN UPPER(TRIM(gender)) = 'MALE' OR UPPER(TRIM(gender)) = 'M' THEN 'M'
            WHEN UPPER(TRIM(gender)) = 'FEMALE' OR UPPER(TRIM(gender)) = 'F' THEN 'F'
            ELSE 'O'
        END as genero_limpio,
        age
    FROM staging_data
    WHERE customer_id IS NOT NULL
      AND customer_id != ''
      AND age IS NOT NULL
      AND age BETWEEN 1 AND 120
),
clientes_con_grupo AS (
    SELECT
        customer_id,
        genero_limpio,
        age,
        CASE 
            WHEN age < 18 THEN 'Menor 18'
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            WHEN age >= 65 THEN '65+'
            ELSE 'Desconocido'
        END as grupo_edad
    FROM clientes_unicos
)
INSERT INTO dim_customer (id_customer, gender, age, age_group)
SELECT 
    customer_id,
    genero_limpio as gender,
    age,
    grupo_edad as age_group
FROM clientes_con_grupo
ORDER BY customer_id;
