SELECT idCliente,
        dtRef, 
        descLifeCycle 
FROM life_cycle 
where descLifeCycle <> 'zumbi'
and dtRef = (select DISTINCT max(dtRef) from life_cycle)
group by dtRef, descLifeCycle
order by dtRef, descLifeCycle