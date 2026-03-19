# Install data.table if not present
if (!requireNamespace("data.table", quietly = TRUE)) {
  cat("data.table not found, installing...\n")
  install.packages("data.table", repos = "https://cloud.r-project.org")
}

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[which(args == "--input") + 1]
output_file <- args[which(args == "--output") + 1]

cat("Reading input file:", input_file, "\n")
dt <- fread(input_file, header = TRUE, fill = TRUE, data.table = TRUE)

gene_cols <- setdiff(names(dt), c("IID", "FID"))

cat("Applying log2(CPM + 1) transformation in chunks...\n")

chunk_size <- 1000   # number of columns per chunk
for (start in seq(1, length(gene_cols), by = chunk_size)) {
  end <- min(start + chunk_size - 1, length(gene_cols))
  cols_chunk <- gene_cols[start:end]

  dt[, (cols_chunk) := lapply(.SD, function(x) {
    x <- suppressWarnings(as.numeric(x))
    x[is.na(x) | is.nan(x) | is.infinite(x)] <- 0
    log2(x + 1)
  }), .SDcols = cols_chunk]
}

cat("Writing output to:", output_file, "\n")
fwrite(dt, file = output_file, sep = "\t", quote = FALSE, na = "0")
cat("Done!\n")