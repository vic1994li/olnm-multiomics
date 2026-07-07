suppressPackageStartupMessages({
library(argparser)
library(dplyr)
library(tidyverse)
library(data.table)
library(edgeR)
library(limma)
library(DESeq2)
library(ggpubr)
})

compare="N12_vs_N0"
diff_software="limma"
log2FC_cut=1
pvalue_cut=0.05
pvalue_type=pvalue

exprset = fread(expr_file, sep='\t', header=T, check.names=F)
colnames(exprset)[1] = 'genesymbol'
head(colnames(exprset))
exprset = exprset[!duplicated(exprset$genesymbol),]
exprset[is.na(exprset)] <- 0
exprset[exprset==""] <- 0
exprset[is.null(exprset)] <- 0
exprset <- aggregate(.~genesymbol, data=exprset, mean)
exprset = column_to_rownames(exprset, var='genesymbol')
exprset <- exprset[which(rowSums(exprset)!=0),]
#去除50%样本都不表达的基因
num <- ncol(exprset) / 5  # 表达样本的数量阈值 (20%)
exprset <- exprset[rowSums(exprset != 0) >= num, ]
dim(exprset)

compare_group = unlist(strsplit(compare,'_vs_'))
com_name = gsub('_vs_','-', compare)
metadata<-fread(group_file,sep="\t",header=T)
metadata= metadata[metadata$group %in% compare_group,]
metadata$group = factor(metadata$group, levels=rev(compare_group))
head(metadata$sample)
common_samples = base::intersect(colnames(exprset),metadata$sample)
filter_data = exprset[,common_samples]
metadata = subset(metadata, sample %in% common_samples)
metadata = metadata[match(common_samples, metadata$sample), ]
fwrite(metadata, file='sample_info.xls',sep='\t')

diff_limma = function(exprset,metadata){
    ex <- exprset
    qx <- as.numeric(stats::quantile(ex, c(0., 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = T))
    LogC <- (qx[5] > 100) || (qx[6] - qx[1] > 50 && qx[2] > 0)

    if (LogC) {
        exprset <- log2(ex + 1)
        exprset1 = exprset %>% as.data.frame() %>% rownames_to_column(var='genesymbol')
        message("=> log2(x+1) transform finished")
        fwrite(exprset1, file=paste0(prefix,'.log_expset.txt'),sep='\t')
    }else{
        message("=> log2 transform not needed")
    }

    message("=> Running limma")
    exprset <- limma::normalizeBetweenArrays(exprset)
    exprset1 <- exprset %>% as.data.frame() %>% rownames_to_column(var='genesymbol')
    fwrite(exprset1, file='normalize_exp.xls',sep='\t')
    group = metadata$group
    names(group) = metadata$sample
    design <- stats::model.matrix(~0+group) #表示模型中不包含截距（intercept），它会创建一个只有group变量的模型矩阵，没有常数项（即所有观测值都等于1的列）。这意味着每个组别的估计值都是相对于所有其他组的平均值来计算的.
    colnames(design) <- levels(group)
    rownames(design) <- names(group)
    contrast.matrix <- limma::makeContrasts(com_name,levels = design)
    fit <- limma::lmFit(exprset, design)
    fit2 <- contrasts.fit(fit, contrast.matrix)
    fit2 <- eBayes(fit2)
    deg_limma <- topTable(fit2, coef = 1,n = Inf,sort.by="logFC")
    deg_limma <- stats::na.omit(deg_limma)
    deg_limma <- rownames_to_column(deg_limma, var='genesymbol')
    return(deg_limma)
}

deg_data=diff_limma(filter_data, metadata)
