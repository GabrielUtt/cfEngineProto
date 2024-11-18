# -------------------- PURPOSE --------------------
# apply lintr:: functions to R-files in working directory

if (!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)
if (!require(lintr)) install.packages("lintr")
library(lintr)

# name file in working directory to be linted
file <- file.path("products", "product_tables.R")

file.exists(file.path(getwd(), file))

# lint specified file
lintr::lint(
  file.path(getwd(), file)
)
