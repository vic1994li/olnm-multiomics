library(data.table)
library(tidyverse)
library(argparser)
library(glmnet)
library(caret)
library(randomForest)

label_colname<-"group"
count=100
data = fread(data_file, sep = "\t",header=T)
data = as.data.frame(data)

df_feature = fread(feature_file, sep = "\t")
colnames(df_feature)[1] = c('feature')

df = subset(data,select = c(label_colname,df_feature$feature))
#mRMR 筛选特征
mRMR_filter_feature <- function(df){
    library(mRMRe)
    df <- as.data.frame(df) 
    df[] <- lapply(df, function(x) {
      if (is.factor(x)) {
        as.numeric(as.character(x))
      } else {
        as.numeric(x)
      }
    })

    data_mrmr <- mRMR.data(data =df)
    res <- mRMR.classic(
      data = data_mrmr,
      target_indices = 1,
      feature_count = count 
    )

    selected_index <- solutions(res)[[1]]
    feature_names <- featureNames(data_mrmr)

    selected_feature <- feature_names[selected_index]
    return(selected_feature)
}

mRMRresult<-mRMR_filter_feature(df)
mRMRresult_df <- data.frame(feature = mRMRresult)
fwrite(mRMRresult_df,"mRMRresult.xls",sep="\t",quote=F,row.names=F)
