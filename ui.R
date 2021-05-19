semanticPage(
  title = "Marine Dashboard", 
  theme = "yeti",
  sidebar_layout(
    mirrored = TRUE,
    sidebar_panel(
      h2(
        class = "ui center aligned icon header", 
        icon("circular", shiny::icon("ship")),
        div(
          class = "content", "Marine Dashboard", 
          div(class = "sub header", "Appsilon test")
          )
        ),
      h3("Please select Vessel Type first"),
      dropdown_ui(id = "vessel_type", type = "Vessel Type"),
      div(class = "ui horizontal divider", "AND"),
      h3("then select Vessel"),
      dropdown_ui(id = "vessel", type = "Vessel"),
      br(),
      div(class = "ui horizontal divider", shiny::icon("info"), "Extra info"),
      card(
        style = "width:auto",
        div(
          class = "content",
          div(
            class = "header", textOutput("card_ship_name")
            ), 
          div(
            class = "meta", textOutput("card_ship_flag")
            ),
          div(
            class = "meta", textOutput("card_ship_date")
            ),
          div(
            class = "description", textOutput("card_ship_distance")
            )
          )
        )
      ),
    main_panel(
      segment(
        class = "placeholder",
        style = "height:96vh", 
        leafletOutput("map", height = "100%")
        )
      )
    )
  
)