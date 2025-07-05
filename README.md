# Análise de Dados de Contagem com Sobredispersão

Este repositório contém uma análise sobre a modelagem de dados de contagem, com foco no tratamento do fenômeno de **sobredispersão**. O projeto utiliza o conjunto de dados `RecreationDemand` do pacote `AER` em R para ilustrar o problema e comparar diferentes abordagens de modelagem.

## O Problema: Sobredispersão

O modelo de Regressão de Poisson é a abordagem padrão para dados de contagem. No entanto, ele se baseia na premissa de **equidispersão**, onde a média e a variância dos dados são iguais (`Var(Y) = E[Y]`).

Na prática, é comum encontrar dados onde a variância é muito maior que a média, um fenômeno chamado **sobredispersão**. Ignorar a sobredispersão pode levar a conclusões equivocadas e erros na inferência estatística.

## Metodologia Aplicada

A análise foi conduzida em quatro etapas principais:

1.  **Análise Exploratória:** Investigação inicial do dataset `RecreationDemand`. A análise da variável `trips` (número de viagens recreativas) revelou uma variância muito superior à média, um forte indicativo de sobredispersão.

2.  **Ajuste e Teste do Modelo Poisson:**
    * Um modelo Poisson foi ajustado como linha de base.
    * Foi aplicado um **teste de hipótese de Cameron & Trivedi** para confirmar formalmente a presença de sobredispersão. O resultado do teste confirmou que o modelo Poisson é inadequado.

3.  **Modelagem com Alternativas:** Para corrigir os problemas encontrados, foram ajustados modelos mais robustos:
    * **Binomial Negativo:** Um modelo que lida diretamente com a sobredispersão ao incluir um parâmetro de dispersão adicional.
    * **Modelo Hurdle (com Poisson e Binomial Negativo):** Uma abordagem de duas partes que modela separadamente a decisão de realizar (ou não) uma viagem e a quantidade de viagens (para aqueles que realizam). É especialmente útil para dados com excesso de zeros.

4.  **Comparação dos Modelos:** Os quatro modelos (Poisson, Binomial Negativo, Hurdle Poisson e Hurdle Binomial Negativo) foram comparados usando métricas de ajuste como **AIC**, **Log-Verossimilhança (LogLik)** e **RMSE**.

## Estrutura do Repositório

* `01_analise_exploratoria.R`: Script com a análise exploratória dos dados, incluindo a verificação de média vs. variância, correlações e visualizações.
* `02_comparacao_modelos.R`: Script principal que ajusta os quatro modelos de regressão (Poisson, Binomial Negativo e as duas versões do Hurdle) e os compara através de uma tabela de métricas.
* `03_teste_sobredispersao_manual.R`: Script que implementa o teste de Cameron & Trivedi passo a passo para detectar a sobredispersão.

## Estudo e Resultados

Análises, gráficos e resultados estão disponíveis no arquivo `TrabalhoSobredispersao.pdf`