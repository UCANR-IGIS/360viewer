## DRONE 360S VIEWER SHINY APP

library(shiny)

## Read in a csv file which contains the JPG file names, image titles, etc.
imgs_df <- read.csv("images.csv", stringsAsFactors = FALSE)

## Error checks
if (anyDuplicated(imgs_df$title_short)) stop("The 'title_short' column must contain unique values")
if (FALSE %in% file.exists(file.path("www", imgs_df$fn))) {
  stop(paste0("360 image file(s) not found: ", 
              paste(file.path("www", imgs_df$fn)[!file.exists(file.path("www", imgs_df$fn))], collapse = ", ")))
}

## Define the UI
ui <- fluidPage(
  tags$style("h2 {font-size:20px; font-weight:bold; color:#444;}"),
  titlePanel("Intermediate 360 Photo Viewer: UC Field Station from the Air"),
  tags$p("This app demonstrates how to view drone 360 photos using Shiny. For details, see this ", 
    tags$a(href="http://igis.ucanr.edu/Tech_Notes/360-shiny-viewer/", target="_blank", rel="noopener", "Tech Note"), 
    " or the ", 
    tags$a(href="https://github.com/ucanr-igis/360viewer", target="_blank", rel="noopener", "source code"), "."),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("img_title_short", "Image", choices = imgs_df$title_short, selected = NULL),
      br(),
      p("Options for JPGs"),
      checkboxInput("autoload", "Auto Load", value = TRUE),
      numericInput("autorotate", "Autorotate", -2),
      numericInput("pitch", "Pitch", -10),
      width = 2
    ),
    
    mainPanel(
      uiOutput("pano_iframe"),
      uiOutput("ui_msg", style = "width:1200px;")
    )
  )
)

server <- function(input, output) {
  
  ## This reactive object generates a URL for the iFrame Source
  ## It is updated whenever one of the input controls is changed
  iframe_src <- reactive({
    
    ## Get the row number of the selected image
    idx <- which(imgs_df$title_short == input$img_title_short)
    
    if (grepl(".json$", imgs_df$fn[idx], ignore.case = TRUE)) {
      
      ## This is a JSON file, so no need to append anything else to the URL
      paste0("pannellum.htm?config=", imgs_df$fn[idx])
      
    } else {
      
      ## Construct the URL parts
      title_param <- ifelse(is.na(imgs_df$title_long[idx]), "", 
                            paste0("&title=", imgs_df$title_long[idx]))
      
      author_param <- ifelse(is.na(imgs_df$author[idx]), "", 
                             paste0("&author=", imgs_df$author[idx]))
      
      autorotate_param <- paste0("&autoRotate=", input$autorotate)
      
      autoload_param <- ifelse(input$autoload, "&autoLoad=true", "&autoLoad=false")
      
      pitch_param <- paste0("&pitch=", input$pitch)
      
      ## Paste the pieces together and return
      paste0("pannellum.htm#panorama=", imgs_df$fn[idx], 
                        title_param, author_param, 
                        pitch_param, autorotate_param, autoload_param)
      
    }
    
  })
  
  ## Recreate the iframe content whenever iframe_src() changes
  output$pano_iframe <- renderUI({
    ## Return an iFrame tag which will become the new content of pano_iframe
    tags$iframe(src = URLencode(iframe_src()), width = "1200px", height = "600px")
  })
  
  output$ui_msg <- renderUI  ({
    ## Get the row number of the selected image
    idx <- which(imgs_df$title_short == input$img_title_short)
    tags$p(imgs_df$notes[idx], tags$br(), "iframe src: ", tags$em(iframe_src()))
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
