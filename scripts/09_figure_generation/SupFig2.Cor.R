library(ggplot2)
library(argparser)
  
argv <- arg_parser('')
argv <- add_argument(argv,"--data", help="data")
argv <- add_argument(argv,"--prefix",help="")
argv <- parse_args(argv)

data <- argv$data
prefix <- argv$prefix
df<-read.table(data,header = T,sep="\t")
head(df)
# 计算相关性
cor1 <- cor.test(df$size, df$Bin_prod, method = "pearson")
cor2 <- cor.test(df$size, df$Bin_Frag_prod, method = "pearson")

# 提取R²和P值
r2_1 <- cor1$estimate^2
p1 <- cor1$p.value

r2_2 <- cor2$estimate^2
p2 <- cor2$p.value

options(repr.plot.width=5,repr.plot.height=5)
# 作图
p <- ggplot() +
  # Bin_prod 散点和拟合线
  geom_point(data = df, aes(x = size, y = Bin_prod), color = "#7876B1", size = 3) +
  geom_smooth(data = df, aes(x = size, y = Bin_prod),
              method = "lm", se = FALSE, color = "#7876B1", linetype = "dotted", linewidth = 1) +

  # Bin_Frag_prod 散点和拟合线
  geom_point(data = df, aes(x = size, y = Bin_Frag_prod), color = "#E18727", size = 3) +
  geom_smooth(data = df, aes(x = size, y = Bin_Frag_prod),
              method = "lm", se = FALSE, color = "#E18727", linetype = "dotted", linewidth = 1) +

  # 添加标注
  annotate("text", x = max(df$size)*0.5, y = max(df$Bin_prod, na.rm=TRUE)*0.45,
           label = paste0("Bin\nR² = ", round(r2_1, 2),
                          "\nP = ", signif(p1, 3)),
           color = "#7876B1", hjust = 0, size = 5) +

  annotate("text", x = max(df$size)*0.75, y = max(df$Bin_Frag_prod, na.rm=TRUE)*0.6,
           label = paste0("Bin_Frag\nR² = ", round(r2_2, 2),
                          "\nP = ", signif(p2, 3)),
           color = "#E18727", hjust = 0, size = 5) +

  labs(
    title = "Correlation of Riskscore with Size",
    x = "size",
    y = "Riskscore"
  ) +
  theme_classic(base_size = 14)+
theme(
    axis.text.x = element_text(size = 14,color = "black"),
    axis.text.y = element_text(size = 14,color = "black"),
    axis.title.y = element_text(size = 14,color = "black"),
    axis.title.x = element_text(size = 14,color = "black"),
)

ggsave(paste0(prefix,"_Cor.pdf"),p,width = 5,height = 5)
ggsave(paste0(prefix,"_Cor.png"),p,width = 5,height = 5)
