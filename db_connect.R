# -------------------- PURPOSE --------------------
# create database and folder if it does not exist
# create database connection

# -------------------- PREREQUISITS/INPUTS --------------------

# Language Setting
Sys.setenv(LANG = "en")
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# libraries
# if (!require(DBI)) install.packages("DBI")
# library(DBI)
# if (!require(styler)) install.packages("styler")
# library(styler)
if (!require(RSQLite)) install.packages("RSQLite")
library(RSQLite)

# -------------------- OUTLOOK/IDEAS --------------------

# -------------------- SCRIPT --------------------

# ---------- __establish database connection ----------

if (!dir.exists("db")) { 
  dir.create("db")
  cat("Folder 'db' created in the working directory.\n")
}

db_conn <- dbConnect(
  RSQLite::SQLite(),
  dbname = file.path(getwd(), "db", "cfEngineProto.db")
)



# -------------------- database functions --------------------

# Date columns in data frames do not map to date columns in SQLite - need to be converted to
# date characger columns first, before using append = TRUE with predefined tables in SQLite db
dbWriteTableSQlite <- function(conn, name, value, ...){
  dbWriteTable(
    conn = conn,
    name = name,
    value = value %>% mutate(across(where(is.Date), as.character)),
    ...
  )}