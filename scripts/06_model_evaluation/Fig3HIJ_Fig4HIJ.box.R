###cli_gene_barplot
library(dplyr)
library(ggpubr)
library(ggplot2)
library(patchwork)
library(argparser)
library(data.table)

use_cols=c('#7876B1','#E18727','#91D1C2','#E58579','#9180AC','#D9BDD8','#8AB1D2','#9BC985','#F7D58B','#BFC1A5','#797BB7','#6F99AD','#e3a8c7','#62beb8', '#d9b96b','#79b6c2')
use_cols = use_cols[!duplicated(use_cols)]

alldata<- fread(alldata,header=T,sep="\t")
valid_yplot<-c("prob")
valid_allgroup<-c("group3")
prefix<-"plot"

for (plotgene in valid_yplot) {
    for (group in valid_allgroup){
        uesdata<-na.omit(select(alldata,c(plotgene,group)))
        num<-length(unique(uesdata[[group]]))
        end_color<-use_cols[1:num]
        names(end_color)<-sort(unique(uesdata[[group]]))
        p <- ggplot(data = uesdata, aes( x = .data[[group]], y = .data[[plotgene]], fill = .data[[group]])) +
        geom_boxplot(position = position_dodge(1), width = 0.7, outlier.shape = 19, outlier.size = 1) +
        stat_summary(fun = median, geom = "point", shape = 16, size = 1, color = "white", position = position_dodge(1)) +
        scale_x_discrete(limits = sort(unique(uesdata[[group]]))) +
        scale_x_discrete(limits = sort(unique(uesdata[[group]]))) +
        scale_fill_manual(values = end_color) +
        labs(x = "", y = "Risk score") +
        theme_bw() +
        theme(
            axis.text.x = element_text(size = 15, color = "black",angle = 45, hjust = 1),
            axis.text.y = element_text(size = 15, color = "black"),
            axis.title.y = element_text(size = 15, color = "black"),
            axis.title.x = element_text(size = 15, color = "black"),
            panel.border = element_rect(colour = "black", linewidth = 1.2),
            panel.grid = element_blank(), 
            legend.position = 'none')
    
        ymin <-min(as.numeric(uesdata[[plotgene]]), na.rm = TRUE)/1.1
        ymax <- max(as.numeric(uesdata[[plotgene]]), na.rm = TRUE)*1.6
        ymax1 <- max(as.numeric(uesdata[[plotgene]]), na.rm = TRUE)*1.2 
        my_comparisons <- lapply(2, function(x) combn(sort(unique(uesdata[[group]])), x, simplify = FALSE))[[1]]
        p<-p+stat_compare_means(comparisons = my_comparisons,method = "wilcox.test")+stat_compare_means(label.y =ymax)
        }
        ggsave(paste0(prefix,"_",group,"_",plotgene, "_bar.pdf"), p, width = 4, height = 5)
        ggsave(paste0(prefix,"_",group,"_",plotgene, "_bar.png"), p, width = 4, height = 5)
    }
