function(input, output, session) {
  
  # 1. Dropdowns -----
  
  value_vessel_type <- dropdown_server(
    id = "vessel_type", 
    values = reactive(factor_ship_types)
    )
  
  factor_ship <- eventReactive(value_vessel_type(), {
    
    data <- ships_info %>%
      filter(Shiptype == value_vessel_type()) %>%
      arrange(Shipname) %>% {
        setNames(object = .$Ship_id, nm = .$Shipname)
      }
    
    return(data)
    
  }, ignoreInit = TRUE, ignoreNULL = FALSE)
  
  value_vessel <- dropdown_server(
    id = "vessel", 
    values = factor_ship
    )
  
  # 2. Map -----
  
  data_ship_distance <- eventReactive(value_vessel(), {
    
    data <- ships_distances %>% 
      filter(Ship_id == value_vessel())
      
    return(data)
    
  }, ignoreInit = TRUE)
  
  output$map <- renderLeaflet({
    leaflet(height = "100vh") %>% 
      addProviderTiles(providers$CartoDB.Positron)
  })
  
  observeEvent(data_ship_distance(), {
    
    req(nrow(data_ship_distance()) > 0)
    
    leafletProxy(
      mapId = "map"
      ) %>%
      clearMarkers() %>%
      addAwesomeMarkers(
        data = data_ship_distance() %>% slice(1), 
        lng = ~Lon, 
        lat = ~Lat, 
        icon = awesomeIcons(
          icon = "stop", 
          iconColor = "red",
          library = "fa",
          markerColor = "white"
          )
        ) %>%
      addAwesomeMarkers(
        data = data_ship_distance() %>% slice(2), 
        lng = ~Lon, 
        lat = ~Lat, icon = awesomeIcons(
          icon = "play", 
          iconColor = "green",
          library = "fa",
          markerColor = "white"
        )
      ) %>%
      flyTo(
        lng = data_ship_distance()$Lon[[1]], 
        lat = data_ship_distance()$Lat[[1]], 
        zoom = 12
        )
    
  }, ignoreInit = FALSE, ignoreNULL = TRUE)
  
  # 3. Extra info -----
  
  output$card_ship_name <- renderText({
    if (nrow(data_ship_distance()) > 0) {
      ships_info %>%
        filter(Ship_id == value_vessel()) %>%
        pull(Shipname) %>%
        unique()
    } else {
      "-"
    }
    
  })
  
  output$card_ship_flag <- renderText({
    if (nrow(data_ship_distance()) > 0) {
      ships_info %>%
        filter(Ship_id == value_vessel()) %>%
        pull(Flag) %>% {
          glue::glue("Flag: {.}")
        }
    } else {
      "-"
    }
    
  })
  
  output$card_ship_date <- renderText({
    if (nrow(data_ship_distance()) > 0) {
      ships_distances %>%
        filter(Ship_id == value_vessel()) %>%
        slice(1) %>%
        pull(Date) %>% {
          glue::glue("Date: {.}")
        }
    } else {
      "-"
    }
    
  })
  
  output$card_ship_distance <- renderText({
    if (nrow(data_ship_distance()) > 0) {
      ships_distances %>%
        filter(Ship_id == value_vessel()) %>%
        slice(1) %>%
        pull(Distance) %>% {
          glue::glue("Distance: {round(., 2)} meters")
        }
    } else {
      "-"
    }
    
  })
  
}
