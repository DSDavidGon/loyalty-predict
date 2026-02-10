# 🎯 Loyalty Predict – Previsão de Fidelização de Clientes

## 📌 Resumo Executivo
Este projeto tem como objetivo prever quais clientes possuem maior probabilidade de retornar ao canal [TeoMeWhy](twitch.tv/teomewhy).  
A análise combina exploração de dados, engenharia de atributos e modelos de machine learning para gerar insights acionáveis para estratégias de retenção e aumento do Lifetime Value (LTV).

---

## 🏢 Contexto do Negócio
Atrair novos clientes é significativamente mais caro do que reter os atuais.  
O canal já possui um sistema de pontos, premiando o cliente por participação e presença nas lives.  
Existe também a área de cursos do canal onde o cliente pontua ao vincular a conta twitch (conta usada para as lives).  
Ambas as fontes possuem dados brutos de clientes e de transações que serão utilizadas no modelo.  
Compreender quais perfis apresentam maior chance de retorno permite direcionar campanhas de marketing, benefícios e comunicações personalizadas.

---

## ❓ Problema de Negócio
- Quais clientes têm maior probabilidade de se tornarem fiéis após a primeiro contato?  
- O que está acontecendo com o engajamento dos clientes?
- Quais as métricas gerais?
- Como melhora-las?

---

## 🎯 Ações
- Métricas gerais do TMW;
- Definição do Ciclo de Vida dos usuários;
- Análise de Agrupamento dos diferentes perfís de usuários;
- Criar modelo de Machine Learning que detecte a perda ou ganho de engajamento;
- Incentivo por meio de pontos para usuários mais engajados

---

## 📂 Dataset
- [TeoMeWhy Loyalty System](https://www.kaggle.com/datasets/teocalvo/teomewhy-loyalty-system/code)
- [TeoMeWhy Education Platform](kaggle.com/datasets/teocalvo/teomewhy-education-platform)

---

## 🛠 Tecnologias Utilizadas
- Python (Pandas / Numpy / Scikit-learn / Matplotlib)
- SQL (SQLite)
- MLflow
- Jupyter Notebook

---

## 🔎 Metodologia

### 1. Métricas Gerais
- DAU: Daily Active Users
- MAU: Monthly Active Users

### 2. Análise Exploratória (EDA)
- Distribuição de compras
- Frequência
- Ticket médio
- Padrões de retorno

### 3. Engenharia de Atributos
- Criação de métricas de recorrência
- Intervalo entre compras
- Valor acumulado

### 4. Modelagem
Modelos testados:
- Regressão Logística
- Random Forest
- XGBoost (se usar)

### 5. Avaliação
Métricas analisadas:
- Acurácia
- Precisão
- Recall
- AUC

---

## 📊 Principais Insights


---

## 🤖 Performance do Modelo
| Modelo | Acurácia | Recall | AUC |
|--------|----------|--------|-----|


---

## 💡 Recomendações de Negócio
Com base nas análises, recomenda-se:


---

## 🚀 Próximos Passos
- Testar novas variáveis comportamentais
- Criar um dashboard de acompanhamento
- Realizar testes A/B com campanhas reais
- Automatizar previsões

---

## ▶️ Como Executar o Projeto

```bash
git clone https://github.com/DSDavidGon/loyalty-predict
pip install -r requirements.txt
