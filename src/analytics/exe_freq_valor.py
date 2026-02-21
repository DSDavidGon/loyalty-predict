# %%

import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

from sklearn import cluster

from sklearn import preprocessing
import seaborn as sns

# %%

engine = sqlalchemy.create_engine('sqlite:///../../data/loyalty-system/database.db')

# %%

def import_query(path):
    with open(path) as open_file:
        return open_file.read()

query = import_query('freq_valor.sql')

# %%

df = pd.read_sql(query, engine)
df.head()

df = df[df['valor']<4000]

# %%

plt.plot(df['frequencia'], df['valor'],'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.show()

# %%
# Padronizar o cluster para ter valores de x e y dentro de uma escala igual (0 a 1)
minmax = preprocessing.MinMaxScaler()

X = minmax.fit_transform(df[['frequencia','valor']])

# %%

kmean = cluster.KMeans(n_clusters = 5, random_state = 42, max_iter=1000)
kmean.fit(X)

df['cluster'] = kmean.labels_

df.groupby(by='cluster')['IdCliente'].count()

# %%

sns.scatterplot(data=df,
                x='frequencia',
                y='valor',
                hue='cluster',
                palette='deep')

#Seguimentação escolhida

plt.hlines(y=1500, xmin=0,xmax=25, colors='black')
plt.hlines(y=750, xmin=0,xmax=25, colors='black')
plt.vlines(x=4, ymin=0,ymax=750, colors='black')
plt.vlines(x=10, ymin=0,ymax=3000, colors='black')

plt.grid