setwd("/home/s4693165/honours/scripts/R")
source("tblup/orm_helper_functions.R")
orm_obj <- ReadORMBin("/scratch/user/s4693165/tblup/trm/cut_1.00_trm_afc_autosome_standard")

diag_vals <- orm_obj$diag
q <- quantile(diag_vals, c(0.25, 0.75))
iqr <- q[2] - q[1]
upper <- q[2] + 3*iqr
lower <- q[1] - 3*iqr
outliers <-which(diag_vals > upper | diag_vals < lower)
print(orm_obj$id[outliers,1])
