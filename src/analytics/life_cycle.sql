/*
Analise do Ciclo
Curioso - Contas Recém criadas (Até 7 dias)
Fiel - Fez transações recente (até 7 dias) e a anterior foi em menos de 14 dias
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

),

-- Tabela de idade e recência 
tb_idade as (
    SELECT 
        idCliente,
        cast(max(julianday('now')-julianday(dtDia)) as int) as idade, --Dias desde a primeira transação
        cast(min(julianday('now')-julianday(dtDia)) as int) as recencia --Dias desde a ultima transação

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
        cast(julianday('now')-julianday(dtDia) as int) as penultimaAtivacao

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
            when recencia <= 7 and (penultimaAtivacao - recencia) BETWEEN 15 and 28 then 'reconquistado'
            when recencia <=7 and (penultimaAtivacao - recencia) > 28 then 'reborn'
        
        end as descLifeCycle    

    from tb_idade as t1
    left join tb_penul_atv as t2
    on t1.idCliente = t2.idCliente
    
)
select descLifeCycle,
        count(*)
from tb_life_cycle
group by descLifeCycle





