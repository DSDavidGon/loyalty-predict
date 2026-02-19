select dtRef,
        descLifeCycle,
        count(*)
from life_cycle
group by dtRef, descLifeCycle