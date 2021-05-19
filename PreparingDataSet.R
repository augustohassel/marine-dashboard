
# First I have to download data from https://docs.google.com/document/d/1-2wzWoCh88FaVmFZtLdAJReRiUe9-6yOZcOWEMe_7VQ/edit# 

# 1. Loading basic packages -----------------------------------------------

paquetes <- list(
  "Tidyverse" = list("dplyr", "tidyr", "purrr", "lubridate", "magrittr", "vroom", "stringr", "janitor", "feather"),
  "Map" = list("geodist")
)

lapply(as.list(c(paquetes, recursive = T, use.names = F)),
       function(x) {
         library(x, character.only = T, verbose = F)
       })
rm(list = c("paquetes"))

# 2. Loading data ---------------------------------------------------------

ships <- vroom::vroom(
  file = "data/ships.csv", 
  .name_repair = ~ janitor::make_clean_names(.) %>% stringr::str_to_title()
  )

# 3. Building relevant datasets -------------------------------------------

ships_info <- ships %>%
  group_by(Ship_id) %>%
  summarise(
    across(
      .cols = c(Shipname, Flag, Length, Width, Dwt, Shiptype, Ship_type), 
      .fns = first
    )
  )

ships_distances <- ships %>%
  filter(Is_parked == 0) %>%
  nest(data = -Ship_id) %>%
  mutate(
    data = purrr::map(
      .x = data, 
      .f = function(x) {
        x %>%
          arrange(Datetime) %>%
          bind_cols(
            Distance = geodist(
              x = x %>% 
                select(Lat, Lon), 
              sequential = TRUE, 
              pad = TRUE, 
              measure = "geodesic"
              )
            ) %>%
          mutate(
            Id = row_number()
          ) %>%
          arrange(desc(Distance), desc(Datetime)) %>% 
          filter(Id == first(Id) | Id == first(Id) - 1) %>%
          select(Lat, Lon, Destination, Distance, Port, Datetime, Date, Id)
        }
    )
  ) %>%
  unnest(data)

# 4. Saving relevant datasets ---------------------------------------------

iwalk(
  .x = list("ships_info" = ships_info, "ships_distances" = ships_distances), 
  .f = ~ write_feather(
    x = .x, 
    path = glue::glue("app/data/{.y}.feather")
    )
  )
