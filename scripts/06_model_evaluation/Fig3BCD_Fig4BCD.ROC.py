import numpy as np
import pandas as pd
from pandas.plotting import scatter_matrix
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns   #绘图函数
from scipy import stats
from sklearn.model_selection import train_test_split,learning_curve, validation_curve, cross_val_score,GridSearchCV
from sklearn.model_selection import cross_validate
from sklearn.metrics import f1_score
from sklearn.model_selection import GridSearchCV
from sklearn import preprocessing
from sklearn.pipeline import Pipeline

#特征选择
from sklearn.feature_selection import SelectKBest, chi2, f_classif,mutual_info_classif

#平衡采样
from imblearn.over_sampling import SMOTE
from imblearn.combine import SMOTEENN
from collections import Counter
    
#模型
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.decomposition import PCA
from sklearn.naive_bayes import BernoulliNB
from sklearn.ensemble import BaggingClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.linear_model import SGDClassifier
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier
#from catboost import CatBoostClassifier

#ROC
from itertools import cycle
from sklearn.metrics import roc_curve, auc,accuracy_score,roc_auc_score,precision_recall_curve, f1_score, precision_score, recall_score
from sklearn.preprocessing import label_binarize
from sklearn.model_selection import RepeatedStratifiedKFold
#from sklearn.metrics import roc_curve, auc, precision_recall_curve
from sklearn.base import clone

#可视化
from sklearn.metrics import confusion_matrix
#import plotly.express as px  #生成热图
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns   #绘图函数

#保存模型
import joblib
import os
import time
import sys
import argparse
import warnings
warnings.filterwarnings("ignore") #不显示警告




def plot_curves(results_dict, modelname="test"):
    
    # ===== ROC =====
    plt.figure(figsize=(6,6))
    n_curves = len(results_dict)
    custom_colors = ['#e41a1c', '#377eb8', '#4daf4a', '#5F559B',
                    '#ff7f00','#ffff33', '#f781bf', '#31B7BC',
                    '#999999', '#1b9e77','#e7298a', '#e6ab02','#6F286A']
    colors = custom_colors[:n_curves]
    
    for idx, name in enumerate(results_dict):
        fpr, mean, lower, upper = results_dict[name]["roc"]
        auc_label = results_dict[name]["metrics"]["AUC"]
        
        plt.plot(fpr, mean,
                 label=f"{name},{auc_label}",
                 color=colors[idx],
                 linewidth=2,
                 drawstyle='steps-post')
        #加阴影
        #plt.fill_between(fpr, lower, upper, alpha=0.2)
    
    plt.plot([0,1],[0,1],'k--')
    plt.xlabel("False Positive Rate", fontsize=14, fontweight='bold')
    plt.ylabel("True Positive Rate", fontsize=14, fontweight='bold')
    plt.title("ROC Curve (95% CI)", fontsize=14, fontweight='bold')
    plt.legend(loc='lower right', 
               frameon=True, 
               fancybox=True, 
               shadow=True, 
               framealpha=0.9,
               fontsize=11)
    plt.tight_layout()
    plt.savefig(modelname + '_bootstrap_ROC.pdf', dpi=300, bbox_inches="tight")
    plt.savefig(modelname + '_bootstrap_ROC.png', dpi=300)
    plt.close()

    # ===== PR =====
    plt.figure(figsize=(6,6))
    
    for name in results_dict:
        recall, mean, lower, upper = results_dict[name]["pr"]
        pr_label= results_dict[name]["metrics"]["PR_AUC"]
        plt.plot(recall, mean,
                 label=f"{name} PR-AUC {pr_label} ",drawstyle='steps-post')
        #加阴影
        #plt.fill_between(recall, lower, upper, alpha=0.2)
    
    plt.xlabel("Recall")
    plt.ylabel("Precision")
    plt.title("Precision-Recall Curve (95% CI)")
    plt.legend(loc='lower left')
    plt.tight_layout()
    plt.savefig(modelname + '_bootstrap_PR.pdf', dpi=300, bbox_inches="tight")
    plt.savefig(modelname + '_bootstrap_PR.png', dpi=300)
    plt.close()

results_train = joblib.load("results_train.pkl")
plot_curves(results_train,modelname="Train")
