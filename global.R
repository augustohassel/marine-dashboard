
# 1. renv & Config File ---------------------------------------------------

renv::consent(provided = TRUE); renv::restore();
config <- config::get(config = "local-test", file = "config.yml")

# 2. Libraries ------------------------------------------------------------

paquetes <- list(
  "Rep" = list("renv", "config"),
  "Shiny Core" = list("shiny", "shiny.semantic"),
  "Tidyverse" = list("dplyr", "tidyr", "purrr", "lubridate", "magrittr", "vroom", "stringr", "janitor", "feather"),
  "Map" = list("leaflet", "geodist")
)

lapply(as.list(c(paquetes, recursive = T, use.names = F)),
       function(x) {
         library(x, character.only = T, verbose = F)
       })
rm(list = c("paquetes"))

# 3. Global Parameters ----------------------------------------------------

options(
  list(
    future.globals.maxSize = config$params$future_max_size,
    shiny.fullstacktrace   = config$params$fullstacktrace,
    shiny.reactlog         = config$params$shiny_reactlog,
    scipen                 = config$params$scipen
  )
)
  
Sys.setenv(TZ = config$params$TZ)

# 4. Load data ------------------------------------------------------------

walk(
  .x = list("ships_info", "ships_distances"), 
  .f = function(x) {
    feather::read_feather(
      path = glue::glue("app/data/{x}.feather")
      ) %>%
      assign(x = x, value = ., envir = .GlobalEnv)
  }
)

# 5. Modules --------------------------------------------------------------

invisible(lapply(list.files(path = "modules", full.names = T), source))
