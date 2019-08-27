library(shiny)
library(shinythemes)
library(Matrix)
library(ggplot2)
library(RColorBrewer)
library(viridis)
library(cowplot)
library(scales)

shinyServer(function(input,output,session){
  #reactive inputs
  values <- reactiveValues(
    results=results,
    dr.c="",cluster.c="",
    dr.f="",feature.f="",
    cluster.vb="",feature.vb="",
    cluster.deg="",cluster.1.deg="",alpha.deg="",fc.deg="",direction.deg=""
  )
  values$results <- eventReactive(input$go.d,{
    LoadData(dim=c("umap","tsne","pca"),dir=dir.shared,samp=input$sample)
  })
  output$loaded <- eventReactive(input$go.d,{
    paste0("Sample ",values$results()$sample)
  })
  output$nav.analysis <- renderUI({
    req(values$results()$sample)
    tabsetPanel(type="tabs",
      tabPanel("Cluster Plot",
        sidebarPanel(
          h3(textOutput("lab.sample.c")),
          uiOutput("dr.c"),
          uiOutput("cluster.c"),
          actionButton("go.c","Submit")
        ),
        mainPanel(
          h3(textOutput("lab.dr.c")),
          h4(textOutput("lab.cluster.c")),
          plotOutput("plot.cluster.c"),
          tags$br(),
          uiOutput("button.download.c")
        )
      ),
      tabPanel("Feature Plot",
        sidebarPanel(
          h3(textOutput("lab.sample.f")),
          uiOutput("dr.f"),
          uiOutput("feature.f"),
          actionButton("go.f","Submit")
        ),
        mainPanel(
          h3(textOutput("lab.feature.f")),
          h4(textOutput("lab.dr.f")),
          plotOutput("plot.feature"),
          tags$br(),
          uiOutput("button.download.f")
        )
      ),
      tabPanel("ViolinBox Plot",
        sidebarPanel(
          h3(textOutput("lab.sample.vb")),
          uiOutput("cluster.vb"),
          uiOutput("feature.vb"),
          actionButton("go.vb","Submit"),
          br(),
          br(),
          plotOutput("plot.cluster.vb")
        ),
        mainPanel(
          h3(textOutput("lab.feature.vb")),
          h4(textOutput("lab.cluster.vb")),
          plotOutput("plot.violinbox"),
          tags$br(),
          uiOutput("button.download.vb"),
          tags$br(),
          tags$br(),
          tableOutput("table.expression.vb")
        )
      ),
      tabPanel("Differentially Expressed Features",
        sidebarPanel(
          h3(textOutput("lab.sample.deg")),
          uiOutput("cluster.deg"),
          uiOutput("cluster.1.deg"),
          numericInput("alpha.deg","Maximum p-value",min=0,max =1,value=0.05,step=0.001),
          numericInput("fc.deg","Minimum Fold Change",min=0,max =50,value=0,step=0.5),
          radioButtons("direction.deg","Fold Change Direction",c("Positively Expressed"="up","Negatively Expressed"="down","Both"="both"),selected="up"),
          actionButton("go.deg","Submit"),
          br(),
          br(),
          plotOutput("plot.cluster.deg")
        ),
        mainPanel(
          h3(textOutput("lab.cluster.1.deg")),
          h4(textOutput("lab.cluster.deg")),
          h5(textOutput("lab.alpha.deg")),
          h5(textOutput("lab.fc.deg")),
          uiOutput("download.deg.button"),
          tags$br(),
          tags$br(),
          tableOutput("table.deg")
        )
      )
    )
  })
  output$nav.qc <- renderUI({
    req(values$results()$sample)
    xml2::write_html(rvest::html_node(xml2::read_html(Sys.glob("workflow/output/multiqc/*/multiqc_report.html")), "body"), file = "workflow/output/multiqc/multiqc_report_vizapp.html")
    includeHTML("workflow/output/multiqc/multiqc_report_vizapp.html")
  })
  
  #sidebar input/outputs
  output$lab.sample.c <- reactive({paste0("Sample ",values$results()$sample)})
  output$dr.c <- renderUI({selectInput("dr.c","Dimentionality Reduction",names(values$results()$dr))})
  output$cluster.c <- renderUI({selectInput("cluster.c","Clustering",names(values$results()$cluster))})
  output$lab.sample.f <- reactive({paste0("Sample ",values$results()$sample)})
  output$dr.f <- renderUI({selectInput("dr.f","Dimentionality Reduction",names(values$results()$dr))})
  output$feature.f <- renderUI({textInput("feature.f","Feature",levels(values$results()$features[,2])[1])})
  output$lab.sample.vb <- reactive({paste0("Sample ",values$results()$sample)})
  output$cluster.vb <- renderUI({selectInput("cluster.vb","Clustering",names(values$results()$cluster))})
  output$feature.vb <- renderUI({textInput("feature.vb","Feature",levels(values$results()$features[,2])[1])})
  output$plot.cluster.vb <- renderPlot({
    req(input$go.vb)
    print(plot.cluster.vb())
  })
  output$lab.sample.deg <- reactive({paste0("Sample ",values$results()$sample)})
  output$cluster.deg <- renderUI({selectInput("cluster.deg","Clustering",names(values$results()$cluster))})
  output$cluster.1.deg <- renderUI({
    clust <- levels(factor(values$results()$cluster[[req(input$cluster.deg)]]$Cluster))
    selectInput("cluster.1.deg", "Specific Cluster",clust,clust[1])
  })
  observe({
    if (!is.numeric(input$alpha.deg)) {
      updateNumericInput(session,"alpha","Maximum p-value",min=0,max =1,value=0.05,step=0.001)
    }
  })
  observe({
    if (!is.numeric(input$fc.deg)) {
      updateNumericInput(session,"fc","Minimum Fold Change",min=0,max =50,value=0,step=0.5)
    }
  })
  output$lab.sample.qc <- reactive({paste0("Sample ",values$results()$sample)})
  output$lab.cell.count <- renderText({paste0(nrow(values$results()$barcodes)," Cells Detected")})  
  output$qc <- renderTable(values$results()$qc)
  
  #main input/outputs
  output$lab.dr.c <- eventReactive(input$go.c,{
    req(input$go.c)
    paste0(toupper(req(input$dr.c))," Reduction")
  },ignoreNULL=FALSE)
  output$lab.cluster.c <- eventReactive(input$go.c,{
    req(input$go.c)
    paste0(toupper(req(input$cluster.c))," Clustering")
  },ignoreNULL=FALSE)
  output$plot.cluster.c <- renderPlot({
    req(input$go.c)
    print(plot.cluster.c())
  })
  output$lab.feature.f <- eventReactive(input$go.f,{
    req(input$go.f)
    if(toupper(req(input$feature.f)) %in% as.character(values$results()$features[,2])){
      toupper(req(input$feature.f))
    } else {
      paste0(req(input$feature.f)," NOT PRESENT")
    }
  },ignoreNULL=FALSE)
  output$lab.dr.f <- eventReactive(input$go.f,{
    req(input$go.f)
    paste0(toupper(req(input$dr.f))," Reduction")
  },ignoreNULL=FALSE)
  output$plot.feature <- renderPlot({
    req(input$go.f)
    print(plot.feature())
  })
  output$lab.feature.vb <- eventReactive(input$go.vb,{
    req(input$go.vb)
    if(toupper(req(input$feature.vb)) %in% as.character(values$results()$features[,2])){
      toupper(req(input$feature.vb))
    } else {
      paste0(req(input$feature.vb)," NOT PRESENT")
    }
  },ignoreNULL=FALSE)
  output$lab.cluster.vb <- eventReactive(input$go.vb,{
    req(input$go.vb)
    paste0(toupper(req(input$cluster.vb))," Clustering")
  },ignoreNULL=FALSE)
  output$plot.violinbox <- renderPlot({
    req(input$go.vb)
    print(plot.violinbox())
  })
  output$table.expression.vb <- renderTable({
    req(input$go.vb)
    table.expression.vb()
  })
  output$lab.cluster.1.deg <- eventReactive(input$go.deg,{
    req(input$go.deg)
    paste0("Cluster ",req(input$cluster.1.deg)," DEGs")
  },ignoreNULL=FALSE)
  output$lab.cluster.deg <- eventReactive(input$go.deg,{
    req(input$go.deg)
    paste0(toupper(req(input$cluster.deg))," Clustering")
  },ignoreNULL=FALSE)
  output$lab.alpha.deg <- eventReactive(input$go.deg,{
    req(input$go.deg)
    paste0("Maximum p-value <- ",req(input$alpha.deg))
  },ignoreNULL=FALSE)
  output$lab.fc.deg <- eventReactive(input$go.deg,{
    req(input$go.deg)
    if (req(input$direction.deg) == "up"){
      paste0("Minimum fold-change difference <- ",req(input$fc.deg)," above the other cells")
    } else if (req(input$direction.deg) == "down") {
      paste0("Minimum fold-change difference <- ",req(input$fc.deg)," below the other cells")
    } else {
      paste0("Minimum fold-change difference <- ",req(input$fc.deg)," above & below the other cells")
    }
  },ignoreNULL=FALSE)
  output$table.deg <- renderTable({
    req(input$go.deg)
    table.deg()
  })
  output$plot.cluster.deg <- renderPlot({
    req(input$go.deg)
    print(plot.cluster.deg())
  })
  output$download.deg.button <- renderUI({
    req(input$go.deg)
    downloadButton("download.deg","Download Table")
  })
  output$plot.cliffknee <- renderPlot({print(Plot.cliffknee(barcodes.raw=values$results()$barcodes.raw,exp.raw=values$results()$exp.raw,barcodes=values$results()$barcodes))})
  
  #reactive download buttons
  output$button.download.c <- renderUI({
    req(input$go.c)
    downloadButton("download.c","Download Figure")
  })
  output$button.download.f <- renderUI({
    req(input$go.f)
    downloadButton("download.f","Download Figure")
  })
  output$button.download.vb <- renderUI({
    req(input$go.vb)
    downloadButton("download.vb","Download Figure")
  })
  output$button.download.deg <- renderUI({
    req(input$go.deg)
    downloadButton("download.deg","Download Table")
  })
    
  #save current parameters
  values$dr.c <- eventReactive(input$go.c,{input$dr.c})
  values$cluster.c <- eventReactive(input$go.c,{input$cluster.c})
  values$dr.f <- eventReactive(input$go.f,{input$dr.f})
  values$feature.f <- eventReactive(input$go.f,{toupper(input$feature.f)})
  values$cluster.vb <- eventReactive(input$go.vb,{input$cluster.vb})
  values$feature.vb <- eventReactive(input$go.vb,{toupper(input$feature.vb)})
  values$cluster.deg <- eventReactive(input$go.deg,{input$cluster.deg})
  values$cluster.1.deg <- eventReactive(input$go.deg,{input$cluster.1.deg})
  values$alpha.deg <- eventReactive(input$go.deg,{input$alpha.deg})
  values$fc.deg <- eventReactive(input$go.deg,{input$fc.deg})
  values$direction.deg <- eventReactive(input$go.deg,{input$direction.deg})
  
  #plot functions
  plot.cluster.c <- eventReactive(input$go.c,{
    Plot.cluster(
    values$results()$dr[[req(input$dr.c)]],values$results()$cluster[[req(input$cluster.c)]])
  },ignoreNULL=FALSE)
  plot.feature <- eventReactive(input$go.f,{
    if(toupper(req(input$feature.f)) %in% as.character(values$results()$features[,2])){
      Plot.feature(values$results()$dr[[req(input$dr.f)]],values$results()$exp[as.numeric(rownames(values$results()$features[values$results()$features[,2]==toupper(req(input$feature.f)),])),])
    } else {
      plot.new()
    }
  },ignoreNULL=FALSE)
  plot.violinbox <- eventReactive(input$go.vb,{
    if(toupper(req(input$feature.vb)) %in% as.character(values$results()$features[,2])){
      Plot.violinbox(values$results()$exp[as.numeric(rownames(values$results()$features[values$results()$features[,2]==toupper(req(input$feature.vb)),])),],values$results()$cluster[[req(input$cluster.vb)]])
    } else {
      plot.new()
    }
  },ignoreNULL=FALSE)
  plot.cluster.vb <- eventReactive(input$go.vb,{
    Plot.cluster(
      values$results()$dr[["umap"]],values$results()$cluster[[req(input$cluster.vb)]])
  },ignoreNULL=FALSE)
  plot.cluster.deg <- eventReactive(input$go.deg,{
    req(input$cluster.1.deg)
    Plot.cluster(
      values$results()$dr[["umap"]],values$results()$cluster[[input$cluster.deg]])
  },ignoreNULL=FALSE)
  
  #table functions
  table.expression.vb <- eventReactive(input$go.vb,{
    if(toupper(req(input$feature.vb)) %in% as.character(values$results()$features[,2])){
      tab <- values$results()$deg[[req(input$cluster.vb)]][values$results()$deg[[req(input$cluster.vb)]][,2]==toupper(req(input$feature.vb)),c(2,grep("Mean.Counts",names(values$results()$deg[[req(input$cluster.vb)]])))]
      colnames(tab) <- c("Feature",gsub(".Mean.Counts","",names(tab[,-1])))
      tab <- data.frame(t(tab))
      tab[,2] <- tab[,1]
      tab[,1] <- rownames(tab)
      tab <- tab[-1,]
      colnames(tab) <- c("Cluster",paste0("Ave ",req(input$feature.vb)," Expression"))
      tab
    } else {
      ""
    }
  },ignoreNULL=FALSE)
  table.deg <- eventReactive(input$go.deg,{
    tab <- values$results()$deg[[input$cluster.deg]]
    tab <- tab[tab[paste0("Cluster.",req(input$cluster.1.deg),".Adjusted.p.value")]<=input$alpha.deg,]
    if (input$fc.deg == 0){
      fc <- 0
    } else {
      fc <- log2(input$fc.deg)
    }
    if (input$direction.deg=="up"){
      tab <- tab[tab[paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change")]>=fc,]
    } else if (input$direction.deg=="down"){
      tab <- tab[tab[paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change")]<=-fc,]
    } else {
      tab <- tab[tab[paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change")]>=fc | tab[paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change")]<=-fc,]
    }
    tab <- tab[,c(colnames(values$results()$deg[[input$cluster.deg]])[2],paste0("Cluster.",req(input$cluster.1.deg),".Mean.Counts"),paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change"),paste0("Cluster.",req(input$cluster.1.deg),".Adjusted.p.value"))]
    tab <- tab[order(abs(tab[paste0("Cluster.",req(input$cluster.1.deg),".Log2.fold.change")]),decreasing=TRUE),]
    tab
  },ignoreNULL=FALSE)
  
  #download
  output$download.c <- downloadHandler(
    filename <- function(){paste0("clusters_",values$dr.c(),"_",values$cluster.c(),".pdf")},
    content <- function(file){
      pdf(file,onefile=FALSE)
      print(plot.cluster.c())
      dev.off()
    }
  )
  output$download.f <- downloadHandler(
    filename <- function(){paste0("feature_",values$dr.f(),"_",toupper(values$feature.f()),".pdf")},
    content <- function(file){
      pdf(file,onefile=FALSE)
      print(plot.feature())
      dev.off()
    }
  )
  output$download.vb <- downloadHandler(
    filename <- function(){paste0("violinbox_",values$cluster.vb(),"_",toupper(values$feature.vb()),".pdf")},
    content <- function(file){
      pdf(file,onefile=FALSE)
      print(plot.violinbox())
      dev.off()
    }
  )
  output$download.deg <- downloadHandler(
    filename <- function(){paste0("deg_",values$cluster.deg(),"_cluster.",values$cluster.1.deg(),"_p",values$alpha.deg(),"_fc",values$fc.deg(),values$direction.deg(),".csv")},
    content <- function(file){
      write.csv(table.deg(),file,row.names=FALSE,quote=FALSE)
    }
  )
})
