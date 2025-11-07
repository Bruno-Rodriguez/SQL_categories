# Creando categorías por desempeño en MS SQL Server

En este proyecto usé las funciones de búsquedas en SQL Server para crear un esquema de clasificacion para los conductores de una empresa de entragas a domicilio, basado en el desempeño de cada conductor durante un mes específico. Se asigna la Categoría 1 a los conductores que contribuyan al 10% superior de los viajes totales del mes, la Categoría 2 a los que contribuyan al 20% siguiente, la Categoría 3 a aquellos que contribuyan al 30% siguiente, y la Categoría 4 a los que solo contribuyeron al último 40% de los viajes totales. Este proyecto demuestra una buena práctica de técnicas útiles de SQL, tales como creación de vistas, CTEs, unión de tablas y cláusulas CASE.

Una vista simple de los reultados de la clasificación se puede ver a continuación: (los nombres han sido censurados para asegurar la privacidad de los empleados)

![view_results](/view_results.jpg)

El recuento de cuántos conductores corresponden a cada categoría se aprecia a continuación:

![view_counts](/view_counts.jpg)
