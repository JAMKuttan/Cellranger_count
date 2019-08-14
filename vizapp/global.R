library(shiny)
library(shinythemes)
library(Matrix)
library(ggplot2)
library(RColorBrewer)
library(viridis)
library(cowplot)
library(scales)

setwd("../")
source("./vizapp/functions.R")
  
#load data
dir.shared <- "/work/BICF/s189701/cellranger_count/workflow/output/count310/"
samples <- list.dirs(dir.shared,full.names=FALSE,recursive=FALSE)
results <- LoadData(dim=c("umap","tsne","pca"),dir=dir.shared,samp=samples[1])
