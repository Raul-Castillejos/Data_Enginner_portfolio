-- =============================================
-- QUERIES DE EXTRACCIÓN PARA DATASTAGE
-- Basado en Snowflake QuickStart: Data Engineering with DataStage
-- La source real viene de un archivo csv esta es una recreacion de la logica empleada en el ejercicio
-- =============================================

-- Extracción de datos de clientes
SELECT 
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.CUSTOMER;

-- Extracción de datos de órdenes
SELECT 
    O_ORDERKEY,
    O_CUSTKEY,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS;

-- Extracción de datos de líneas de orden
SELECT 
    L_ORDERKEY,
    L_PARTKEY,
    L_SUPPKEY,
    L_LINENUMBER,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    L_DISCOUNT,
    L_TAX,
    L_RETURNFLAG,
    L_LINESTATUS,
    L_SHIPDATE,
    L_COMMITDATE,
    L_RECEIPTDATE,
    L_SHIPINSTRUCT,
    L_SHIPMODE,
    L_COMMENT
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.LINEITEM;
