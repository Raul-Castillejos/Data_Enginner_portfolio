# 🚀 Pipeline ETL con IBM DataStage y Snowflake

📋 Descripción del Proyecto
Pipeline ETL completo desarrollado en **IBM Cloud Pak for Data** usando **DataStage** para orquestación visual. Extracción, transformación y carga de datos entre diferentes esquemas de Snowflake.

🏗️ Arquitectura

**Flujo de Datos:**
1. **Origen**: Snowflake (tablas raw/operacionales)
2. **ETL**: IBM DataStage en Cloud Pak for Data
   - Extracción via Snowflake connector
   - Transformaciones con stages visuales
   - Validaciones de calidad
3. **Destino**: Snowflake (tablas analíticas/curated)


🛠️ Tecnologías Utilizadas
    IBM Cloud Pak for Data - Plataforma unificada
    DataStage - Orquestración ETL visual
    Snowflake - Data Warehouse (origen y destino)
    SQL - Transformaciones y consultas


📊 Flujo del Pipeline
    Extracción: Consulta a tablas origen en Snowflake
    Transformación:
    Limpieza y estandarización de datos
    Joins entre múltiples fuentes
    Cálculo de métricas de negocio
    Carga: Inserción en tablas destino optimizadas


🎯 Componentes de DataStage Utilizados
    Sequential File Stage - Manejo de datos planos
    Transformer Stage - Lógica de transformación
    Snowflake Connector - Conexión bidireccional
    Quality Stage - Validación de datos


📈 Resultados Obtenidos

✅ Pipeline ejecutándose en producción

✅ Procesamiento de X registros diarios

✅ Reducción de X% en tiempo de transformación

✅ Mejora en calidad de datos del X%

