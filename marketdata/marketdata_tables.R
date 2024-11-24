# -------------------- PURPOSE --------------------

# set up marketdata tables

# -------------------- OUTLOOK/IDEAS --------------------

# also add description for columns via SQL Code?

# -------------------- PREREQUISITS/INPUTS --------------------

# settings
Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# libraries
# if (!require(tidyverse)) install.packages("tidyverse")
# library(tidyverse)
# if (!require(lubridate)) install.packages("lubridate")
# library(lubridate)

# database connection / dbconn
if (!exists("db_conn")) {
  source("db_connect.R")
}

# parameters:
# - ref_dt
# if (!exists("ref_dt")) ref_dt <- today() # UTC default - need to set time zone?

# -------------------- SCRIPT --------------------

# -------------------- table t_rategroup --------------------

# - rategroup_id: (maximum) 2-letter code for rategroup, PK
# - rategroup_name: name of rategroup in snake case
# - 3 letter code (either 'rel' or 'abs') for (relative vs. absolute) differencing of time series
# - rategroup_desc: free text field

# schema_table_name <- f_name_table(table = "t_rategroup", schema = "mktdat") # list

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


# Close db connection
# DBI::dbDisconnect() # Generates error message, unable to find inherited method...???
