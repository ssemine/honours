setwd("/home/s4693165/honours/scripts/R")
source("/home/s4693165/honours/scripts/R/tblup/orm_helper_functions.R")

args <- commandArgs(trailingOnly = TRUE)
orm_path <- args[1]
orm_obj <- ReadORMBin(orm_path)

diag_vals <- orm_obj$diag
q <- quantile(diag_vals, c(0.25, 0.75))
iqr <- q[2] - q[1]
upper <- q[2] + 3*iqr
lower <- q[1] - 3*iqr
outliers <-which(diag_vals > upper | diag_vals < lower)
cat(orm_obj$id[outliers,1], orm_obj$id[outliers,1], sep=" ", fill=TRUE)