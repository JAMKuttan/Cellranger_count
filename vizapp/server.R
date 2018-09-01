# This example implements a simple file browser for accessing results.

library(shiny)
library(shinyFiles)

# Results are available in the directory specified by the outputDir environment
# variable, red by Sys.getenv

rootdir <- Sys.getenv('outputDir')


shinyServer(function(input, output, session) {

    # The backend for a simple file chooser, restricted to the
    # rootdir we obtained above.
    # See https://github.com/thomasp85/shinyFiles

    shinyFileChoose(input, 'files', roots=c('workflow'=rootdir), filetypes=c('', 'bed', 'xls','wig'), session=session)

})
