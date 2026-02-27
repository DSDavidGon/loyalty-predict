# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%
#SAMPLE - IMPORT DOS DADOS

df = pd.read_sql('abt_fiel',con)

df.head()

# %%
#SAMPLE - OOT - Out Of Time

df_oot = df[df['dtRef']==df['dtRef'].max()].reset_index(drop=True)

df_oot

# %%
#SAMPLE - TREINO E TESTE

target = 'flFiel'
features = df.columns.to_list()[3:]

df_train_test = df[df['dtRef']<df['dtRef'].max()].reset_index(drop=True)
df_train_test

X = df_train_test[features]
y = df_train_test[target]

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print(f"Base Treino: {y_train.shape[0]} Unid. | Target {100*y_train.mean():.2f}%")
print(f"Base Teste: {y_test.shape[0]} Unid. | Target {100*y_test.mean():.2f}%")

# %%
#EXPLORE - Missing

s_na=X_train.isna().mean()

s_na = s_na[s_na>0]
s_na

# %%
#EXPLORE - Analise bivariada

cat_features = ['descLifeCycleAtual','descLifeCycleD28']
num_features = list(set(features)-set(cat_features))
num_features

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features]=df_train[num_features].astype(float)
bivariada_num = df_train.groupby(target)[num_features].mean().T
bivariada_num['ratio']=(bivariada_num[1] + 0.001 )/(bivariada_num[0] + 0.001)
bivariada_num.sort_values(by='ratio',ascending = False)

to_remove = bivariada_num[bivariada_num['ratio']==1].index.tolist()
to_remove

for i in to_remove:
    features.remove(i)
    num_features.remove(i)

# %%
df_train.groupby('descLifeCycleAtual')[target].mean()

# %%
df_train.groupby('descLifeCycleD28')[target].mean()


