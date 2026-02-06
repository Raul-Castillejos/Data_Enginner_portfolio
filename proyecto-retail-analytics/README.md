# Proyecto: Análisis de Ventas Retail

# Descripción
Dashboard analítico para ventas minoristas implementando un pipeline completo de datos desde extracción hasta visualización.

# Objetivos
- Crear Infraestructura desde modelado y ETL
- Identificar patrones de compra por segmento de cliente
- Proporcionar insights accionables para toma de decisiones

# Arquitectura del Sistema
Raw Data (CSV) → Google Cloud Storage → PostgreSQL (ETL) → Looker Studio (Visualización)

# Modelado de Datos (Star Schema)
fact_sales (Tabla de Hechos)
├── dim_time (Dimensión Temporal)
├── dim_shopping_mall (Dimensión Ubicación)
├── dim_category (Dimensión Producto)
└── dim_customer (Dimensión Cliente)

## 🛠️ Tecnologías Utilizadas
| Tecnología | Uso |
|------------|-----|
| **PostgreSQL** | Base de datos relacional (Google Cloud SQL) |
| **SQL** | ETL, transformaciones, queries analíticas |
| **Looker Studio** | Visualización y dashboard interactivo |
| **Google Cloud Storage** | Almacenamiento inicial de datos |
| **CTEs (Common Table Expressions)** | Transformaciones complejas de datos |

# Habilidades Demostradas
## 1. **ETL Avanzado**
- Normalización de formatos inconsistentes y debugging (fechas, categorías)
- Validación de calidad de datos
- Transformaciones con CTEs anidadas

## 2. **Modelado Dimensional**
- Diseño e implementación de Star Schema
- Optimización para queries analíticas

## 3. **Resolución de Problemas Reales**
- **Problema:** Fechas inconsistentes (`6/1/2021` vs `24/11/2021`)
  **Solución:** `LPAD() + SPLIT_PART() + TO_DATE()`
- **Problema:** Categorías no estandarizadas (`Food & Beverage` vs `Food and Beverage`)
  **Solución:** `CASE WHEN` en JOINS y dimensiones
- **Problema:** Integridad referencial en carga de datos
  **Solución:** Validación pre-insert y CTEs de limpieza
