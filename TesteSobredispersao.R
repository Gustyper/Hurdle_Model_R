# 1. CONFIGURAÇÃO INICIAL
#-------------------------------------------------------------------------------
# Carrega as bibliotecas necessárias
library(AER)
library(MASS)

# Carrega o conjunto de dados
data("RecreationDemand")

# Seleciona as variáveis de interesse para o modelo
df <- RecreationDemand[, c("trips", "quality", "ski", "userfee", "income", "costS")]


# 2. PASSO 1: AJUSTAR O MODELO POISSON PADRÃO
#-------------------------------------------------------------------------------
# O primeiro passo é ajustar o modelo Poisson, que é o modelo que queremos testar
# para a presença de sobredispersão.

mod_poisson <- glm(trips ~ quality + ski + userfee + income + costS,
                   data = df,
                   family = poisson())

# Para o teste, precisamos dos valores observados (a própria variável resposta)
# e dos valores ajustados (as médias estimadas pelo modelo).
y_obs <- df$trips
mu_hat <- fitted(mod_poisson)


# 3. PASSO 2: CONSTRUIR A VARIÁVEL DE TESTE
#-------------------------------------------------------------------------------
# A lógica do teste é criar uma variável dependente (Z) para uma regressão auxiliar.
# Esta variável é construída para testar se a variância se desvia da média.
# A fórmula é baseada na relação Var(y) = mu + alpha * f(mu).
# Se alpha = 0, temos a premissa do Poisson (Var(y) = mu). Se alpha > 0, temos sobredispersão.

Z <- ((y_obs - mu_hat)^2 - y_obs) / mu_hat


# 4. PASSO 3: EXECUTAR A REGRESSÃO AUXILIAR
#-------------------------------------------------------------------------------
# Agora, regredimos a variável Z contra os valores ajustados (mu_hat).
# Usamos um modelo sem intercepto, pois o teste avalia se o coeficiente de mu_hat
# é significativamente diferente de zero.

# lm(Z ~ 0 + mu_hat) significa "regredir Z em mu_hat sem adicionar um termo de intercepto".
sobredisp_lm <- lm(Z ~ 0 + mu_hat)


# 5. PASSO 4: INTERPRETAR O RESULTADO
#-------------------------------------------------------------------------------
# Exibimos o resumo da regressão auxiliar. O ponto de interesse é o p-valor
# (Pr(>|t|)) do coeficiente de mu_hat.

summary(sobredisp_lm)

# Análise do Resultado:
# O coeficiente estimado para mu_hat é positivo (1.6406) e o seu p-valor é 0.0327.
#
# Conclusão:
# Um p-valor baixo nos leva a rejeitar a hipótese nula de que o coeficiente é zero.
# Portanto, há evidência estatística significativa de sobredispersão no modelo Poisson.
# Isso confirma que a variância dos dados de 'trips' é maior do que a média estimada
# pelo modelo, indicando que o modelo Poisson não é o mais adequado para estes dados.