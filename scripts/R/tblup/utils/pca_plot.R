# Load necessary library
library(ggplot2)

# Path to your final matrix (IID, FID, Genes)
# Path to your final matrix (IID, FID, Genes)
input_file <- "/scratch/user/s4693165/gene_exp_data/test.txt"

# Read the data
expr <- read.table(input_file, header = TRUE, sep = " ", check.names = FALSE, stringsAsFactors = FALSE)

# Separate IID/FID from expression data
iid_data <- expr[, 1:2]   # Columns 1 and 2 are IID/FID
gene_expr <- expr[, -c(1,2)]  # Remaining columns

# Ensure all gene expression columns are numeric
gene_expr_num <- data.frame(lapply(gene_expr, function(x) as.numeric(trimws(x))))

# Check for conversion problems
if (any(is.na(gene_expr_num))) {
  cat("Warning: NAs introduced during conversion. Number of NAs:", sum(is.na(gene_expr_num)), "\n")
  # Optionally, remove rows with NA
  gene_expr_num <- na.omit(gene_expr_num)
}

# Perform PCA
pca_res <- prcomp(gene_expr_num, center = TRUE, scale. = TRUE)

# Extract first two PCs
scores <- data.frame(iid_data, PC1 = pca_res$x[,1], PC2 = pca_res$x[,2])
head(scores)

# Simple scatter plot
p <- ggplot(scores, aes(x = PC1, y = PC2)) +
  geom_point(color = "blue", size = 2) +
  xlab(paste0("PC1 (", round(summary(pca_res)$importance[2,1]*100, 1), "%)")) +
  ylab(paste0("PC2 (", round(summary(pca_res)$importance[2,2]*100, 1), "%)")) +
  ggtitle("PCA of Final Gene Expression Matrix") +
  theme_minimal()

o1 <- "~/honours/data/plots/tblup/pca_dis.png"
ggsave(o1, p, width = 8, height = 5)