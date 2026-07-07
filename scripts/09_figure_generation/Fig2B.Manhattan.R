library(stringr)
library(data.table)
library(tidyverse)
library(argparser)
library(scRNAtoolVis)

diffdata<-as.data.frame(fread(diff_file,sep="\t",header=T))
#需包含列 gene, cluster, log2FC, pval, pval_adj

use_cols1 = '#7DBFA7,#EE934E,#D2EBC8,#9B5B33,#B383B9,#FCED82,#BBDD78,#3C77AF,#AECDE1,#D1352B,#F5CFE4,#8FA4AE,#F5D2A8'
use_cols1 = unlist(strsplit(use_cols1, ",")[[1]])
use_cols2=c('#BC3C29', '#0072B5', '#E14727', '#20854E', '#7876B1', '#6F99AD', '#FFDC91', '#EE4C97','#63BB56','#FBA539','#BCBD22', '#17BECF')
use_cols = c(use_cols1,use_cols2)

manha_plot <- function(diffdata, use_cols, prefix, topn=0){
    p <- jjVolcano(diffData = diffdata,
            expand=c(-1,1), 
            log2FC.cutoff=0.25,
            pvalue.cutoff =0.05, 
            legend.position=c(0.8,0.9),
            base_size = 12,
			celltypeSize=4,
            pSize=0.75, #点的大小
	    aesCol=c('#99d6eb','#e69999'),
            tile.col=use_cols, 
            topGeneN=topn
        )+
        theme(legend.position = 'top')+labs(x="")+
        theme(legend.key.size = unit(25, "pt"), 
            legend.text = element_text(colour="black", size=13)
        )+
        guides(color = guide_legend(override.aes = list(size = 5),reverse=TRUE  ))

    clusters=unique(diffdata$cluster)

    ggsave(paste0(prefix,"_diff_manhattan.pdf"),p,width=max(6,length(clusters)*0.8),height=7)
    ggsave(paste0(prefix,"_diff_manhattan.png"),p,width=max(6,length(clusters)*0.8),height=7)
}

manha_plot(diffdata, use_cols, "plot", topn=0)
