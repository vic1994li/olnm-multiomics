library(MEDIPS)
library(BSgenome.Hsapiens.UCSC.hg19)
library(dplyr)
BSgenome="BSgenome.Hsapiens.UCSC.hg19"
uniq=1e-3
extend=300
shift=0
chr.select <- paste0("chr", c(1:22, "X", "Y", "M"))
ws=300
outdir<-"./"

bamdir<-"/data/bam"
bam.jan2020 <- list.files(file.path(bamdir), "*.sort.bam", full.names = TRUE)
bam.jan2020
# create medip objects
medip.jan2020 = lapply(bam.jan2020, function(x) {
	MEDIPS.createSet(file = x,BSgenome = BSgenome, extend = extend, shift = shift, uniq = uniq,window_size = ws, chr.select = chr.select, paired = TRUE)
  	}
)
samp_name <- sapply(medip.jan2020, function(x) x@sample_name)
saveRDS(medip.jan2020, file = file.path(outdir, "MEDIPS_10samples.rds"))

## For CpG density dependent normalization of MeDIP-seq data, we need to generate a coupling set. The coupling set must be created based on the same reference genome, the same set of chromosomes, and with the same window size used for the MEDIPS SETs. 
medip.jan2020[[1]]
CS = MEDIPS.couplingVector(pattern = "CG", refObj = medip.jan2020[[1]])
#count/rpm
mr.edgeR = MEDIPS.meth(MSet1 = medip.jan2020, CSet = CS, p.adj = "BH", diff.method = "edgeR",chr =chr.select)
saveRDS(mr.edgeR,"edgeR.rds")

