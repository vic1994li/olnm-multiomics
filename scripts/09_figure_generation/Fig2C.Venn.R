library(tidyverse)
library(ggvenn)
library(argparser)

argv <- arg_parser('venn plot')
argv <- add_argument(argv,"--file_list", help="aa.txt,bb.txt Required.")
argv <- add_argument(argv,"--outdir", help="outdir", default='./')
argv <- add_argument(argv,"--prefix", help="prefix", default="pbmc")
argv <- add_argument(argv,"--label_list", help="venn label:aa,bb")
argv <- parse_args(argv)

file_list=argv$file_list
file_list = unlist(strsplit(file_list,','))
outdir = argv$outdir
prefix = argv$prefix
label_list =argv$label_list
label_list = unlist(strsplit(label_list,','))

print(file_list)
data_list=list()
for(each_file in file_list){
    data= read.table(each_file, sep='\t', header=T, check.names = F)
    genes = unique(unlist(data$geneName))
    file_id = label_list[which(file_list==each_file)]
    data_list[[file_id]] = genes
}
data_type=names(data_list)
new_data_list = data_list[-1]
library(ggvenn)

common_genes = Reduce(base::intersect,data_list) %>% as.data.frame()
common_genes<-as.data.frame(common_genes)
colnames(common_genes)<-"gene_name"
write.table(common_genes, file=paste0(outdir,'/',prefix,'.venn_common.txt'), sep='\t',quote=F,row.names=F)

max_length <- max(sapply(data_list, length))
new_data = do.call(cbind, lapply(data_list, function(x) c(x, rep('', max_length - length(x)))))
write.table(new_data, paste0(outdir,'/',prefix,".venn_data.txt"), sep="\t", row.names = FALSE,quote=F)


mycol2<-c('#BC3C29','#00468B')
mycol2<-rev(mycol2)
p <- ggvenn(data_list, fill_color=mycol2,stroke_linetype = "solid", set_name_size = 5,text_size = 5,
           fill_alpha = 0.8,)+coord_flip()
ggsave(p,file=paste0(outdir,'/',prefix,'.venn_plot.pdf'),width=4,height=6)
mypdf=paste0(outdir,'/',prefix,'.venn_plot.pdf')
mypng=paste0(outdir,'/',prefix,'.venn_plot.png')
system(paste0("/usr/bin/convert  -density 600 -background white -flatten ",mypdf," ",mypng))
