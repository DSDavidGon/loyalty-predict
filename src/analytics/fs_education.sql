with tb_usuario_cursos as (

    SELECT idUsuario,
            descSlugCurso,
            count(descSlugCursoEpisodio) as qtdEps

    FROM cursos_episodios_completos
    WHERE dtCriacao < '2026-02-09'
    GROUP BY idUsuario, descSlugCurso
),

tb_cursos_total_eps as (

    SELECT descSlugCurso,
            count(descEpisodio) as qtdTotalEps
    FROM cursos_episodios

    GROUP BY descSlugCurso
),

tb_pct_cursos as (
    SELECT t1.idUsuario,
            t1.descSlugCurso,
            1. * t1.qtdEps/t2.qtdTotalEps as pctCurso

    FROM tb_usuario_cursos as t1

    LEFT JOIN tb_cursos_total_eps as t2
    on t1.descSlugCurso=t2.descSlugCurso
),

--Pivota os cursos por usuario, mostrando cursos completos e incompletos
tb_pct_cursos_pivot as (

    SELECT idUsuario, 

            sum(case when pctCurso=1 then 1 else 0 end) as qtdCursosCompletos,
            sum(case when pctCurso > 0 and pctCurso < 1 then 1 else 0 end) as qtdCursosIncompletos, 

            sum(case when descSlugCurso='carreira' then pctCurso else 0 end) as carreira,
            sum(case when descSlugCurso='coleta-dados-2024' then pctCurso else 0 end) as coletaDados2024,
            sum(case when descSlugCurso='data-platform-2025' then pctCurso else 0 end) as dataPlatform2025,
            sum(case when descSlugCurso='ds-databricks-2024' then pctCurso else 0 end) as dsDatabricks2024,
            sum(case when descSlugCurso='ds-pontos-2024' then pctCurso else 0 end) as dsPontos2024,
            sum(case when descSlugCurso='estatistica-2024' then pctCurso else 0 end) as estatistica2024,
            sum(case when descSlugCurso='estatistica-2025' then pctCurso else 0 end) as estatistica2025,
            sum(case when descSlugCurso='github-2024' then pctCurso else 0 end) as github2024,
            sum(case when descSlugCurso='github-2025' then pctCurso else 0 end) as github2025,
            sum(case when descSlugCurso='go-2026' then pctCurso else 0 end) as go2026,
            sum(case when descSlugCurso='ia-canal-2025' then pctCurso else 0 end) as iaCanal2025,
            sum(case when descSlugCurso='lago-mago-2024' then pctCurso else 0 end) as lagoMago2024,
            sum(case when descSlugCurso='loyalty-predict-2025' then pctCurso else 0 end) as loyaltyPredict2025,
            sum(case when descSlugCurso='machine-learning-2025' then pctCurso else 0 end) as machineLearning2025,
            sum(case when descSlugCurso='matchmaking-trampar-de-casa-2024' then pctCurso else 0 end) as matchmakingTramparDeCasa2024,
            sum(case when descSlugCurso='ml-2024' then pctCurso else 0 end) as ml2024,
            sum(case when descSlugCurso='mlflow-2025' then pctCurso else 0 end) as mlflow2025,
            sum(case when descSlugCurso='nekt-2025' then pctCurso else 0 end) as nekt2025,
            sum(case when descSlugCurso='pandas-2024' then pctCurso else 0 end) as pandas2024,
            sum(case when descSlugCurso='pandas-2025' then pctCurso else 0 end) as pandas2025,
            sum(case when descSlugCurso='python-2024' then pctCurso else 0 end) as python2024,
            sum(case when descSlugCurso='python-2025' then pctCurso else 0 end) as python2025,
            sum(case when descSlugCurso='speed-f1' then pctCurso else 0 end) as speedF1,
            sum(case when descSlugCurso='sql-2020' then pctCurso else 0 end) as sql2020,
            sum(case when descSlugCurso='sql-2025' then pctCurso else 0 end) as sql2025,
            sum(case when descSlugCurso='streamlit-2025' then pctCurso else 0 end) as streamlit2025,
            sum(case when descSlugCurso='trampar-lakehouse-2024' then pctCurso else 0 end) as tramparLakehouse2024,
            sum(case when descSlugCurso='tse-analytics-2024' then pctCurso else 0 end) as tseAnalytics2024

    FROM tb_pct_cursos

    GROUP BY idUsuario
),

--Mostra ultima atividade (recompensa, habilidade, episódio) de cada usuário
tb_atividade as (
        SELECT 
            idUsuario,
            max(dtRecompensa) as dtCriacao

        FROM recompensas_usuarios
        WHERE dtRecompensa < '2026-02-09'
        GROUP BY idUsuario

    UNION ALL

        SELECT
            idUsuario,
            max(dtCriacao) as dtCriacao

        FROM habilidades_usuarios
        WHERE dtCriacao < '2026-02-09'
        GROUP BY idUsuario

    UNION ALL

        SELECT
            idUsuario,
            max(dtCriacao) as dtCriacao

        FROM cursos_episodios_completos
        WHERE dtCriacao < '2026-02-09'
        group by idUsuario
),

tb_ultima_atv as (

    SELECT idUsuario,
            min(julianday('2026-02-09')-julianday(dtCriacao)) as diasUltAtv
    FROM tb_atividade
    group by idUsuario
),

--Consulta ajustada a tabela usuarios_tmw para padronizar com db transacoes
    tb_join as (
    SELECT  t3.idTMWCliente,
            t1.qtdCursosCompletos,
            t1.qtdCursosIncompletos,
            t1.carreira,
            t1.coletaDados2024,
            t1.dataPlatform2025,
            t1.dsDatabricks2024,
            t1.dsPontos2024,
            t1.estatistica2024,
            t1.estatistica2025,
            t1.github2024,
            t1.github2025,
            t1.go2026,
            t1.iaCanal2025,
            t1.lagoMago2024,
            t1.loyaltyPredict2025,
            t1.machineLearning2025,
            t1.matchmakingTramparDeCasa2024,
            t1.ml2024,
            t1.mlflow2025,
            t1.nekt2025,
            t1.pandas2024,
            t1.pandas2025,
            t1.python2024,
            t1.python2025,
            t1.speedF1,
            t1.sql2020,
            t1.sql2025,
            t1.streamlit2025,
            t1.tramparLakehouse2024,
            t1.tseAnalytics2024,
            t2.diasUltAtv

    from tb_pct_cursos_pivot as t1

    left join tb_ultima_atv as t2
    on t1.idUsuario=t2.idUsuario

    inner join usuarios_tmw as t3
    on t1.idUsuario = t3.idUsuario
)

SELECT date('2026-02-09','-1 day') as dtRef,
        *

FROM tb_join