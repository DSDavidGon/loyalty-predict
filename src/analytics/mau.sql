-- Monthly Active Users em janelas de 28 dias
WITH tb_daily as (

    SELECT DISTINCT
            date(substr(DtCriacao,0,11)) as dtDia,
            idCliente
    FROM transacoes
    ORDER BY dtDia
),

tb_distinct_day as (
    SELECT DISTINCT
            dtDia as dtRef
    FROM tb_daily        
)

SELECT t1.dtRef,
        count(DISTINCT idCliente) as MAU
FROM tb_distinct_day as t1
left join tb_daily as t2
on t2.dtDia <= t1.dtRef
AND julianday(t1.dtRef)-julianday(t2.dtDia)<28
GROUP BY t1.dtRef
ORDER BY t1.dtRef ASC



