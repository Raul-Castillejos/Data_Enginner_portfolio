--Componentes técnicos
# 🔧 Implementación Técnica - DataStage Components

## 📋 Overview
Pipeline ETL implementado en IBM Cloud Pak for Data usando DataStage para orquestación visual entre Snowflake (origen) y Snowflake (destino).

## 🏗️ Arquitectura del Pipeline

### **Stages Utilizados:**
- **Snowflake Connector (Origen)**: Conexión a `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000`
- **Transformer Stage**: Joins y transformaciones entre tablas
- **Snowflake Connector (Destino)**: Carga a esquema `ANALYTICS`

### **Flujo de Datos:**
  CUSTOMER Table → JOIN → Transformaciones → CUSTOMER_ORDERS_DETAILED
  ORDERS Table → JOIN → Business Rules → (Tabla Final)
  LINEITEM Table → JOIN → Métricas →
  
## ⚙️ Configuraciones Clave

### **Conexión Snowflake:**
```properties
  Warehouse: COMPUTE_WH
  Database: DATASTAGE_DB
  Schema: TPCH_SF1000 (origen) / ANALYTICS (destino)
  Role: SYSADMIN
