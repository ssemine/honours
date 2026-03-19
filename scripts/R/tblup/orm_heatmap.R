library(ggplot2)
library(reshape2)
library(pheatmap)

# NEED SERIOUS REWORKING


setwd("/home/s4693165/honours/scripts/R")
source("tblup/utils/read_orm.R")

# ORM matrix initialisation
<<<<<<< HEAD
orm_obj <- ReadORMBin("/scratch/user/s4693165/gene_exp_data/final/final_trm_std")
=======
orm_obj <- ReadORMBin("/scratch/user/s4693165/tblup/trm/final_trm")
>>>>>>> fixed_bod_pipeline
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
<<<<<<< HEAD
ggplot(df, aes(x = relatedness)) +
  geom_histogram(bins = n, fill = "steelblue", color = "black") +
  theme_minimal() +
=======
p1 <- ggplot(df, aes(x = relatedness)) +
  geom_histogram(bins = n, fill = "black", color = "blue") +
  theme_bw() +
>>>>>>> fixed_bod_pipeline
  labs(
    x = "TRM off-diagonal values",
    y = "Count",
    title = "Distribution of TRM off-diagonal values"
  )

diag_vals <- orm_obj$diag
df <- data.frame(diag_vals = diag_vals)
<<<<<<< HEAD
ggplot(df, aes(x = diag_vals)) +
=======


p2 <- ggplot(df, aes(x = diag_vals)) +
>>>>>>> fixed_bod_pipeline
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

<<<<<<< HEAD
# GRM Heatmap (Unsorted)
df <- melt(ORM_mat)
colnames(df) <- c("Individual1", "Individual2", "Value")
df$Individual1 <- factor(df$Individual1, levels = ordered_inds)
df$Individual2 <- factor(df$Individual2, levels = ordered_inds)
ggplot(df, aes(x = Individual1, y = Individual2, fill = Value)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",      # low relatedness
    mid = "white",     # midpoint
    high = "red",      # high relatedness
    limits = c(min(df$Value), max(df$Value)),  # ensures legend matches data
    name = "Transcriptomic relatedness",
    breaks = seq(round(min(df$Value), 1), round(max(df$Value), 1), by = 0.5)# legend title
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),   # remove x-axis labels
    axis.text.y = element_blank(),   # remove y-axis labels
    axis.ticks = element_blank()     # remove tick marks
  ) +
  labs(
    x = paste("Individuals (n =", n, ")"),
    y = paste("Individuals (n =", n, ")"),
    title = "TRM Heatmap"
  )
=======
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
p4
>>>>>>> fixed_bod_pipeline

