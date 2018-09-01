library(shiny)
library(shinyFiles)


shinyUI(fluidPage(

  verticalLayout(

    # Application title
    titlePanel("Astrocyte Example"),

    wellPanel(

        helpText("This is a minimal example, demonstrating how
        a Shiny visualization application can access the output of a workflow.
        Here we provide a file browser using the shinyFiles package. Real
        Astrocyte vizapps would provide custom methods to access and visualize
        output."),

        helpText("The workflow output is in the directory set in the
        outputDir environment variable. this can be retrieved in R with the
        command Sys.getenv('outputDir')"),

        # A simple file browser within the workflow output directory
        # See https://github.com/thomasp85/shinyFiles
        shinyFilesButton('files', label='Browse workflow output', title='Please select a file', multiple=FALSE)

    )
  )
))
