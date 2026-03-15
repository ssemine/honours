# iqr_outliers.R
#
# Identifies outliers in the diagonal of an ORM using the IQR method
# 
# Usage: Rscript iqr_outliers.R <ORM filepath> > <outliers (IID IID) filepath>

source ("/home/s4693165/honours/scripts/R/tblup/config/paths.R")
source(read_orm_path)

setwd(working_dir)

args <- commandArgs(trailingOnly = TRUE)
orm_path <- args[1]
orm_obj <- ReadORMBin(orm_path)

diag_vals <- orm_obj$diag
q <- quantile(diag_vals, c(0.25, 0.75))
iqr <- q[2] - q[1]
upper <- q[2] + 3*iqr
lower <- q[1] - 3*iqr
outliers <-which(diag_vals > upper | diag_vals < lower)

write.table(
    cbind(orm_obj$id[outliers,1], orm_obj$id[outliers,1]),
    file = "",
    row.names = FALSE,
    col.names = FALSE,
    quote = FALSE
)