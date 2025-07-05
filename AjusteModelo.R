# 1. CONFIGURAÇÃO INICIAL
#-------------------------------------------------------------------------------
# Carrega as bibliotecas necessárias
library(AER)  # Para o conjunto de dados e testes de dispersão
library(MASS) # Para o modelo Binomial Negativo (glm.nb)
library(pscl) # Para os modelos Hurdle (hurdle)

# Carrega o conjunto de dados
data("RecreationDemand")

# Seleciona as variáveis relevantes para a modelagem
# Análise: Manteremos um conjunto fixo de preditores para comparar os modelos de forma justa.
df <- RecreationDemand[, c("trips", "quality", "ski", "userfee", "income", "costS")]

# 2. MODELO 1: POISSON (MODELO BASE)
#-------------------------------------------------------------------------------
# Análise: O modelo Poisson é o ponto de partida padrão para dados de contagem.
# Ele assume que a média e a variância da variável resposta são iguais.

mod_poisson <- glm(trips ~ quality + ski + userfee + income + costS,
                   data = df,
                   family = poisson)

# Exibe o resumo do modelo
summary(mod_poisson)

# 3. MODELO 2: BINOMIAL NEGATIVO (CORREÇÃO PARA SOBREDISPERSÃO)
#-------------------------------------------------------------------------------
# Análise: O modelo Binomial Negativo é uma alternativa direta ao Poisson
# quando há sobredispersão, pois inclui um parâmetro extra (theta) para modelar a dispersão.

mod_nb <- glm.nb(trips ~ quality + ski + userfee + income + costS,
                 data = df)

# Exibe o resumo do modelo
summary(mod_nb)
# O parâmetro 'theta' significativo confirma a presença de sobredispersão.


# 4. MODELO 3: HURDLE COM POISSON (CORREÇÃO PARA EXCESSO DE ZEROS)
#-------------------------------------------------------------------------------
# Análise: O modelo Hurdle ("obstáculo") trata os dados em duas partes:
# 1. Uma parte binária (logit) que modela se a contagem é zero ou positiva (passa o "obstáculo").
# 2. Uma parte de contagem (Poisson truncado no zero) que modela apenas os valores positivos.

mod_hurdle_pois <- hurdle(trips ~ quality + ski + userfee + income + costS,
                          data = df,
                          dist = "poisson",    # Distribuição para contagens positivas
                          zero.dist = "binomial") # Modelo para a parte zero/não-zero

# Exibe o resumo do modelo
summary(mod_hurdle_pois)


# 5. MODELO 4: HURDLE COM BINOMIAL NEGATIVO (TESTE COMBINADO)
#-------------------------------------------------------------------------------
# Análise: Para testar se é melhor, combinamos as duas abordagens: um modelo Hurdle
# para lidar com o excesso de zeros e uma distribuição Binomial Negativa para
# lidar com a sobredispersão nas contagens positivas.

mod_hurdle_nb <- hurdle(trips ~ quality + ski + userfee + income + costS,
                        data = df,
                        dist = "negbin",      # Distribuição para contagens positivas
                        zero.dist = "binomial") # Modelo para a parte zero/não-zero

# Exibe o resumo do modelo
summary(mod_hurdle_nb)


# 6. COMPARAÇÃO FINAL DOS MODELOS
#-------------------------------------------------------------------------------
# Análise: Agora vamos calcular algumas métricas para comparar o desempenho dos quatro modelos.
# Usaremos RMSE, AIC e Log-Verossimilhança.
# - RMSE: erro médio, quanto menor, melhor.
# - AIC: critério de informação, penaliza complexidade, quanto menor, melhor.
# - LogLik: log-verossimilhança, quanto maior (mais perto de zero), melhor o ajuste.

# Função para calcular o Erro Quadrático Médio da Raiz (RMSE)
rmse <- function(observado, predito) {
  sqrt(mean((observado - predito)^2))
}

# Coleta as métricas de todos os modelos
resultados <- data.frame(
  Modelo = c("Poisson",
             "Binomial Negativa",
             "Hurdle Poisson",
             "Hurdle Binomial Negativa"),
  
  AIC = c(AIC(mod_poisson),
          AIC(mod_nb),
          AIC(mod_hurdle_pois),
          AIC(mod_hurdle_nb)),
  
  LogLik = c(as.numeric(logLik(mod_poisson)),
             as.numeric(logLik(mod_nb)),
             as.numeric(logLik(mod_hurdle_pois)),
             as.numeric(logLik(mod_hurdle_nb))),
  
  RMSE = c(rmse(df$trips, fitted(mod_poisson)),
           rmse(df$trips, fitted(mod_nb)),
           rmse(df$trips, fitted(mod_hurdle_pois)),
           rmse(df$trips, fitted(mod_hurdle_nb)))
)

# Exibe a tabela de resultados ordenada pelo AIC (do melhor para o pior)
print("Tabela Comparativa de Modelos:")
print(resultados[order(resultados$AIC), ])

# A tabela final permite uma comparação clara, mostrando que modelos mais complexos
# (Hurdle e Binomial Negativo) forneceram um ajuste significativamente melhor que o Poisson simples.