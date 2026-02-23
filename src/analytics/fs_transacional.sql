--Features Transacionais

with tb_transacao as (
    select *,
            substr(DtCriacao,0,11) as dtDia,
            cast(substr(dtCriacao, 12,2)as int) as dtHora

    from transacoes

    where DtCriacao < '2026-02-09'

),

--Idade na base, Agregações de frequencia, pontos e segmentação de iterações relativas

tb_agg_transacao as (
    SELECT IdCliente,

        max(julianday(date('2026-02-09','-1 day'))-julianday(DtCriacao)) as idadeDias,
        
        count(DISTINCT dtDia) as freqAtvVida,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-7 day') then dtDia end) as freqAtvD7,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-14 day') then dtDia end) as freqAtvD14,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-28 day') then dtDia end) as freqAtvD28,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-56 day') then dtDia end) as freqAtvD56,

        count(DISTINCT IdTransacao) as freqTransVida,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-7 day') then IdTransacao end) as freqTransD7,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-14 day') then IdTransacao end) as freqTransD14,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-28 day') then IdTransacao end) as freqTransD28,
        count(DISTINCT case when dtDia >= date('2025-02-09', '-56 day') then IdTransacao end) as freqTransD56,

        sum(qtdePontos) as saldo,
        sum(case when dtDia >= date('2025-02-09', '-7 day') then qtdePontos else 0 end) as saldoD7,
        sum(case when dtDia >= date('2025-02-09', '-14 day') then qtdePontos else 0 end) as saldoD14,
        sum(case when dtDia >= date('2025-02-09', '-28 day') then qtdePontos else 0 end) as saldoD28,
        sum(case when dtDia >= date('2025-02-09', '-56 day') then qtdePontos else 0 end) as saldoD56,

        sum(case when qtdePontos > 0 then qtdePontos else 0 end) as ptsPosVida,
        sum(case when dtDia >= date('2025-02-09', '-7 day') and qtdePontos > 0 then qtdePontos else 0 end) as ptsPosD7,
        sum(case when dtDia >= date('2025-02-09', '-14 day') and qtdePontos > 0 then qtdePontos else 0 end) as ptsPosD14,
        sum(case when dtDia >= date('2025-02-09', '-28 day') and qtdePontos > 0 then qtdePontos else 0 end) as ptsPosD28,
        sum(case when dtDia >= date('2025-02-09', '-56 day') and qtdePontos > 0 then qtdePontos else 0 end) as ptsPosD56,

        sum(case when qtdePontos < 0 then qtdePontos else 0 end) as ptsNegVida,
        sum(case when dtDia >= date('2025-02-09', '-7 day') and qtdePontos < 0 then qtdePontos else 0 end) as ptsNegD7,
        sum(case when dtDia >= date('2025-02-09', '-14 day') and qtdePontos < 0 then qtdePontos else 0 end) as ptsNegD14,
        sum(case when dtDia >= date('2025-02-09', '-28 day') and qtdePontos < 0 then qtdePontos else 0 end) as ptsNegD28,
        sum(case when dtDia >= date('2025-02-09', '-56 day') and qtdePontos < 0 then qtdePontos else 0 end) as ptsNegD56,


        1. * count(case when dtHora BETWEEN 10 and 14 then IdTransacao end) / count(IdTransacao) as pctTransManha,
        1. * count(case when dtHora BETWEEN 15 and 20 then IdTransacao end) / count(IdTransacao) as pctTransTarde,
        1. * count(case when dtHora > 20 or dtHora < 10 then IdTransacao end) / count(IdTransacao) as pctTransNoite
    FROM tb_transacao

    GROUP BY idCliente

),

--Agregação de Transação/Frequência e Ativação/MAU

tb_agg_calc as (

    select *,
            coalesce(1. * freqTransVida/freqAtvVida, 0) as transDiaVida,
            coalesce(1. * freqTransD7/freqAtvD7, 0) as transDiaD7,
            coalesce(1. * freqTransD14/freqAtvD14, 0) as transDiaD14,
            coalesce(1. * freqTransD28/freqAtvD28, 0) as transDiaD28,
            coalesce(1. * freqTransD56/freqAtvD56, 0) as transDiaD56,
            coalesce(1. * freqAtvD28/28 , 0) as pctAtvMAU

    FROM tb_agg_transacao        
),

--Duração em horas de Clientes/Dia

tb_horas_dia as (
    SELECT idCliente,
        dtDia,
        24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) as duracao

    FROM tb_transacao

    GROUP BY idCliente, dtDia
),

--Agregação de duração de cliente/dia

tb_hora_cliente as (

    SELECT idCliente,
            sum(duracao) as qtdHorasVida,
            sum( case when dtDia >= date('2025-02-09', '-7 day') then duracao else 0 end) as qtdHorasD7,
            sum( case when dtDia >= date('2025-02-09', '-14 day') then duracao else 0 end) as qtdHorasD14,
            sum( case when dtDia >= date('2025-02-09', '-28 day') then duracao else 0 end) as qtdHorasD28,
            sum( case when dtDia >= date('2025-02-09', '-56 day') then duracao else 0 end) as qtdHorasD56

    FROM tb_horas_dia

    GROUP BY idCliente
),

tb_lag_dia as (
    SELECT idCliente,
            dtDia,
            LAG(dtDia) over (PARTITION BY idCliente order by dtDia) as lagDia

    FROM tb_horas_dia
),

--Média do intervalo de dias que o cliente ativa

tb_intervalo as (

    SELECT *,
            avg(julianday(dtDia) - julianday(lagDia)) as avgIntervaloVida,
            avg(case when dtDia >= date('2025-02-09' , '-28 day') then julianday(dtDia)-julianday(lagDia) end) as avgIntervaloD28

    from tb_lag_dia

    GROUP BY idCliente
),

--Share de Produtos Relativo

tb_share_produto as (

SELECT  idCliente,
        t3.DescNomeProduto,
        t3.DescCategoriaProduto,

        1. * count(case when DescNomeProduto='ChatMessage' then t1.IdTransacao end)/count(t1.IdTransacao) as pctChatMessage,
        1. * count(case when DescNomeProduto='Airflow Lover' then t1.IdTransacao end)/count(t1.IdTransacao) as pctAirFlowLover,
        1. * count(case when DescNomeProduto='R Lover' then t1.IdTransacao end)/count(t1.IdTransacao) as pctRLover,
        1. * count(case when DescNomeProduto='Resgatar Ponei' then t1.IdTransacao end)/count(t1.IdTransacao) as pctResgatarPonei,
        1. * count(case when DescNomeProduto='Lista de presença' then t1.IdTransacao end)/count(t1.IdTransacao) as pctListaPresenca,
        1. * count(case when DescNomeProduto='Presença Streak' then t1.IdTransacao end)/count(t1.IdTransacao) as pctPresencaStreak,
        1. * count(case when DescNomeProduto='Troca de Pontos StreamElements' then t1.IdTransacao end)/count(t1.IdTransacao) as pctTrocaPontosStreamElements,
        1. * count(case when DescNomeProduto='Reembolso: Troca de Pontos StreamElements' then t1.IdTransacao end)/count(t1.IdTransacao) as pctReembolsoPontosStreamElements,
        1. * count(case when DescCategoriaProduto='rpg' then t1.IdTransacao end)/count(t1.IdTransacao) as pctRPG,
        1. * count(case when DescCategoriaProduto='chrun_model' then t1.IdTransacao end)/count(t1.IdTransacao) as pctChurnModel
FROM tb_transacao as t1

LEFT JOIN transacao_produto as t2
on t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos as t3
on t2.IdProduto= t3.IdProduto

GROUP BY idCliente

),

tb_join as (

    select t1.* ,
            t2.qtdHorasVida,
            t2.qtdHorasD7,
            t2.qtdHorasD14,
            t2.qtdHorasD28,
            t2.qtdHorasD56,

            t3.avgIntervaloVida,
            t3.avgIntervaloD28,

            t4.pctChatMessage,
            t4.pctAirFlowLover,
            t4.pctRLover,
            t4.pctResgatarPonei,
            t4.pctListaPresenca,
            t4.pctPresencaStreak,
            t4.pctTrocaPontosStreamElements,
            t4.pctReembolsoPontosStreamElements,
            t4.pctRPG,
            t4.pctChurnModel

    from tb_agg_calc as t1

    LEFT JOIN tb_hora_cliente as t2
    on t1.idCliente = t2.idCliente

    LEFT JOIN tb_intervalo as t3
    on t1.idCliente = t3.idCliente

    LEFT JOIN tb_share_produto as t4
    on t1.idCliente = t4.idCliente
)

select date('2026-02-09','-1 day') as dtRef,
        * 

from tb_join
