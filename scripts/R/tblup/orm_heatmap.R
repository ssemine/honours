library(ggplot2)
library(reshape2)
library(pheatmap)

# NEED SERIOUS REWORKING


setwd("/home/s4693165/honours/scripts/R")
source("tblup/utils/read_orm.R")

# ORM matrix initialisation
orm_obj <- ReadORMBin("/scratch/user/s4693165/results/cut_0.75_5/trm")
n <- nrow(orm_obj$id)
ORM_mat <- matrix(0, n, n)
diag(ORM_mat) <- orm_obj$diag
ORM_mat[lower.tri(ORM_mat)] <- orm_obj$off
ORM_mat[upper.tri(ORM_mat)] <- t(ORM_mat)[upper.tri(ORM_mat)]
rownames(ORM_mat) <- orm_obj$id[,1]
colnames(ORM_mat) <- orm_obj$id[,1]

# Off-diagonals distribution
relatedness_values <- ORM_mat[lower.tri(ORM_mat, diag = FALSE)]
df <- data.frame(relatedness = relatedness_values)
p1 <- ggplot(df, aes(x = relatedness)) +
  geom_histogram(bins = n, fill = "black", color = "blue") +
  theme_bw() +
  labs(
    x = "TRM off-diagonal values",
    y = "Count",
    title = "Distribution of TRM off-diagonal values"
  )

diag_vals <- orm_obj$diag
df <- data.frame(diag_vals = diag_vals)


p2 <- ggplot(df, aes(x = diag_vals)) +
  geom_histogram(
    bins = 100,
    fill = "black",
    color = "black"
  ) +
theme_minimal() +
labs(
  x = "ORM diagonal values",
  y = "Count",
  title = "TRM diagonal values distribtuion"
) +
scale_x_continuous(
  breaks = seq(0, max(diag_vals), by = 0.1)  # set x-axis ticks every 0.1
) +
scale_y_continuous(
  breaks = seq(0, 8, by = 1)
) +
  theme_bw()


p3 <- pheatmap(
  ORM_mat,
  #color = colorRampPalette(c("blue", "white", "red"))(100),
  show_rownames = FALSE,
  show_colnames = FALSE,
  main = "TRM Heatmap",
  clustering_method = "complete",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  border_color = NA
)
library(pheatmap)

# Set font to Times New Roman
par(family = "Times")

p3 <- pheatmap(
  ORM_mat,
  color = colorRampPalette(c("blue", "white", "red"))(100),
  show_rownames = FALSE,
  show_colnames = FALSE,
  main = "TRM Heatmap",
  clustering_method = "complete",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  border_color = NA,
  
  # Legend control
  legend = TRUE,
  legend_breaks = seq(min(ORM_mat), max(ORM_mat), length.out = 5),
  legend_labels = round(seq(min(ORM_mat), max(ORM_mat), length.out = 5), 2),
  
  # Axis labels
  labels_row = rownames(ORM_mat),
  labels_col = colnames(ORM_mat),
  
  # Font sizes
  fontsize = 12,
  fontsize_row = 10,
  fontsize_col = 10
)
o1 <- "~/honours/data/plots/tblup/offdiag_0.75_nopca.png"
o2 <- "~/honours/data/plots/tblup/diag_0.75_nopca.png"
o3 <- "~/honours/data/plots/tblup/phea_0.75_nopca.png"
ggsave(o1, p1, width = 8, height = 5)
ggsave(o2, p2, width = 8, height = 5)
ggsave(o3, p3, width = 8, height = 5)

