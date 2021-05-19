#' UI: Dropdown
#'
#' @param type 
#' @param id 
dropdown_ui <- function(id, type) {
  ns <- NS(id)
  
  tagList(
    dropdown_input(
      input_id = ns("dropdown"), 
      choices = NULL, 
      default_text = glue::glue("Select {type}"), 
      type = "fluid search selection"
      )
    )
  
}

#' Server: Dropdown
#'
#' @param id 
#' @param values 
#'
#' @return Alerta de creacion o error
dropdown_server <- function(id, values) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      
      ns <- session$ns
      
      # 1 - Value to Return -----
      
      return_value <- shiny::reactiveVal()
      

      # 2 - Complete dropdown -----
      
      observe({
        update_dropdown_input(
          session = session, 
          input_id = "dropdown", 
          choices = names(values()), 
          choices_value = values()
        )
      })
      
      observeEvent(input$dropdown, {
        return_value(input$dropdown)
      })
      
      
      # 5 - Return values -----
      
      return_value
      
    }
  )
}