# 🏗️ Architecture Decision Record

## Decision: ETL vs ELT
**Elección**: ETL con DataStage
**Rationale**: 
- Transformaciones complejas requieren lógica de negocio
- DataStage provee capacidades visuales para data quality
- Snowflake como destino optimizado para lectura

## Data Flow Architecture
[Snowflake Source] → [DataStage ETL] → [Snowflake Target]
       ↓                    ↓                  ↓
   TPCH_SF1000        Transformations      ANALYTICS
   .CUSTOMER             & Joins          .CUSTOMER_ORDERS_DETAILED
   .ORDERS           Business Rules
   .LINEITEM         Data Quality

## Component Responsibilities
- **Snowflake (Source)**: Almacenamiento raw data, alta performance querying
- **DataStage**: Orquestación ETL, transformaciones, data quality
- **Snowflake (Target)**: Almacenamiento analítico, serving para BI tools
