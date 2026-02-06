-- ============================================
-- 1. DIM_SHOPPING_MALL (Centro Comercial)
-- ============================================
CREATE TABLE IF NOT EXISTS dim_shopping_mall (
    id_mall SERIAL PRIMARY KEY,
    mall_name VARCHAR(150) NOT NULL, -- Se agregó CONSTRAINT UNIQUE en carga, era importante para ON CONFLICT
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100)
);

COMMENT ON TABLE dim_shopping_mall IS 'Catálogo de centros comerciales';
COMMENT ON COLUMN dim_shopping_mall.mall_name IS 'Nombre del shopping mall (ej: Mall of Istanbul)';

-- ============================================
-- 2. DIM_CATEGORIA (Categoría de Producto)
-- ============================================
CREATE TABLE IF NOT EXISTS dim_categoria (
    id_category SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

COMMENT ON TABLE dim_categoria IS 'Catálogo de categorías de productos';

-- ============================================
-- 3. DIM_CLIENTE (Clientes con edad agrupada)
-- ============================================
CREATE TABLE IF NOT EXISTS dim_cliente (
    customer_id VARCHAR(50) PRIMARY KEY,
    gender CHAR(6) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    age INTEGER NOT NULL, -- guarda el dato original
    age_group VARCHAR(20) NOT NULL 
);

COMMENT ON TABLE dim_cliente IS 'Dimension de clientes con grupos de edad';
COMMENT ON COLUMN dim_cliente.age_group IS 'Grupo etario: 18-25, 26-35, 36-50, 50+';

-- ============================================
-- 4. DIM_TIME (Tabla de calendario)
-- ============================================
CREATE TABLE IF NOT EXISTS dim_time (
    id_date DATE PRIMARY KEY,
    day INTEGER NOT NULL CHECK (day BETWEEN 1 AND 31),
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    day_of_week VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

COMMENT ON TABLE dim_time IS 'Tabla de dimension de tiempo (calendario)';

-- ============================================
-- 5. FACT_SALES (Tabla de hechos - transacciones)
-- ============================================
CREATE TABLE IF NOT EXISTS fact_sales (
    id_sales SERIAL PRIMARY KEY,
    invoice_no VARCHAR(50) NOT NULL,
    id_date DATE NOT NULL REFERENCES dim_time(id_date),
    id_mall INTEGER NOT NULL REFERENCES dim_shopping_mall(id_mall),
    id_category INTEGER NOT NULL REFERENCES dim_category(id_category),
    id_customer VARCHAR(50) NOT NULL REFERENCES dim_customer(id_customer),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
);

COMMENT ON TABLE fact_sales IS 'Hechos de ventas - transacciones detalladas';
COMMENT ON COLUMN fact_sales.price_per_unit IS 'Precio unitario calculado = total_amount / quantity';
