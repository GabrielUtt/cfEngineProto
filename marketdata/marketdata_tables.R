# -------------------- PURPOSE --------------------

# set up marketdata tables

# -------------------- OUTLOOK/IDEAS/TDs --------------------

# TD:
# Check Whether truncate/delete works for SQLite table with FK

# also add description for columns via SQL Code?
# put table exist check and delete in function? Or just drop tables everytime before rewriting the here
# Code: DROP TABLE IF EXISTS 'table_name'

# -------------------- PREREQUISITS/INPUTS --------------------

# clean environment
rm(list = ls())

# settings
Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# libraries

# database connection / dbconn
if (!exists("db_conn")) {
  source("db_connect.R")
}

# parameters:

# -------------------- SCRIPT --------------------

# -------------------- table t_rategroup --------------------

# contains information about rategroups, i.e. groups of market data with specific common properties, like
# FX data, equity data, interest rate data, etc.

table_name <- "mktdat_t_rategroup"

# NOTE: Table cannot be truncated if rategroup_id is foreign key to other tables!

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
      rategroup_id varchar(2) NOT NULL,
      rategroup_name text NOT NULL,
      differencing varchar(3) NOT NULL,
      rategroup_desc text NULL,
      CONSTRAINT pkey_", table_name, " PRIMARY KEY (rategroup_id),
      CONSTRAINT chk_", table_name, "_differencing CHECK (differencing IN ('abs', 'rel'))
    );")
  ))
}

rm(table_name)


# -------------------- table t_ratedefinition --------------------

table_name <- "mktdat_t_ratedefinition"

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
    paste0("CREATE TABLE ", table_name, ' (
      rate_id text NOT NULL,
      rategroup_id varchar(2) NOT NULL,
      "period" text NOT NULL,
      currency varchar(3) NOT NULL,
      "source" text NULL,
      source_id text NULL,
      CONSTRAINT pkey_', table_name, " PRIMARY KEY (rate_id)
    );")
  ))
}

rm(table_name)

# -------------------- table t_marketdata_ts --------------------

table_name <- "mktdat_t_marketdata_ts"

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
      rate_date date NOT NULL,
      rate_id text NOT NULL,
      rate_value numeric NOT NULL,
      CONSTRAINT pkey_", table_name, " PRIMARY KEY (rate_date, rate_id)
    )")
  )) # WITH (autovacuum_enabled=true) ?
}

rm(table_name)
