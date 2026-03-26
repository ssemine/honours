library(ggplot2)
library(ggrepel)
library(dplyr)

setwd("/home/s4693165/honours/scripts/R")
source("tblup/utils/read_orm.R")

input_file <- "/scratch/user/s4693165/results/initial/efile"
orm_obj <- ReadORMBin("/scratch/user/s4693165/results/initial/trm")
n <- nrow(orm_obj$id)
ORM_mat <- matrix(0, n, n)
diag(ORM_mat) <- orm_obj$diag
ORM_mat[lower.tri(ORM_mat)] <- orm_obj$off
ORM_mat[upper.tri(ORM_mat)] <- t(ORM_mat)[upper.tri(ORM_mat)]
rownames(ORM_mat) <- orm_obj$id[,1]
colnames(ORM_mat) <- orm_obj$id[,1]

input_file <- "/scratch/user/s4693165/results/cut_nocut_3_pca2/efile"
expr <- read.table(input_file, header = TRUE, sep = " ", check.names = FALSE, stringsAsFactors = FALSE)
iid_data <- expr[, 1:2]
gene_expr <- expr[, -c(1,2)]
gene_expr_num <- data.frame(lapply(gene_expr, function(x) as.numeric(trimws(x))))
if (any(is.na(gene_expr_num))) {
  cat("Warning: NAs introduced during conversion. Number of NAs:", sum(is.na(gene_expr_num)), "\n")
  gene_expr_num <- na.omit(gene_expr_num)
}

pca_res <- prcomp(gene_expr_num, center = TRUE, scale. = TRUE)
scores <- data.frame(iid_data, PC1 = pca_res$x[,1], PC2 = pca_res$x[,2])
head(scores)

orm_mean <- rowMeans(ORM_mat)
orm_mean <- rowMeans(ORM_mat)
orm_df <- data.frame(
  iid = rownames(ORM_mat),
  orm_mean = orm_mean
)
colnames(scores)[colnames(scores) == "IID"] <- "iid"

scores2 <- merge(scores, orm_df, by = "iid")
labels_df <- scores2 %>%
  filter(orm_mean > 0.35 | PC1 < -100)

p <- ggplot(scores2, aes(x = PC1, y = PC2, color = orm_mean)) +
  geom_point(size = 2, alpha = 0.5) +
  scale_color_viridis_c( name = "mean TRM") +
  xlab(paste0("PC1 (", round(summary(pca_res)$importance[2,1]*100, 1), "%)")) +
  ylab(paste0("PC2 (", round(summary(pca_res)$importance[2,2]*100, 1), "%)")) +
  ggtitle("PCA of finalised Gene expression") +
  geom_text_repel(
    data = labels_df,
    aes(label = iid),
    size = 3,
    color = "white",       
    bg.color = "black",  
    bg.r = 0.15,         
    box.padding = 0.3,
    point.padding = 0.3,
    max.overlaps = Inf
  ) +
  theme_bw()
print(p)

