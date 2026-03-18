CREATE DATABASE VentasDW;
GO
USE VentasDW;
GO

CREATE TABLE DimCliente (
    IdCliente INT PRIMARY KEY,
    NombreCliente NVARCHAR(100),
    Pais NVARCHAR(100),
    Region NVARCHAR(100),
    Ciudad NVARCHAR(100)
)
GO

CREATE TABLE DimProducto (
    IdProducto INT PRIMARY KEY,
    NombreProducto NVARCHAR(150),
    Categoria NVARCHAR(100),
    PrecioUnitario DECIMAL(10,2),
    Proveedor NVARCHAR(100)
);
GO

CREATE TABLE DimTiempo (
    IdTiempo INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    Dia INT,
    Mes INT,
    NombreMes NVARCHAR(20),
    Trimestre INT,
    Año INT,
    DiaSemana NVARCHAR(20)
);
GO

CREATE TABLE HechoVentas (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT,
    IdProducto INT,
    IdTiempo INT,
    CantidadVendida INT,
    PrecioUnitario DECIMAL(10,2),
    Descuento DECIMAL(5,2),
    TotalVenta AS (CantidadVendida * PrecioUnitario * (1 - (Descuento/100))) PERSISTED,
    CONSTRAINT FK_HechoVentas_Cliente FOREIGN KEY (IdCliente) REFERENCES DimCliente(IdCliente),
    CONSTRAINT FK_HechoVentas_Producto FOREIGN KEY (IdProducto) REFERENCES DimProducto(IdProducto),
    CONSTRAINT FK_HechoVentas_Tiempo FOREIGN KEY (IdTiempo) REFERENCES DimTiempo(IdTiempo)
);
GO
ALTER TABLE DimCliente
ALTER COLUMN NombreCliente NVARCHAR(101);

SELECT TOP 10 * FROM HechoVentas;

SELECT SUM(TotalVenta) AS Total_Ventas_Global
FROM HechoVentas;

SELECT AVG(TotalVenta) AS Promedio_Venta_Transaccion
FROM HechoVentas;

SELECT 
t.Año,
t.Mes,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.Año, t.Mes
ORDER BY t.Año, t.Mes;

SELECT 
    c.Pais,
    c.Region,
    c.Ciudad,
    SUM(h.TotalVenta) AS Volumen_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.Pais, c.Region, c.Ciudad
ORDER BY Volumen_Ventas DESC;

SELECT 
p.NombreProducto,
SUM(h.CantidadVendida) AS Total_Unidades
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.NombreProducto
ORDER BY Total_Unidades DESC;

SELECT 
p.NombreProducto,
SUM(h.TotalVenta) AS Ingreso_Total
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.NombreProducto
ORDER BY Ingreso_Total DESC;

SELECT TOP 10
p.NombreProducto,
SUM(h.CantidadVendida) AS Unidades_Vendidas
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.NombreProducto
ORDER BY Unidades_Vendidas ASC;

SELECT TOP 10 *
FROM HechoVentas
WHERE IdProducto IN (SELECT IdProducto FROM DimProducto);

SELECT
    P.NombreProducto,
    AVG(HV.PrecioUnitario) AS PrecioPromedioVenta
FROM
    HechoVentas AS HV
JOIN DimProducto AS P ON HV.IdProducto = P.IdProducto
GROUP BY P.NombreProducto
ORDER BY P.NombreProducto ASC;


--3
SELECT 
    c.NombreCliente,
    COUNT(h.IdVenta) AS Numero_Compras
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente
ORDER BY Numero_Compras DESC;

SELECT 
c.NombreCliente,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente
ORDER BY Total_Ventas DESC;

SELECT 
    c.NombreCliente,
    AVG(h.CantidadVendida) AS Promedio_Productos
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente;

--
WITH VentasPorCliente AS (
SELECT 
c.NombreCliente,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente
)
SELECT TOP 5 
NombreCliente,
Total_Ventas,
(Total_Ventas * 100.0 / (SELECT SUM(Total_Ventas) FROM VentasPorCliente)) AS Porcentaje_Total
FROM VentasPorCliente
ORDER BY Total_Ventas DESC;

SELECT 
    c.Pais,
    SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.Pais
ORDER BY Total_Ventas DESC;

--4 me pierdooo
SELECT 
t.Año,
t.Mes,
SUM(h.TotalVenta) AS Ventas_Mensuales
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.Año, t.Mes
ORDER BY t.Año, t.Mes;

SELECT TOP 5
t.NombreMes,
SUM(h.TotalVenta) AS Ventas_Totales
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.NombreMes
ORDER BY Ventas_Totales DESC;

SELECT 
p.NombreProducto,
t.Mes,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY p.NombreProducto, t.Mes
ORDER BY p.NombreProducto, t.Mes;

SELECT 
t.Año,
SUM(h.TotalVenta) AS Total_Anual
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.Año
ORDER BY t.Año;

--5 ULTIMO (ARRIBA EL LICEY)

SELECT 
p.Categoria,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.Categoria
ORDER BY Total_Ventas DESC;

WITH VentasPorCategoria AS (
SELECT 
p.Categoria,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.Categoria
)
SELECT 
Categoria,
Total_Ventas,
(Total_Ventas * 100.0 / (SELECT SUM(Total_Ventas) FROM VentasPorCategoria)) AS Porcentaje_Total
FROM VentasPorCategoria
ORDER BY Porcentaje_Total DESC;

SELECT 
c.Pais,
c.Region,
c.Ciudad,
SUM(h.TotalVenta) AS Total_Ventas,
COUNT(h.IdVenta) AS Numero_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.Pais, c.Region, c.Ciudad
ORDER BY Total_Ventas DESC;

SELECT 
t.Año,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.Año
ORDER BY t.Año;

--6 Faltaban mas wao

SELECT
SUM(TotalVenta) AS TotalGlobalDeVentas
FROM HechoVentas;

SELECT 
p.NombreProducto,
c.NombreCliente,
t.Mes,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
JOIN DimCliente c ON h.IdCliente = c.IdCliente
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY p.NombreProducto, c.NombreCliente, t.Mes
ORDER BY Total_Ventas DESC;

SELECT TOP 5
p.NombreProducto,
SUM(h.CantidadVendida) AS Total_Unidades
FROM HechoVentas h
JOIN DimProducto p ON h.IdProducto = p.IdProducto
GROUP BY p.NombreProducto
ORDER BY Total_Unidades DESC;

SELECT TOP 5
c.NombreCliente,
SUM(h.TotalVenta) AS Total_Ventas
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente
ORDER BY Total_Ventas DESC;

SELECT 
c.NombreCliente,
AVG(h.TotalVenta) AS Promedio_Venta
FROM HechoVentas h
JOIN DimCliente c ON h.IdCliente = c.IdCliente
GROUP BY c.NombreCliente;


WITH VentasMensuales AS (
SELECT 
t.Año,
t.Mes,
SUM(h.TotalVenta) AS Ventas_Mensuales
FROM HechoVentas h
JOIN DimTiempo t ON h.IdTiempo = t.IdTiempo
GROUP BY t.Año, t.Mes
)
SELECT 
Año,
Mes,
Ventas_Mensuales,
LAG(Ventas_Mensuales) OVER (ORDER BY Año, Mes) AS Ventas_Mes_Anterior,
( (Ventas_Mensuales - LAG(Ventas_Mensuales) OVER (ORDER BY Año, Mes)) * 100.0 /
NULLIF(LAG(Ventas_Mensuales) OVER (ORDER BY Año, Mes), 0) ) AS Crecimiento_Porcentual
FROM VentasMensuales;





