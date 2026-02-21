with tb_freq_valor as (
        select idCliente,
        count(DISTINCT substr(DtCriacao,0,11)) as frequencia,
        sum(CASE WHEN QtdePontos > 0 then qtdePontos else 0 end) as valor
--Decisão de considerar apenas pontos positivos pq os pontos gastos já foram ganhos em algum periodo histórico anterior
        from transacoes
        where DtCriacao < '2025-09-01'
        and DtCriacao >= date('2025-09-01','-28 days') 
        group by idCliente
        order by frequencia DESC
),

tb_cluster as (
        select *,
                CASE
                        WHEN frequencia <= 10 and valor >= 1500 then '12-hyper'
                        WHEN frequencia > 10 and valor >= 1500 then '22-eficiente'
                        WHEN frequencia <= 10 and valor >= 750 then '11-indeciso'
                        WHEN frequencia > 10 and valor >= 750 then '21-esforçado'
                        WHEN frequencia < 5 then '00-lucker'
                        WHEN frequencia <= 10 then '01-preguiçoso'
                        WHEN frequencia > 10 then '20-potencial'
                end as cluster

        from tb_freq_valor
)

SELECT *

from tb_cluster

 
