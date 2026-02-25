/*
Analise do Ciclo
Curioso - Contas Recém criadas (Até 7 dias)
Fiel - Fez transações nos ultimos 7 dias e a anterior foi em menos de 14 dias
Turista - Fez transações entre 7 e 14 dias
Desencantado - Fez transações entre 15 e 28 dias
Zumbi - Ultima transação a mais de 28 dias
Reconquistado - Fez transação nos ultimos 7 dias e a anterior foi entre 15 e 28 dias
Reborn - Fez transações nos ultimos 7 dias e a anterior foi maior que 28 dias
*/

--Tabela de Dias/Cliente
with tb_daily as (
    SELECT
        DISTINCT idCliente,
        substr(dtCriacao, 1,11) as dtDia
    FROM transacoes
    WHERE dtCriacao < '2025-09-01'

),

-- Tabela de idade e recência 
tb_idade as (
    SELECT 
        idCliente,
        cast(max(julianday('2025-09-01')-julianday(dtDia)) as int) as idade, --Dias desde a primeira transação
        cast(min(julianday('2025-09-01')-julianday(dtDia)) as int) as recencia --Dias desde a ultima transação

    from tb_daily
    group by idCliente
),

-- Tabela de ativações/idCliente
tb_rn as (
    select *,
        row_number() OVER (PARTITION by idCliente order by dtDia DESC) as rnDia
    from tb_daily
),

--Tabela de Penultima Ativacao
tb_penul_atv as (
    SELECT *,
        cast(julianday('2025-09-01')-julianday(dtDia) as int) as penultimaAtivacao

    from tb_rn
    where rnDia = 2
),

tb_life_cycle as (
    SELECT t1.*,
        t2.penultimaAtivacao,
        CASE
            when idade <= 7 then 'curioso'
            when recencia <= 7 and (penultimaAtivacao - recencia) <= 14 then 'fiel'
            when recencia BETWEEN 8 and 14 then 'turista'
            when recencia BETWEEN 15 and 28 then 'desencantado'
            when recencia > 28 then 'zumbi'
            when recencia <= 7 and (penultimaAtivacao - recencia) BETWEEN 15 and 27 then 'reconquistado'
            when recencia <=7 and (penultimaAtivacao - recencia) > 27 then 'reborn'
        
        end as descLifeCycle    

    from tb_idade as t1
    left join tb_penul_atv as t2
    on t1.idCliente = t2.idCliente
    
),

tb_freq_valor as (
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

select date('2025-09-01','-1 day') as dtRef,
        t1.*,
        t2.frequencia,
        t2.valor,
        t2.cluster
from tb_life_cycle as t1

left join tb_cluster as t2
on t1.idCliente = t2.idCliente






