library(reshape2)
library(ggpubr)
library(tidyverse)
library(data.table)
library(RColorBrewer)
library(dplyr)
udata<-as.data.frame(fread(count_data,header = T,sep="\t"))
udata$fraction<-round(udata$count/sum(udata$count)* 100, 2)
udata$label = ifelse(udata$fraction>5, paste0(udata$fraction,'%'), '')
data<-udata
use_cols <- c("#E64B35","#3C5488","#F39B7F","#00A087","#E18727", "#91D1C2","#7876B1")

p <- ggplot(data, aes(x = "", y = fraction, fill = type)) +
  geom_bar(stat = "identity", width = 1, color = "white", linewidth = 0.3) +
  coord_polar(theta = "y") +
  theme_void() +  # 去掉背景和坐标轴
  geom_text(aes(label = label), 
            position = position_stack(vjust = 0.5), 
            size = 5,  # 从3.5增大到5
            fontface = "bold") +
  scale_fill_manual(values = use_cols) +  # 使用自定义颜色
  labs(fill = "Genomic Region") +
  theme(legend.position = "right",
        legend.title = element_text(face = "bold", size = 14),  # 从10增大到14
        legend.text = element_text(size = 12),  # 从9增大到12
        plot.margin = margin(15, 15, 15, 15))  # 边距略微增大
ggsave("Region_pie.pdf",p,width=6,height=4)
ggsave("Region_pie.png",p,width=6,height=4)
