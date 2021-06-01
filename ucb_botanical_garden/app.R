## UC BOTANICAL GARDEN 360 PHOTOS SHINY APP

library(shiny)

## Create a vector of the JPG files in the 'www' directory.
## We do this *outside* of ui() and server() because this only needs to be done once and only once
imgs_fn <- list.files("www", pattern = "JPG$|JPEG$", ignore.case = TRUE)

## Define the UI
ui <- fluidPage(
  titlePanel("Simple 360 Photo Viewer: UC Berkeley Botanical Garden"),
  
  p("This app demonstrates how to view 360 photos using Shiny. For details, see this blog post and the source code."),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("img_fn", "Image", choices = imgs_fn, selected = NULL),
      width = 2
    ),
    mainPanel(
      uiOutput("pano_iframe")
    )
  )
)

server <- function(input, output) {
  ## Render the iFrame 
  output$pano_iframe <- renderUI({

    ## Construct the URL
    src_url <- paste0("pannellum.htm#panorama=",
                                input$img_fn, 
                                "&autoLoad=true&autoRotate=-2")
    
    tags$iframe(src = URLencode(src_url), width = "1200px", height = "600px")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
