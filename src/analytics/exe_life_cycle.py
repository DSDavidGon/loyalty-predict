# Trazendo para o python a consulta para fazer a progressão histórica do ciclo de vida dos clientes.

# %%
import pandas as pd
import sqlalchemy
from datetime import datetime, timedelta

# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query('life_cycle.sql')

# %%

engine_app = sqlalchemy.create_engine('sqlite:///../../data/loyalty-system/database.db')

engine_analytical = sqlalchemy.create_engine('sqlite:///../../data/analytics/database.db')

# %%

def dates(engine_app,data_inicial='2024-01-27',intervalo_dias=28):
    query_ultima = "SELECT max(substr(dtCriacao, 1,10)) as ultima_data FROM transacoes" 
    df_ultima = pd.read_sql(query_ultima, engine_app)
    ultima_data = df_ultima['ultima_data'].iloc[0]

    if isinstance(data_inicial, str):
        dt_inicial = datetime.strptime(data_inicial, '%Y-%m-%d')
    else:
        dt_inicial = data_inicial
        
    if isinstance(ultima_data, str):
        dt_final = datetime.strptime(ultima_data, '%Y-%m-%d')
    else:
        dt_final = ultima_data
    
    print(f"Período total: {dt_inicial.strftime('%Y-%m-%d')} até {dt_final.strftime('%Y-%m-%d')}")
    
    # Gerar lista de datas com intervalo de 28 dias
    dates = []
    data_atual = dt_inicial
    
    while data_atual <= dt_final:
        dates.append(data_atual.strftime('%Y-%m-%d'))
        data_atual += timedelta(days=intervalo_dias)
    
    return dates
print(dates)

dates = dates(engine_app, data_inicial='2024-01-27', intervalo_dias=28)

for i in dates:

    with engine_analytical.connect() as con:
        con.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE dtRef= date('{i}', '-1 day')"))
        con.commit()
    query_format = query.format(date=i)
    df = pd.read_sql(query_format,engine_app)
    df.to_sql('life_cycle', engine_analytical, index=False, if_exists='append')