# Install data.table if needed (optional, not used for PCA here)
if (!requireNamespace("data.table", quietly = TRUE)) {
  install.packages("data.table", repos = "https://cloud.r-project.org")
}

args <- commandArgs(trailingOnly = TRUE)

# Parse command-line arguments
input_file <- NULL
pc1_thresh <- NULL

i <- 1
while (i <= length(args)) {
  if (args[i] == "--input") {
    input_file <- args[i + 1]
    i <- i + 2
  } else if (args[i] == "--thresh") {
    pc1_thresh <- as.numeric(args[i + 1])
    i <- i + 2
  } else {
    stop(paste("Unknown argument:", args[i]))
  }
}

if (is.null(input_file) || is.null(pc1_thresh)) {
  stop("Usage: Rscript pca_filter.R --input input_file.txt --thresh 1.5")
}

# Read data
expr <- read.table(input_file, header = TRUE, sep = " ", check.names = FALSE, stringsAsFactors = FALSE)

# Separate IID/FID from expression columns
iid_data <- expr[, 1:2]             # IID/FID assumed in first two columns
gene_expr <- expr[, -c(1,2)]        # Remaining columns are expression

# Convert all gene expression values to numeric
gene_expr_num <- data.frame(lapply(gene_expr, function(x) as.numeric(trimws(x))))

# Warn if NAs were introduced
if (any(is.na(gene_expr_num))) {
  cat("Warning:", sum(is.na(gene_expr_num)), "NAs introduced during conversion\n")
}

# Perform PCA
pca_res <- prcomp(gene_expr_num, center = TRUE, scale. = TRUE)

# Extract PC1 scores
pc1_scores <- pca_res$x[,1]

# Select IIDs below threshold
filtered_iids <- iid_data[pc1_scores < pc1_thresh, 1, drop = FALSE]

# Output IID IID pairs to stdout (no header)
write.table(
  cbind(filtered_iids[,1], filtered_iids[,1]),
  file = "",
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE,
  sep = "\t"
)