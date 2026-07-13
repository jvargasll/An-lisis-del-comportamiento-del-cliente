--1. Ingresos por género – Comparación de los ingresos totales generados por clientes hombres frente a mujeres.
select sexo, sum(monto_de_comprar) as TotalComprado from cliente group by sexo

--2. Usuarios de descuentos con alto gasto – Identificación de clientes que utilizaron 
--   descuentos pero cuyo gasto superó el importe medio de compra.
select idcliente, monto_de_comprar
from cliente
where  descuento_aplicado='YES' and monto_de_comprar>=(select avg(monto_de_comprar) from cliente)

--3.Los 5 productos mejor valorados – Identificación de los productos con las valoraciones (comentarios) 
--  medias más altas.

SELECT TOP 5
    articulo_comprado, 
    CAST(AVG(calificacion_del_cliente) AS DECIMAL(10,2)) AS promedio_calificacion_cliente
FROM cliente
GROUP BY articulo_comprado
ORDER BY promedio_calificacion_cliente DESC

--4. Comparación de tipos de envío – Comparación de los importes medios de compra entre envíos estándar y exprés.

SELECT 
    tipo_de_envio, 
    CAST(AVG(monto_de_comprar) AS DECIMAL(10,2)) AS promedio_importe
FROM cliente 
WHERE tipo_de_envio in ('Standard','Express')
GROUP BY tipo_de_envio

--5. Suscriptores frente a no suscriptores – 
--   Comparación del gasto medio y los ingresos totales según el estado de suscripción.

SELECT 
    estado_de_suscripcion, count(idcliente) AS total_clientes,
    CAST(AVG(monto_de_comprar) AS DECIMAL(10,2)) AS promedio_ingresos,
    CAST(SUM(monto_de_comprar) AS DECIMAL(10,2)) AS total_ingresos
FROM cliente 
GROUP BY estado_de_suscripcion
ORDER BY total_ingresos, promedio_ingresos desc 

--6. Productos con alta dependencia de descuentos 
--   Identificación de los 5 productos con mayor porcentaje de compras realizadas con descuento.

select top 5 
    articulo_comprado,
    CAST(round(100.0*sum(case when descuento_aplicado='YES' then 1 else 0 end)/count(*),2) AS DECIMAL(10,2)) as tasa_de_descuento
from cliente
group by articulo_comprado
order by tasa_de_descuento desc

-- 7.Segmentación de clientes – Clasificación de los clientes en segmentos 
--   (nuevos, recurrentes y fieles) según su historial de compras.
with tipo_cliente as (
select idcliente, compras_anteriores, 
case when compras_anteriores = 1 then 'Nuevo'
     when compras_anteriores between 2 and 10 then 'Recurrente'
     else 'Fieles'
     end as Segemento_Cliente
from cliente 
)
select Segemento_Cliente, count(*) as Numero_ce_clientes
from tipo_cliente
group by Segemento_Cliente

--8.Los 3 mejores productos por categoría – Listado de los productos más comprados en cada categoría.
WITH CUENTADEARTICULOS AS(
SELECT CATEGORIA,
       ARTICULO_COMPRADO,
	   COUNT(IDCLIENTE) AS TOTAL_DE_PEDIDOS,
	   ROW_NUMBER() OVER(PARTITION BY CATEGORIA ORDER BY COUNT(IDCLIENTE) DESC) AS RANKING_DE_PRODUCTOS
FROM CLIENTE
GROUP BY CATEGORIA,ARTICULO_COMPRADO

)
SELECT RANKING_DE_PRODUCTOS,CATEGORIA,ARTICULO_COMPRADO,TOTAL_DE_PEDIDOS
FROM CUENTADEARTICULOS
WHERE RANKING_DE_PRODUCTOS<=3

--9. Clientes recurrentes y suscripciones 
--   Análisis de si los clientes con más de 5 compras tienen mayor probabilidad de suscribirse
select estado_de_suscripcion,
       count(idcliente) as Compras_recurrentes
from cliente
where compras_anteriores>5
group by estado_de_suscripcion

