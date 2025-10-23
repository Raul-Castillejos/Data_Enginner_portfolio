-- =============================================
-- LÓGICA DE TRANSFORMACIÓN APLICADA EN DATASTAGE
-- =============================================

-- Join entre tablas (esto es lo que DataStage hizo visualmente)
WITH customer_orders AS (
    SELECT
        c.C_CUSTKEY,
        c.C_NAME,
        c.C_ACCTBAL,
        c.C_MKTSEGMENT,
        o.O_ORDERKEY,
        o.O_ORDERDATE,
        o.O_TOTALPRICE,
        o.O_ORDERSTATUS,
        l.L_QUANTITY,
        l.L_EXTENDEDPRICE,
        l.L_DISCOUNT,
        l.L_TAX,
        (l.L_EXTENDEDPRICE * (1 - l.L_DISCOUNT) * (1 + l.L_TAX)) AS NET_PRICE
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER c
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS o 
        ON c.C_CUSTKEY = o.O_CUSTKEY
    JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.LINEITEM l 
        ON o.O_ORDERKEY = l.L_ORDERKEY
    WHERE o.O_ORDERDATE >= '1998-01-01'
),

business_metrics AS (
    SELECT
        C_CUSTKEY,
        C_NAME,
        C_MKTSEGMENT,
        O_ORDERDATE,
        O_TOTALPRICE,
        L_QUANTITY,
        NET_PRICE,
        -- Métricas de negocio calculadas
        CASE 
            WHEN C_ACCTBAL > 5000 THEN 'High Balance'
            WHEN C_ACCTBAL BETWEEN 1000 AND 5000 THEN 'Medium Balance' 
            ELSE 'Low Balance'
        END AS CUSTOMER_SEGMENT,
        CASE
            WHEN O_TOTALPRICE > 100000 THEN 'Large Order'
            WHEN O_TOTALPRICE > 50000 THEN 'Medium Order'
            ELSE 'Small Order'
        END AS ORDER_SIZE_CATEGORY
    FROM customer_orders
)

SELECT * FROM business_metrics;
