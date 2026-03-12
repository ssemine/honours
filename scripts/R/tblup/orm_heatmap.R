library(ggplot2)
library(reshape2)
library(pheatmap)

setwd("/home/s4693165/honours/scripts/R")
source("tblup/orm_helper_functions.R")

# ORM matrix initialisation
orm_obj <- ReadORMBin("/scratch/user/s4693165/tblup/trm/cut_1.00_trm_std_standard")
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
  geom_histogram(bins = n, fill = "steelblue", color = "black") +
  theme_minimal() +
  labs(
    x = "TRM off-diagonal values",
    y = "Count",
    title = "Distribution of TRM off-diagonal values"
  )

diag_vals <- orm_obj$diag
df <- data.frame(diag_vals = diag_vals)
p2 <- ggplot(df, aes(x = diag_vals)) +
  geom_histogram(
    bins = n,
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
  breaks = seq(0, 2, by = 0.1)  # set x-axis ticks every 0.1
) +
scale_y_continuous(
  breaks = seq(0, 8, by = 1)
)


# GRM Heatmap (Unsorted)
df <- melt(ORM_mat)
colnames(df) <- c("Individual1", "Individual2", "Value")
df$Individual1 <- factor(df$Individual1, levels = ordered_inds)
df$Individual2 <- factor(df$Individual2, levels = ordered_inds)
p3 <- ggplot(df, aes(x = Individual1, y = Individual2, fill = Value)) +
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


# Import phenotype file for sorting
iid_pheno_path="/scratch/user/s4693165/pheno_data/iid_filtered_newest_version_phenotypes_Myworkingfile.txt"
iid_pheno <- read.table(iid_pheno_path, header=TRUE)
order_ids <- iid_pheno$iid[order(iid_pheno$hef_wks_preg)]
order_ids <- df$Individual1[order(df$relatedness)]
# GRM Heatmap (Sorted)
df <- melt(ORM_mat)
colnames(df) <- c("Individual1", "Individual2", "Value")
df$Individual1 <- factor(df$Individual1, levels = order_ids)
df$Individual2 <- factor(df$Individual2, levels = order_ids)


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







mat <- xtabs(Value ~ Individual1 + Individual2, data = df)
hc <- hclust(as.dist(1 - mat))
order_ids <- rownames(mat)[hc$height]
df$Individual1 <- factor(df$Individual1, levels = order_ids)
df$Individual2 <- factor(df$Individual2, levels = order_ids)
ggplot(df, aes(x = Individual1, y = Individual2, fill = Value)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    limits = c(min(df$Value), max(df$Value)),
    name = "Transcriptomic relatedness",
    breaks = seq(round(min(df$Value), 1), round(max(df$Value), 1), by = 0.5)
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank()
  ) +
  labs(
    x = paste("Individuals (n =", n, ")"),
    y = paste("Individuals (n =", n, ")"),
    title = "TRM Heatmap (clustered)"
  )


# plot every group
vars <- setdiff(names(iid_pheno), "iid")
for (v in vars) {

  order_ids <- iid_pheno$iid[order(iid_pheno[[v]], na.last = TRUE)]
  order_ids <- intersect(order_ids, unique(df$Individual1))

  df$Individual1 <- factor(df$Individual1, levels = order_ids)
  df$Individual2 <- factor(df$Individual2, levels = order_ids)

  p <- ggplot(df, aes(x = Individual1, y = Individual2, fill = Value)) +
    geom_tile() +
    scale_fill_gradient2(
      low = "blue",
      mid = "white",
      high = "red",
      limits = c(min(df$Value), max(df$Value)),
      name = "Transcriptomic relatedness",
      breaks = seq(round(min(df$Value),1), round(max(df$Value),1), by = 0.5)
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank()
    ) +
    labs(
      x = paste("Individuals (n =", n, ")"),
      y = paste("Individuals (n =", n, ")"),
      title = paste("TRM Heatmap ordered by", v)
    )

  ggsave(
    paste0("~/honours/data/plots/tblup/TRM_heatmap_ordered_by_", v, ".png"),
    plot = p,
    width = 8,
    height = 8
  )
}

ggsave(filename = "~/honours/data/plots/tblup/trm_off_d_dis.png",
       plot = p1,
       width = 10,
       height = 6,
       dpi = 300)
ggsave(filename = "~/honours/data/plots/tblup/trm_d_dis.png",
       plot = p2,
       width = 10,      # width in inches
       height = 6,      # height in inches
       dpi = 300)       # resolution
ggsave(filename = "~/honours/data/plots/tblup/trm_heart.png",
       plot = p3,
       width = 10,      # width in inches
       height = 6,      # height in inches
       dpi = 300)       # resolution
