--Daily Active Users
SELECT substr(DtCriacao,1,11) as dtDia,
        count(DISTINCT idCliente) as DAU
FROM transacoes
GROUP BY 1
order by dtDia

