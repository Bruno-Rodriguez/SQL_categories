-- Crear vista con IDs y nombres de conductores, número de viajes completados, fracción del total de viaje, acumulado de las fracciones, y la categoría correspondiente
CREATE VIEW conductores_categorias AS 
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


-- Visualizar los resultados completos de la vista
SELECT * 
FROM conductores_categorias
ORDER BY 'N. Viajes' DESC;


-- Visualizar la cuenta de conductores por cada categoría
SELECT Categoría, COUNT(*) AS 'Conductores por categoría'
FROM conductores_categorias
GROUP BY Categoría

ORDER BY 'Conductores por categoría' ASC;
