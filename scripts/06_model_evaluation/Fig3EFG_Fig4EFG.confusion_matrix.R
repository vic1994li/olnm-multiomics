library(ggplot2)
library(reshape2)
library(argparser)
  
argv <- arg_parser('')
argv <- add_argument(argv,"--inputdata", help="")
argv <- add_argument(argv,"--prefix", help="")
argv <- parse_args(argv)
inputdata <- argv$inputdata
prefix <- argv$prefix

df <- read.table(inputdata,
                 header = TRUE,
                 sep = "\t",
                 stringsAsFactors = FALSE)

for(i in 1:nrow(df)){

  threshold <- df$group[i]

  TP <- df$TP[i]
  TN <- df$TN[i]
  FP <- df$FP[i]
  FN <- df$FN[i]

  # 构建矩阵（顺序非常重要）
  cm <- matrix(c(TN, FP,
                 FN, TP),
               nrow = 2,
               byrow = TRUE)

  rownames(cm) <- c("True LNM-","True LNM+")
  colnames(cm) <- c("Pred LNM-","Pred LNM+")

  cm_df <- melt(cm)

  colnames(cm_df) <- c("True_Label","Predicted_Label","Count")

  # 固定顺序
  cm_df$True_Label <- factor(cm_df$True_Label,
                             levels=c("True LNM+","True LNM-"))

  cm_df$Predicted_Label <- factor(cm_df$Predicted_Label,
                                  levels=c("Pred LNM-","Pred LNM+"))
  
  # 添加分类列用于指定颜色
  cm_df$Category <- with(cm_df, 
                         ifelse(True_Label == "True LNM-" & Predicted_Label == "Pred LNM-", "TN",
                         ifelse(True_Label == "True LNM+" & Predicted_Label == "Pred LNM+", "TP",
                         ifelse(True_Label == "True LNM-" & Predicted_Label == "Pred LNM+", "FP",
                                "FN"))))

  # 自定义颜色：TN蓝色，TP红色，FP和FN白色
  custom_colors <- c("TN" = "#3B4992",    # 蓝色
                     "TP" = "#BC3C29",    # 红色
                     "FP" = "#FFFFFF",    # 白色
                     "FN" = "#FFFFFF")    # 白色
  
  cm_df$TextColor <- ifelse(cm_df$Category %in% c("TN", "TP"), "white", "black")

  # 打印数据检查
  print(paste("Processing threshold:", threshold))
  print(cm_df)
  p <- ggplot(cm_df,
              aes(x=Predicted_Label,
                  y=True_Label,
                  fill=Category)) +
    
    geom_tile(color="black", size=1.5) +
    
    geom_text(aes(label=Count, color=TextColor),
              size=8,
              fontface="bold") +
    
    scale_fill_manual(values = custom_colors,
                      guide = "none") +
    scale_color_identity() + 
    labs(title=paste0(threshold, " Confusion Matrix"),
         x="Predicted Label",
         y="True Label") +
    
    theme_bw() +  
    
    theme(
      text=element_text(size=16, color="black",face="bold"),
      plot.title=element_text(hjust=0.5, size=16, face="bold", color="black"),
      axis.title=element_text(size=16, color="black",face="bold"),
      axis.text=element_text(size=16, color="black",face="bold"),
      axis.text.x=element_text(angle=0, hjust=0.5, color="black"),
      axis.text.y=element_text(color="black"),
      panel.border=element_rect(fill=NA, color="black", size=0),  # 添加 fill=NA
      panel.grid=element_blank(),
    )

  ggsave(paste0(prefix,"_", threshold, ".pdf"),
         plot = p,
         width = 5,
         height = 5,
         dpi = 300,
         device = "pdf")
  
  ggsave(paste0(prefix,"_", threshold, ".png"),
         plot = p,
         width = 5,
         height = 5,
         dpi = 300,
         device = "png")
  
}
