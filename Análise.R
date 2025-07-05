# 1. CONFIGURAÇÃO INICIAL
#-------------------------------------------------------------------------------
# Carrega a biblioteca necessária
library(AER)

# Carrega o conjunto de dados "RecreationDemand"
data("RecreationDemand")

# Exibe as primeiras linhas para uma visualização inicial dos dados
head(RecreationDemand)

# Exibe a documentação do conjunto de dados para entender as variáveis
?RecreationDemand


# 2. ANÁLISE EXPLORATÓRIA DA VARIÁVEL RESPOSTA (trips)
#-------------------------------------------------------------------------------
# O objetivo é entender a distribuição e as características da nossa variável de interesse.

# Calcula e imprime a média e a variância de 'trips'
print("Média de trips:")
mean(RecreationDemand$trips) # Resultado: 2.2431
print("Variância de trips:")
var(RecreationDemand$trips)  # Resultado: 39.59524

# A variância é muito maior que a média, um forte indicativo de sobredispersão.
# Isso sugere que modelos de contagem como Poisson podem não ser adequados sem ajustes (e.g., Binomial Negativo).

# Verifica a quantidade de observações com zero viagens, o que é comum em dados de contagem.
sum(RecreationDemand$trips == 0) # Resultado: 134 (um número significativo de zeros)

# Gera um histograma para visualizar a distribuição de 'trips'
# A alta frequência de valores baixos (especialmente o zero) e a longa cauda à direita são visíveis aqui.
hist(RecreationDemand$trips,
     breaks = 88, # Número de barras para detalhar a distribuição
     main = "Distribuição da Variável 'trips'",
     xlab = "Número de Viagens (trips)",
     ylab = "Frequência",
     col = "lightblue",
     border = "black")


# 3. ANÁLISE DAS VARIÁVEIS EXPLICATIVAS
#-------------------------------------------------------------------------------
# O objetivo é entender como as outras variáveis se relacionam com o número de viagens.

# --- 3.1 Análise das Variáveis de Custo (Multicolinearidade) ---

# Minha análise: Como os custos de C, H e S são MUITO correlacionados, vou usar só um deles para evitar multicolinearidade no modelo.
# Vamos verificar essa correlação.

# Seleciona as colunas de custo
custos <- RecreationDemand[, c("costH", "costC", "costS")]

# Calcula e exibe a matriz de correlação de Pearson
print("Matriz de Correlação entre as variáveis de custo:")
cor(custos)
# A alta correlação (próxima de 1) entre as variáveis de custo confirma a suspeita.


# --- 3.2 Relação com Variáveis Contínuas (Gráficos de Dispersão) ---

# Minha análise: Aqui vemos que temos correlação entre as variáveis. Removi outliers pra enxergar melhor e vi que todas as que dá pra ver são boas.

# Cria uma lista de variáveis explicativas numéricas para plotar
variaveis_numericas <- names(RecreationDemand)[sapply(RecreationDemand, is.numeric)]
variaveis_numericas <- variaveis_numericas[variaveis_numericas != "trips"] # Remove a própria variável 'trips'

# Remove outliers extremos apenas para a visualização, facilitando a interpretação dos gráficos
dados_limpos_viz <- subset(RecreationDemand, trips <= 35)

# Loop para criar um gráfico de dispersão para cada variável numérica vs. trips
for (var in variaveis_numericas) {
  plot(dados_limpos_viz[[var]], dados_limpos_viz$trips,
       main = paste("Viagens (trips) vs", var),
       xlab = var,
       ylab = "Número de viagens (trips)",
       pch = 1,
       col = rgb(0, 0, 1, 0.7),
       cex = 1.5,
       las = 1, # Deixa os rótulos do eixo Y na horizontal
       bty = "l") # Remove as bordas superior e direita do gráfico
  
  # Adiciona uma linha de tendência (regressão linear simples) para visualizar a relação
  abline(lm(trips ~ dados_limpos_viz[[var]], data = dados_limpos_viz), col = "red", lwd = 2)
}


# --- 3.3 Relação com Variáveis Categóricas (Binárias) ---

# Analisando se a média de viagens muda com as variáveis binárias 'ski' e 'userfee'.

# Análise da variável 'ski'
cat("\nContagem para a variável 'ski':\n")
print(table(RecreationDemand$ski))
cat("Média de trips por prática de 'ski':\n")
print(tapply(RecreationDemand$trips, RecreationDemand$ski, mean))

# Análise da variável 'userfee'
cat("\nContagem para a variável 'userfee':\n")
print(table(RecreationDemand$userfee))
cat("Média de trips por cobrança de 'userfee':\n")
print(tapply(RecreationDemand$trips, RecreationDemand$userfee, mean))

# Minha análise: A variável 'userfee' tem pouquíssimos casos positivos.
# Só tem 13 'yes' contra mais de 600 'no'. Não vale a pena manter essa variável no modelo devido ao grande desbalanceamento.

# Boxplots para comparar visualmente a distribuição de 'trips' entre os grupos
par(mfrow = c(1, 2)) # Prepara a área de plotagem para exibir 2 gráficos lado a lado

boxplot(trips ~ ski, data = RecreationDemand,
        main = "Trips por Prática de Esqui",
        ylab = "Número de Viagens", xlab = "Pratica Esqui?")

boxplot(trips ~ userfee, data = RecreationDemand,
        main = "Trips por Cobrança de Taxa",
        ylab = "Número de Viagens", xlab = "Paga Taxa?")

par(mfrow = c(1, 1)) # Retorna a área de plotagem ao normal
