# -------------------- PURPOSE --------------------

# standard test for population marketdata control tables
# - t_rategroup

# -------------------- OUTLOOK/IDEAS --------------------




# -------------------- PREREQUISITS/INPUTS --------------------

# settings
Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# libraries
if (!require(tidyverse)) install.packages("tidyverse")

# data
currencies <- c("EUR") # list of available/possible currencies

# database connection / dbconn
if (!exists("db_conn")) {
  source("db_connect.R")
}

# -------------------- SCRIPT --------------------

# -------------------- t_rategroup --------------------

# Create table content
assign(
  schema_table_name$full_name,
  tribble(
    ~rategroup_id, ~rategroup_name, ~differencing, ~rategroup_desc,
    "FX", "foreign_exchange_rate", "rel", "foreign exchange rates",
    "E", "equity", "rel", "equity prices, single stocks",
    "IE", "equity_index", "rel", "equity indices"
  )
)

# save data to table
dbWriteTable(
  conn = db_conn,
  name = schema_table_name$full_name,
  value = get(schema_table_name$full_name),
  append = TRUE,
  row.names = FALSE
)

rm(schema_table_name)

# -------------------- t_ratedefinition --------------------

# Code from app_R (adapt!)

# Start with list of yahoo fx quote symbols:
yahoo_quotes_fx <- "
Symbol  ,    Quote
EURUSD=X,    EUR/USD
JPY=X   ,    USD/JPY
BRL=X   ,    USD/BRL
GBPUSD=X,    GBP/USD
AUDUSD=X,    AUD/USD
NZDUSD=X,    NZD/USD
EURJPY=X,    EUR/JPY
GBPJPY=X,    GBP/JPY
EURGBP=X,    EUR/GBP
EURCAD=X,    EUR/CAD
EURSEK=X,    EUR/SEK
EURCHF=X,    EUR/CHF
EURHUF=X,    EUR/HUF
EURNOK=X,    EUR/NOK
EURTRY=X,    EUR/TRY
CNY=X   ,    USD/CNY
HKD=X   ,    USD/HKD
SGD=X   ,    USD/SGD
INR=X   ,    USD/INR
MXN=X   ,    USD/MXN
PHP=X   ,    USD/PHP
IDR=X   ,    USD/IDR
THB=X   ,    USD/THB
MYR=X   ,    USD/MYR
ZAR=X   ,    USD/ZAR
RUB=X   ,    USD/RUB
"

# create fx data for table t_ratedefinition
# - rate_id (PK): underlying + (period) + currency + (curve) + rategroup + "_" + type(bid, close,..)
# - rategroup_id (FK): see t_rategroup
# - period/period_id (FK): period table wip
# - currency: 3-letter currency code
# - source: data source, e.g. bloomberg, yahoo, ...
# - source_id: source dependent identifier for data, e.g. bloomberg ticker
t_ratedefinition_fx <- read.table(
  text = str_replace_all(yahoo_quotes_fx, fixed(" "), ""),
  sep = ",", header = TRUE
) %>%
  mutate(
    underlying = str_sub(Quote, start = 1, end = 3),
    period = "SPOT",
    currency = str_sub(Quote, start = 5, end = 7),
    rategroup_id = "FX",
    rate_id = paste0(
      underlying,
      period,
      currency,
      rategroup_id,
      "_C"
    ),
    source = "yahoo"
  ) %>%
  rename(
    source_id = Symbol
  ) %>%
  select(
    -all_of(c("Quote", "underlying")),
    rate_id, rategroup_id, period, currency, source, source_id
  )

# NOTE: later combine with ratedefinition tables for other rategroups before saving

schema_table_name <- f_name_table(table = "t_ratedefinition", schema = "mktdat") # list

assign(
  schema_table_name$full_name,
  t_ratedefinition_fx
)

# save data to table
dbWriteTable(
  conn = db_conn,
  name = schema_table_name$full_name,
  value = get(schema_table_name$full_name),
  append = TRUE,
  row.names = FALSE
)

rm(schema_table_name)
