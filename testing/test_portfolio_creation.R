# -------------------- PURPOSE --------------------

# standard test for creating a portfolio ak positions/instruments of a bank

# -------------------- OUTLOOK/IDEAS --------------------




# -------------------- PREREQUISITS/INPUTS --------------------

Sys.setenv(LANG = "en")

# libraries
if (!require(tidyverse)) install.packages("tidyverse")

currencies <- c("EUR")

# -------------------- SCRIPT --------------------

source("db_connect.R")

# -------------------- t_current_accounts --------------------


# -------------------- t_interbank_deposits --------------------


table_name <- "prdct_t_interbank_deposits"

n_obs <- 10



test_t_interbank_deposits <- tibble(
  ctrct_id = paste0("IBDP", seq(1:n_obs)),
  nominal = round((1 + runif(n_obs) * 9), digits = 1) * 1000000,
  currency = sample(currencies, size = n_obs, replace = TRUE),
  ir_rate = c(0, -0.01, round(runif(n_obs - 2)/20, digits = 4)), # border cases 0, negative rates
  start_dt = c(today(), today() - round(runif(n_obs - 1) * 365, digits = 0)),
  maturity_dt = c(today() + 1, today() + round(runif(n_obs - 1) * 365, digits = 0)),
  customer_id = "dummy"
)

dbWriteTableSQlite(
  conn = db_conn,
  name = table_name,
  value = test_t_interbank_deposits,
  append = TRUE,
  row.names = FALSE
)

prdct_t_interbank_deposits <- dbReadTable(db_conn, "prdct_t_interbank_deposits")

rm(table_name, n_obs)

