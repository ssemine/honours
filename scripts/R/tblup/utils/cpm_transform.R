# Install data.table if not present
if (!requireNamespace("data.table", quietly = TRUE)) {
  cat("data.table not found, installing...\n")
  install.packages("data.table", repos = "https://cloud.r-project.org")
}

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[which(args == "--input") + 1]
output_file <- args[which(args == "--output") + 1]

cat("Processing file:", input_file, "\n")

# Read only metadata (IID, FID)
meta <- fread(input_file, select = c("IID", "FID"), header = TRUE, data.table = TRUE)

# Get all column names to determine gene columns
all_cols <- names(fread(input_file, nrows = 0))
gene_cols <- setdiff(all_cols, c("IID", "FID"))

# Chunk parameters
chunk_size <- 1000
first_chunk <- TRUE

cat("Transforming genes in chunks of", chunk_size, "columns...\n")

for (start in seq(1, length(gene_cols), by = chunk_size)) {
  end <- min(start + chunk_size - 1, length(gene_cols))
  cols_chunk <- gene_cols[start:end]

  # Read only current chunk + metadata
  dt_chunk <- fread(input_file, select = c("IID", "FID", cols_chunk), header = TRUE, data.table = TRUE)

  # Apply log2(CPM + 1) transformation to gene columns
  dt_chunk[, (cols_chunk) := lapply(.SD, function(x) {
    x <- suppressWarnings(as.numeric(x))
    x[is.na(x) | is.nan(x) | is.infinite(x)] <- 0
    log2(x + 1)
  }), .SDcols = cols_chunk]

  # Append to output file
  fwrite(
    dt_chunk,
    file = output_file,
    sep = "\t",
    quote = FALSE,
    na = "0",
    append = !first_chunk,
    col.names = first_chunk
  )

  first_chunk <- FALSE
  cat("Processed columns", start, "to", end, "\n")
}

cat("Done! Output written to:", output_file, "\n")