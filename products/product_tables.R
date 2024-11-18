# -------------------- PURPOSE --------------------

# set up data structure for product data base by creating empty tables for various products


# -------------------- OUTLOOK/IDEAS --------------------



# -------------------- PREREQUISITS/INPUTS --------------------

Sys.setenv(LANG = "en")

# libraries
# if (!require(tidyverse)) install.packages("tidyverse")
# library(tidyverse)
# if (!require(lubridate)) install.packages("lubridate")
# library(lubridate)
# if (!require(timeDate)) install.packages("timeDate")
# library(timeDate)

# functions
# source("functions.R")

# database connection / dbconn

source("db_connect.R")

# parameters:

# -------------------- SCRIPT --------------------

# -------------------- t_current_accounts --------------------

# type: position
# description: simple cash balance without interest payment

table_name <- "prdct_t_current_accounts"

# Either truncate existing table or create new empty table
if (dbExistsTable(
  conn = db_conn,
  name = table_name
)) {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
  ))
} else {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("CREATE TABLE ", table_name, " (
      account_id text NOT NULL,
      balance numeric NOT NULL,
      currency varchar(3) NOT NULL,
      start_dt date NOT NULL,
      customer_id text NOT NULL,
      CONSTRAINT ", table_name, "_pkey PRIMARY KEY (account_id)
    );")
  ))
}

rm(table_name)

# -------------------- t_interbank_deposit --------------------

# type: contract
# description: single interest payment, fixed

table_name <- "prdct_t_interbank_deposits"

# Either truncate existing table or create new empty table
if (dbExistsTable(
  conn = db_conn,
  name = table_name
)) {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
  ))
} else {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("CREATE TABLE ", table_name, " (
      ctrct_id text NOT NULL,
      nominal numeric NOT NULL,
      currency varchar(3) NOT NULL,
      ir_rate numeric NOT NULL,
      start_dt date NOT NULL,
      maturity_dt date NOT NULL,
      customer_id text NOT NULL,
      CONSTRAINT ", table_name, "_pkey PRIMARY KEY (ctrct_id), 
      CONSTRAINT chk_ctrct_id_prefix CHECK (ctrct_id LIKE 'IBDP%'),
      CONSTRAINT chk_maturity_after_start CHECK (maturity_dt > start_dt)
    );")
  ))
}

rm(table_name)


# -------------------- t_time_deposits --------------------


# type: contract
# description: single or multiple interest payments, fixed or floating

# unfinished - multiple periods for introduction of floating rates required

table_name <- "prdct_t_time_deposits"

# Either truncate existing table or create new empty table
if (dbExistsTable(
  conn = db_conn,
  name = table_name
)) {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("DELETE FROM ", table_name, ";") # no TRUNCATE for SQLite
  ))
} else {
  dbClearResult(dbSendQuery(
    db_conn,
    paste0("CREATE TABLE ", table_name, " (
      ctrct_id text NOT NULL,
      nominal numeric NOT NULL,
      currency varchar(3) NOT NULL,
      ir_rate_type text NOT NULL,
      ir_rate numeric NOT NULL,
      ref_ir_rate text,
      start_dt date NOT NULL,
      maturity_dt date NOT NULL,
      customer_id text NOT NULL,
      CONSTRAINT ", table_name, "_pkey PRIMARY KEY (ctrct_id)
    );")
  ))
}

rm(table_name)

