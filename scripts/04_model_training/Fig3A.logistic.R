library(glmnet)
library(pROC)
library(argparser)
library(data.table)
library(caret)
library(stringr)
library(dplyr)
set.seed(1234)
train<-fread(exp_file, sep='\t',header=T,check.names=F)
allusegene<-fread(gene_file, sep='\t',header=F,check.names=F)$V1

data_list=list()
for (each in allusegene){
  print(each)
  formula <- reformulate(each, response = "group")
  model <- glm(formula, data = train, family = binomial())
  model_sum = summary(model)
  stats = model_sum$coefficients 
  beta = stats[,1]
  
  OR <- exp(beta) 
  beta <- stats[,1]
  SE   <- stats[,2]
  CI_low <- exp(beta - 1.96*SE)
  CI_high <- exp(beta + 1.96*SE)
  CI <- paste0(CI_low,'-',CI_high)
  P <- round(stats[,4],2) #提取P值
  train$prob <- predict(model,newdata=train,type="response")
  roc_curve<-roc(train$group,train$prob)
  roc_curve<-roc(train$group,train$prob,direction="<")
  unique_glm_model <- data.frame('Characteristics'=each,
                              'Odds_Ratio' = OR,
                              'CI_95' = CI,
                              'OR_low'=CI_low,
                              'OR_high'=CI_high,
                              'Pvalue' = P,
                              'Model_Cindex'=round(roc_curve$auc,3))[-1,]
  data_list[[each]] = unique_glm_model

}

data = Reduce(rbind, data_list)
data<-as.data.frame(data)
fwrite(data, file=paste0("./",prefix,"/",prefix, '_modeldata_logistic_single.xls'),sep='\t',quote=F)
