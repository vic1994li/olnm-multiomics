#根据基因列表用ORA方法进行富集分析
suppressPackageStartupMessages({
library(clusterProfiler)
library(argparser)
library(tidyverse)
library(ggpubr)
library(data.table)
})
species<-"Homo.sapiens"
pvalue_type<-"pvalue"
prefix <- "Enrichment"

diffgene <- read.table(diffgene,header=T,sep='\t',check.names=F,stringsAsFactor=F)
col_names=colnames(diffgene)
diffgene = unique(diffgene$gene_name)

em <- enricher(diffgene, universe=universe,TERM2GENE=term2gene, TERM2NAME=term2name, pvalueCutoff = 1,pAdjustMethod = "BH",qvalueCutoff = 1,minGSSize = 3)

em_data = as.data.frame(em)
em_data$GeneRatio = gsub('/','|',em_data$GeneRatio)
em_data$BgRatio = gsub('/','|',em_data$BgRatio)
fwrite(em_data,paste0(prefix,"_","enrich.xls"),sep="\t")

em_sig = em_data %>% dplyr::filter(get(pvalue_type)<0.05)
save(list=ls(),file=paste0(prefix, '.RData'))

dim(em_sig)
#plot
#use_cols:RdYlBu, OrRd
#RColorBrewer::display.brewer.all() #显示所有调色板
enrich_plot = function(eGO, prefix, enrich_type='GO',show_category=15, p_type='pvalue', use_cols='OrRd'){
    eGO@result <- eGO@result %>%arrange(Count)  # 按 Count 从小到大排序
    eGO@result <- eGO@result %>% arrange(GeneRatio)  # 按 Count 从小到大排序
    p_dot =dotplot(eGO,showCategory = show_category, #展示的通路
                      font.size = 12,
                      size='GeneRatio', #点大小
                      color = p_type, #颜色映射
                      label_format = 35 #字符截断数
                    ) + 
                 ggtitle(prefix)+
    scale_color_distiller(palette = use_cols, direction = 1)
                    
    if(is.numeric(show_category)){
        f_height = min(nrow(eGO),show_category)
    }else{
        f_height = length(show_category)
    }
    height = max(2, f_height/2)
    print(paste0('height:',height))
 
    ggsave(p_dot, file=paste0(prefix, '_dot.pdf'), width=7, height=height)
    ggsave(p_dot, file=paste0(prefix, '_dot.png'), width=7, height=height)
}

fwrite(em_sig,file=paste0(prefix,"_","enrich_sig.xls"),sep="\t")
em_sig$logpvalue<- round(-log10(em_sig[[pvalue_type]]),1)
data = em_sig %>% slice_max(logpvalue, n=10, with_ties=FALSE)
top_descriptions=data$Description
enrich_plot(em, prefix, prefix,show_category=top_descriptions, p_type=pvalue_type)
