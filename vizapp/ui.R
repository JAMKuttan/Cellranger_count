navbarPage(theme=shinytheme("slate"),"BICF Cellranger Count Analysis (cellranger 3.1.0 version)",
  tabPanel("Select Data",
    mainPanel(
      selectInput("sample","Available Samples",samples),
      actionButton("go.d","Load"),
      br(),
      br(),
      h4("Please whait until the sample has been loaded and a message below displays this, it may take a few minutes"),
      h3(textOutput("loaded"))
    )
  ),
  tabPanel("Analysis",
    uiOutput("nav.analysis")
  ),
  tabPanel("QC",
    uiOutput("nav.qc")
  )
)
