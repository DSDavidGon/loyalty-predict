select dtRef,
        descLifeCycle,
        cluster,
        count(*) as qtdCliente

from life_cycle
where descLifeCycle <> 'zumbi'

group by dtRef, descLifeCycle, cluster
order by dtRef, descLifeCycle, cluster


