# Creando categorías por desempeño en MS SQL Server
___

En este proyecto usé las funciones de consultas en SQL Server para crear un esquema de clasificacion para los conductores de una empresa de entragas a domicilio, basado en el desempeño de cada conductor durante un mes específico. Se asigna la Categoría 1 a los conductores que contribuyan al 10% superior de los viajes totales del mes, la Categoría 2 a los que contribuyan al 20% siguiente, la Categoría 3 a aquellos que contribuyan al 30% siguiente, y la Categoría 4 a los que solo contribuyeron al último 40% de los viajes totales. Este proyecto demuestra una buena práctica de técnicas útiles de SQL, tales como creación de vistas, CTEs, unión de tablas, funciones de ventana y cláusulas CASE.

El archivo `SQLQuery_Categorias.sql` contiene las consultas realizadas para generar la clasifiación, así como para mostrar los resultados y realizar un recuento del número de conductores en cada categoría. Veamos algunas de las partes de este archivo. El siguiente bloque de código crea dos CTEs (expresiones de tablas comunes) que son referenciadas más adelante. La primera de ellas cuenta el número de viajes completados por cada conductor en un año y mes determinados, mientras que la segunda calcula qué fracción de los viajes totales de todos conductores representan los viajes de cada conductor, así como la fracción acumulada que será usada para asignar las categorías de la clasificación: 

```sql
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

Con el siguiente bloque se crea la tabla final deseada, en la cual se une la CTE anterior con la base de datos de los perfiles de los conductores para mostrar el número de identificación único de cada conductor junto con su nombre, el número de viajes realizados, la fracción y fracción acumulada correspondientes del total de viajes, y la categoría que ha sido asignada.

```sql
SELECT DriverID AS 'ID Conductor', 
		CONCAT(TRIM(dp.[driver_profile.first_name]),' ',CONCAT(TRIM(dp.[driver_profile.middle_name]),' ',TRIM(dp.[driver_profile.last_name]))) AS 'Nombre Conductor',
		Trips AS 'N. Viajes',
		ROUND(Trips_f,4) AS 'Fracción de total de viajes',
		ROUND(Trips_f_acc,4) AS 'Fracción acumulada de total de viajes',
		CASE WHEN (Trips_f_acc > 0.9) THEN 'Categoría 1'
			 WHEN (Trips_f_acc BETWEEN 0.7 AND 0.9) THEN 'Categoría 2'
			 WHEN (Trips_f_acc BETWEEN 0.4 AND 0.7) THEN 'Categoría 3' ELSE 'Categoría 4' END AS 'Categoría'
FROM totals t
  LEFT JOIN [Database].[dbo].[DriverProfiles] dp
  ON t.DriverID = dp.[driver_profile.id];
```

La siguiente consulta muestra la tabla final deseada, con los conductores ordenados de manera descendente en función del número de viajes realizados. Una vista simple de los resultados de la clasificación se puede ver a continuación (los nombres han sido censurados por motivos de privacidad):

```sql
SELECT * 
FROM conductores_categorias
ORDER BY 'N. Viajes' DESC;
```

![view_results](/view_results.jpg)


La siguiente consulta realiza un recuento del núemro de conductores asignados a cada categoría, el cual se aprecia a continuación:

```sql
SELECT Categoría, COUNT(*) AS 'Conductores por categoría'
FROM conductores_categorias
GROUP BY Categoría
ORDER BY 'Conductores por categoría' ASC;
```

![view_counts](/view_counts.jpg)
