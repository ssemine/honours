if (!requireNamespace("data.table", quietly = TRUE)) {
  cat("data.table not found, installing...\n")
  install.packages("data.table", repos = "https://cloud.r-project.org")
}

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_file <- NULL
output_file <- NULL

i <- 1
while (i <= length(args)) {
  if (args[i] == "--input") {
    input_file <- args[i + 1]
    i <- i + 2
  } else if (args[i] == "--output") {
    output_file <- args[i + 1]
    i <- i + 2
  } else {
    stop(paste("Unknown argument:", args[i]))
  }
}

if (is.null(input_file) || is.null(output_file)) {
  stop("Usage: Rscript log2_cpm.R --input input_file.txt --output output_file.txt")
}

cat("Reading input file:", input_file, "\n")
dt <- fread(input_file, sep = " ", header = TRUE, fill = TRUE, data.table = TRUE)

gene_cols <- setdiff(names(dt), c("IID", "FID"))

cat("Applying log2(CPM + 1) transformation...\n")
dt[, (gene_cols) := lapply(.SD, function(x) {
  x <- as.numeric(x)
  x[is.na(x)] <- 0
  log2(x + 1)
}), .SDcols = gene_cols]

cat("Writing output to:", output_file, "\n")
fwrite(dt, output_file, sep = " ")

cat("Done!\n")