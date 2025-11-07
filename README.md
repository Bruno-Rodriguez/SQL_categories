# Creando categorías por desempeño en MS SQL Server

En este proyecto usé las funciones de búsquedas en SQL Server para crear un esquema de clasificacion para los conductores de una empresa de entragas a domicilio, basado en el desempeño de cada conductor durante un mes específico. Se asigna la Categoría 1 a los conductores que contribuyan al 10% superior de los viajes totales del mes, la Categoría 2 a los que contribuyan al 20% siguiente, la Categoría 3 a aquellos que contribuyan al 30% siguiente, y la Categoría 4 a los que solo contribuyeron al último 40% de los viajes totales. Este proyecto demuestra una buena práctica de técnicas útiles de SQL, tales como creación de vistas, CTEs, unión de tablas y cláusulas CASE.

El archivo SQLQuery_Categorias.sql contiene 

```
WITH trip_counts AS (
	SELECT 
		o.[driver_profile.id] DriverID,
		FORMAT(CAST(o.[ended_at] AS DATE), 'yyyy-MM') 'Year-Month',
		CAST(COUNT(*) AS FLOAT) Trips
	FROM 
		[Database].[dbo].[Orders] o
	WHERE 
		o.status = 'complete' AND
		MONTH(CAST(o.[ended_at] AS DATE)) = 5 AND -- Filtrar por mes de mayo
		YEAR(CAST(o.[ended_at] AS DATE)) = 2021 -- Filtrar por año 2021
	GROUP BY 
		o.[driver_profile.id], FORMAT(CAST(o.[ended_at] AS DATE), 'yyyy-MM')),

	totals AS (
	SELECT DriverID,
		Trips,
		Trips/(SELECT SUM(Trips) FROM trip_counts) AS Trips_f,
		SUM(Trips/(SELECT SUM(Trips) FROM trip_counts)) OVER (ORDER BY Trips ASC) AS Trips_f_acc
	FROM trip_counts tc)
```

Una vista simple de los reultados de la clasificación se puede ver a continuación: (los nombres han sido censurados para asegurar la privacidad de los empleados)

![view_results](/view_results.jpg)

El recuento de cuántos conductores corresponden a cada categoría se aprecia a continuación:

![view_counts](/view_counts.jpg)
