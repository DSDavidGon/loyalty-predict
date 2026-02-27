# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection
import matplotlib.pyplot as plt
import seaborn as sns
from feature_engine import selection
from feature_engine import imputation
from feature_engine import encoding


# %%
#SAMPLE - IMPORT DOS DADOS

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

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

missing_df = pd.DataFrame({
    'coluna': X_train.columns,
    'missing_count': X_train.isnull().sum().values,
    'missing_percent': (X_train.isnull().sum() / len(X_train) * 100).values
})
missing_df = missing_df[missing_df['missing_count'] > 0].sort_values('missing_percent', ascending=False)

print(missing_df)

plt.figure(figsize=(12, 6))
sns.barplot(data=missing_df, x='coluna', y='missing_percent')
plt.xticks(rotation=45, ha='right')
plt.title('Percentual de Missing Values por Coluna')
plt.ylabel('Percentual Missing (%)')
plt.tight_layout()
plt.show()

# %%
#EXPLORE - Analises Descritivas

cat_features = ['descLifeCycleAtual','descLifeCycleD28']

num_features = list(set(features)-set(cat_features))

print("\n📊 Variáveis Numéricas:")
print(num_features)

print("\n📊 Variáveis Categóricas:")
print(cat_features)

print("\n📊 Informações do Dataset:")
print(f"Shape: {df.shape}")
print(f"Tipos de dados:\n{df.dtypes.value_counts()}")

# %%
# EXPLORE - Analise da variável Target

# Distribuição da target
print(f"\nDistribuição da target '{target}':")
print(df_train[target].value_counts())
print(f"Percentual:\n{df_train[target].value_counts(normalize=True) * 100}")

# Visualização
fig, axes = plt.subplots(1, 2, figsize=(12, 4))

# Gráfico de barras
df_train[target].value_counts().plot(kind='bar', ax=axes[0])
axes[0].set_title('Distribuição da Target (Contagem)')
axes[0].set_xlabel(target)

# Pizza
df_train[target].value_counts().plot(kind='pie', ax=axes[1], autopct='%1.1f%%')
axes[1].set_title('Distribuição da Target (%)')
axes[1].set_ylabel('')

plt.tight_layout()
plt.show()

# %%
#EXPLORE - Analise bivariada

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features]=df_train[num_features].astype(float)

bivariada_num = df_train.groupby(target)[num_features].mean().T
bivariada_num['ratio']=(bivariada_num[1] + 0.001 )/(bivariada_num[0] + 0.001)
bivariada_num.sort_values(by='ratio',ascending = False)

# %%
#Média por categoria de fiéis atuais
df_train.groupby('descLifeCycleAtual')[target].mean()

# %%
#Média por categoria de fiéis em D28
df_train.groupby('descLifeCycleD28')[target].mean()

# %%
#MODIFY - Drops

X_train[num_features]=X_train[num_features].astype(float)

to_remove = bivariada_num[bivariada_num['ratio']<1].index.tolist()

drop_features = selection.DropFeatures(to_remove)

X_train_transform=drop_features.fit_transform(X_train)
missing_df = X_train_transform.isna().mean()

# %%
#MODIFY - MISSING

fill_0 = missing_df[missing_df>=0.9].index.tolist()

imput_0 = imputation.ArbitraryNumberImputer(
    arbitrary_number=0,
    variables=fill_0)

imput_new = imputation.CategoricalImputer(
    fill_value='Nao-Usuario',
    variables=['descLifeCycleD28'])



X_train_transform = imput_0.fit_transform(X_train_transform)
X_train_transform = imput_new.fit_transform(X_train_transform)

X_train_transform
# %%
missing_df = X_train_transform.isna().mean()
missing_df[missing_df>0]

# %%
#MODIFY - ONEHOT

onehot = encoding.OneHotEncoder(variables=cat_features)

X_train_transform=onehot.fit_transform(X_train_transform)
X_train_transform