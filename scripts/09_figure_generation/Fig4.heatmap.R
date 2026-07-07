suppressMessages({
library(ComplexHeatmap)
library(circlize)
library(argparser)
library(tibble)
library(dplyr)
library(yaml)
library(data.table)
})

group_levels<-c("N0","N1","N2")
use_cols<-c("#7876B1,#E18727,#91D1C2")
fontsize<-16
prefix<-"plot"
width<-10
height<-6

heatmap<-read.table(diff_file,header=TRUE,sep='\t',check.names=F,row.names=1)
heatmap = as.matrix(heatmap)
max_value=quantile(heatmap, 0.95,na.rm=T)
min_value=quantile(heatmap, 0.05,na.rm=T)
print(paste('color_break: ',max_value, min_value, sep=' '))
color = colorRamp2(breaks = c(min_value, 0, max_value), colors = c('#0072B5','white','#D1352B'))

group_frame <- fread(group_file,header=TRUE,sep='\t',check.names=F)
group_frame$group = factor(group_frame$group, levels=groups)
names(use_cols) = levels(group_frame$group)
column_names_gp <- gpar(fontsize = 10)

ht_opt$TITLE_PADDING = unit(c(5.5, 5.5), "points") #控制上方框的大小
p=Heatmap(mat=heatmap, 
    name = "expression", 
    col=color,
    show_row_names = TRUE, 
    show_column_names = FALSE,
    column_split = group_frame$group,
    column_title_gp = gpar(fill = use_cols, fontsize=fontsize),
    column_names_gp=column_names_gp,
    row_names_gp = gpar(fontsize = 14),
    column_order = colnames(heatmap),
    cluster_rows = FALSE, # 不进行行聚类
    cluster_columns = FALSE, # 不进行列聚类
    show_row_dend=FALSE,show_column_dend=FALSE,
    row_names_side ='left',
    heatmap_legend_param = list(title = "Exp", title_gp = gpar(fontsize = 16), labels_gp = gpar(fontsize = 16))
    )
dual.plot(p, paste0(prefix,'_heatmap_name'), w=width,h=height)
