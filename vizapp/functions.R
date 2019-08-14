LoadData <- function(dim=c("pca","tsne","umap"),dir,samp){
  exp <- readMM(paste0(dir,samp,"/outs/filtered_feature_bc_matrix/matrix.mtx.gz"))
  features <- read.table(paste0(dir,samp,"/outs/filtered_feature_bc_matrix/features.tsv.gz"),quote="\t")
  barcodes <- read.table(paste0(dir,samp,"/outs/filtered_feature_bc_matrix/barcodes.tsv.gz"),quote="\t")
  
  exp.raw <- readMM(paste0(dir,samp,"/outs/raw_feature_bc_matrix/matrix.mtx.gz"))
  features.raw <- read.table(paste0(dir,samp,"/outs/filtered_feature_bc_matrix/features.tsv.gz"),quote="\t")
  barcodes.raw <- read.table(paste0(dir,samp,"/outs/raw_feature_bc_matrix/barcodes.tsv.gz"),quote="\t")
  
  dr <- list()
  for (i in dim){
    if (i=="pca"){
      dr[[i]] <- read.csv(paste0(dir,samp,"/outs/analysis/",i,"/10_components/projection.csv"))
      dr[[i]] <- dr[[i]][,1:3]
    } else {
      dr[[i]] <- read.csv(paste0(dir,samp,"/outs/analysis/",i,"/2_components/projection.csv"))
    }
  }
  rm(i)
  
  cl <- c("graphclust",paste0("kmeans_",2:10,"_clusters"))
  cluster <- list()
  deg <- list()
  for (i in cl){
    cluster[[i]] <- read.csv(paste0(dir,samp,"/outs/analysis/clustering/",i,"/clusters.csv"))
    deg[[i]] <- read.csv(paste0(dir,samp,"/outs/analysis/diffexp/",i,"/differential_expression.csv"))
  }
  rm(i)
  
  qc <- read.csv(paste0(dir,samp,"/outs/metrics_summary.csv"))
  qc <- data.frame(t(qc))
  qc[,2] <- qc[,1]
  qc[,1] <- rownames(qc)
  qc <- qc[-1,]
  colnames(qc) <- c("Metric","Value")
  
  results <- list(
    sample=samp,
    exp=exp,
    features=features,
    barcodes=barcodes,
    exp.raw=exp.raw,
    features.raw=features.raw,
    barcodes.raw=barcodes.raw,
    dr=dr,
    cluster=cluster,
    deg=deg,
    qc=qc
  )
  return(results)
}

Plot.cluster <- function(dr,cluster){
  pl <-merge(dr,cluster,by="Barcode",all.x=TRUE)
  axis.labs <- colnames(pl)[2:3]
  colnames(pl)[2:3] <- c("dim1","dim2")
  plot.out <- ggplot(pl,aes(x=dim1,y=dim2,col=factor(Cluster)))+geom_point()+scale_color_viridis(discrete=TRUE)+xlab(axis.labs[1])+ylab(axis.labs[2])+labs(col="Cluster")+theme_cowplot()
  return(plot.out)
}

Plot.feature <- function(dr,ft){
  dr$exp <- ft
  axis.labs <- colnames(dr)[2:3]
  colnames(dr)[2:3] <- c("dim1","dim2")
  if (sum(dr$exp) != 0){
    plot.out <- ggplot(dr,aes(x=dim1,y=dim2,col=exp))+geom_point()+scale_color_viridis(option="inferno")+xlab(axis.labs[1])+ylab(axis.labs[2])+labs(col="Expression")+theme_cowplot()
  } else {
    plot.out <- ggplot(dr,aes(x=dim1,y=dim2,col=exp))+geom_point()+scale_color_gradient(low="black",high="black")+xlab(axis.labs[1])+ylab(axis.labs[2])+labs(col="Expression")+theme_cowplot()
  }
  return(plot.out)
}

Plot.violinbox <- function(ft,cluster){
  cluster$exp <- ft
  cluster$Cluster <- factor(cluster$Cluster)
  plot.out <- ggplot(cluster,aes(x=Cluster,y=exp,fill=Cluster))+geom_violin(scale="width",trim=TRUE)+geom_boxplot(width=0.25,fill="white",outlier.shape=NA)+scale_fill_viridis(discrete=TRUE)+ylab("Expression")+theme_cowplot()+theme(axis.text.x=element_text(angle=45))

  return(plot.out)
}

Plot.cliffknee <- function(barcodes.raw,exp.raw,barcodes){
  umi <- matrix(nrow=length(barcodes.raw[,1]),ncol=4)
  umi[,1] <- t(colSums(exp.raw))
  umi[,2] <- as.character(barcodes.raw[,1])
  umi <- as.data.frame(umi)
  umi[,1] <- as.numeric(levels(umi[,1]))[umi[,1]]
  colnames(umi) <- c("nUMI","barcodes","rank","Cell")
  umi <- umi[order(umi$nUMI,decreasing=TRUE),]
  umi$rank <- 1:nrow(umi)
  umi$Cell <- factor(as.character(umi$barcodes %in% barcodes[,1]))
  umi$Cell <- factor(umi$Cell,levels(umi$Cell)[c(2,1)])
  plot.out <- ggplot(umi,aes(x=rank,y=nUMI,col=Cell))+geom_point()+scale_color_manual(values=c("darkgreen","darkred"))+
    scale_x_log10(breaks=trans_breaks("log10",function(x) 10^x),labels=trans_format("log10",math_format(10^.x)))+
    scale_y_log10(breaks=trans_breaks("log10",function(x) 10^x),labels=trans_format("log10",math_format(10^.x)))+
    annotation_logticks()+xlab("Barcode Rank")+ylab("nUMI")+theme_cowplot()
  
  return(plot.out)
}
