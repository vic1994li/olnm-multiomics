suppressPackageStartupMessages({
library(ggpubr)
library(ggplot2)
library(data.table)
library(tidyverse)
library(argparse)
library(RColorBrewer)
})

used_cols=c("#7876B1","#E18727","#91D1C2")
names(used_cols) <- c("N0","N1","N2")

dual.plot <- function(fig, file.prefix, w=7, h=7, res=300){
    pdf(paste(file.prefix,".pdf",sep=""), width = w, height = h,onefile=FALSE)
    print(fig)
    dev.off()
}

data<-read.table(plot_data,sep="\t",quote=F)

p <- ggplot(data, 
            aes(x = start, y = Value, color = group, group = group)) +
    geom_line(linewidth = 0.5) +
    facet_grid(group ~ chromosome,scales = "free_x",switch = "x")+
    scale_color_manual(values = used_cols) +
    scale_y_continuous(limits = c(0,4)) +
    labs(x = "Chromosome", 
        y = "Mean coverage across bins") +
    theme_classic(base_size = 16) +
    theme_pubr(base_size = 16) +
    theme(
        strip.background = element_blank(),
        strip.text = element_text(size = 12, face = "plain"),
        strip.placement = "outside",  # 将标签放在轴外部
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 16),  # 图例标题
        legend.text = element_text(size = 16),   # 图例项目文字
        legend.position = "top"
    )
dual.plot(p, "plot_coverage", w=16,h=5)
