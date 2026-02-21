select idCliente,
        count(DISTINCT substr(DtCriacao,0,11)) as frequencia,
        sum(CASE WHEN QtdePontos > 0 then qtdePontos else 0 end) as valor

from transacoes
where DtCriacao < '2025-09-01'
and DtCriacao >= date('2025-09-01','-28 days') 
group by idCliente
order by frequencia DESC
