# -------------------- PURPOSE --------------------

# standard test for population marketdata tables
# - t_rategroup
# - t_ratedefinition
# - t_marketdata_ts

# -------------------- OUTLOOK/IDEAS --------------------




# -------------------- PREREQUISITS/INPUTS --------------------

# clean environment
rm(list = ls())

# settings
Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# libraries
if (!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)
if (!require(lubridate)) install.packages("lubridate")
library(lubridate)

# database connection / dbconn
if (!exists("db_conn")) {
  source("db_connect.R")
}

# parameters
periods <- c("1D", "7D", "1M", "3M", "6M", "1Y", "2Y", "5Y", "10Y", "30Y") # provide via single source later

report_dt <- today() - 1 - max(wday(today() - 1, week_start = 1) - 5, 0) # last past non-weekend day


# -------------------- SCRIPT --------------------

# -------------------- t_rategroup --------------------

table_name <- "mktdat_t_rategroup"

# Create test content
assign(
  table_name,
  tribble(
    ~rategroup_id, ~rategroup_name, ~differencing, ~rategroup_desc,
    "FX", "foreign_exchange_rate", "rel", "foreign exchange rates",
    "E", "equity", "rel", "equity prices, single stocks",
    "IE", "equity_index", "rel", "equity indices",
    "IR", "interest_rate", "abs", "interest rates"
  )
)

# clear table
dbClearResult(dbSendQuery(
  db_conn,
  paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
))

# save data to table
dbWriteTable(
  conn = db_conn,
  name = table_name,
  value = get(table_name),
  overwrite = FALSE,
  append = TRUE,
  row.names = FALSE
)

rm(list = c(table_name, "table_name"))

# -------------------- t_ratedefinition --------------------

# create IR data for table t_ratedefinition

table_name <- "mktdat_t_ratedefinition"

# Create table content
assign(
  table_name,
  tibble(
    rategroup_id = "IR",
    period = periods,
    currency = "EUR",
    source = "dummy"
  ) %>%
    mutate(
      rate_id = paste0(currency, period, "_", rategroup_id),
      source_id = paste0(source, "_", rate_id)
    )
)

# clear table
dbClearResult(dbSendQuery(
  db_conn,
  paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
))

# save data to table
dbWriteTable(
  conn = db_conn,
  name = table_name,
  value = get(table_name),
  append = TRUE,
  row.names = FALSE
)

ir_rate_ids <- mktdat_t_ratedefinition$rate_id
rm(list = c(table_name, "table_name"))

# -------------------- t_marketdata --------------------
# add IR data

# create IR data for table t_ratedefinition

table_name <- "mktdat_t_marketdata_ts"

# Create table content
assign(
  table_name,
  tibble(
    rate_date = report_dt,
    rate_id = ir_rate_ids,
    rate_value = seq(from = 0.03, by = 0.002, length.out = length(ir_rate_ids))
  ) %>% mutate(across(where(is.Date), as.character))
)

# clear table
dbClearResult(dbSendQuery(
  db_conn,
  paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
))

# save data to table
dbWriteTable(
  conn = db_conn,
  name = table_name,
  value = get(table_name),
  append = TRUE,
  row.names = FALSE
)

rm(ir_rate_ids)
rm(list = c(table_name, "table_name"))
