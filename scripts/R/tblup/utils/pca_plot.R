# Load necessary library
library(ggplot2)

# Path to your final matrix (IID, FID, Genes)
input_file <- "/scratch/user/s4693165/gene_exp_data/final_matrix.txt"

# Read the data
expr <- read.table(input_file, header = TRUE, sep = "\t", check.names = FALSE)

# Remove IID/FID columns for PCA
gene_expr <- expr[, !(names(expr) %in% c("IID", "FID"))]

# Perform PCA
pca_res <- prcomp(gene_expr, center = TRUE, scale. = TRUE)

# Extract scores for first two PCs
scores <- data.frame(PC1 = pca_res$x[,1], PC2 = pca_res$x[,2])

# Simple scatter plot
ggplot(scores, aes(x = PC1, y = PC2)) +
  geom_point(color = "blue", size = 2) +
  xlab(paste0("PC1 (", round(summary(pca_res)$importance[2,1]*100, 1), "%)")) +
  ylab(paste0("PC2 (", round(summary(pca_res)$importance[2,2]*100, 1), "%)")) +
  ggtitle("PCA of Final Gene Expression Matrix") +
  theme_minimal()