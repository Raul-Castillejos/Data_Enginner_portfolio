# Notas de Implementación

## Proceso que seguí

1. **Configuración inicial en Cloud Pak for Data**
   - Creé un nuevo proyecto DataStage
   - Configuré la conexión a Snowflake con mis credenciales
   - Verifiqué que podía acceder al dataset TPCH_SF1000

2. **Diseño del pipeline**
   - Usé el Snowflake Connector para extraer datos de CUSTOMER, ORDERS y LINEITEM
   - Configuré joins entre las tablas usando stages de Transformer
   - Agregué cálculos de métricas como NET_PRICE y segmentación de clientes
   - Configuré el destino en Snowflake con la tabla ANALYTICS.CUSTOMER_ORDERS_DETAILED

3. **Pruebas y ajustes**
    ## Error: después de compilar se detecta en el stage de filtrado al poner comillas curvas en lugar de rectas: (‘y’)|(‘y’)
   - Ejecuté el pipeline por partes para verificar cada transformación
   - Revisé los counts de registros entre origen y destino
   - Validé que los cálculos de métricas fueran correctos

## Decisiones técnicas

- Elegí DataStage porque ya estaba disponible en Cloud Pak for Data además de mis facilidades por tener una cuenta empresarial además tiene buena integración con Snowflake

## Lo que aprendí

- DataStage es potente para pipelines ETL complejos pero tiene curva de aprendizaje
- La integración Snowflake-DataStage funciona bien para mover datos entre ambos sistemas
- Es importante probar cada stage por separado antes de ejecutar el pipeline completo
- Los proyectos de DataStage se integran bien con el versionado de Cloud Pak for Data

## Para mejorar

- Podría haber parametrizado más el pipeline para hacerlo reutilizable
- Sería bueno agregar más validaciones de calidad de datos
- En un proyecto real, implementaría carga incremental en lugar de full refresh
