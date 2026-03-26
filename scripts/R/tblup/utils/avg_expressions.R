library(ggplot2)
library(dplyr)
library(tidyr)

setwd("/scratch/user/s4693165/results/cut_nocut_3_pca2")

# -------------------------------
# Step 1: Load expression file
# -------------------------------
expr <- read.table("efile", header = TRUE, sep = " ", check.names = FALSE)

# -------------------------------
# Step 2: Load gene annotation file
# -------------------------------
oii <- read.table("final_befile.opi", header = FALSE, stringsAsFactors = FALSE)
oii <- oii[, c(1,2,3,5)]
colnames(oii) <- c("chr", "gene_id", "pos", "strand")

# -------------------------------
# Step 3: Keep only genes in expr
# -------------------------------
gene_ids <- colnames(expr)[-c(1,2)]  # skip FID IID
oii_sub <- oii[oii$gene_id %in% gene_ids, ]
oii_sub <- oii_sub[match(gene_ids, oii_sub$gene_id), ]  # same order as expr columns
stopifnot(all(oii_sub$gene_id == colnames(expr)[-c(1,2)]))

# -------------------------------
# Step 4: Pivot to long format
# -------------------------------
gene_expr_long <- expr %>%
  pivot_longer(
    cols = -c(FID, IID),
    names_to = "gene_id",
    values_to = "expression"
  ) %>%
  rename(fid = FID, iid = IID)

# -------------------------------
# Step 5: Merge chromosome info
# -------------------------------
gene_expr_long <- gene_expr_long %>%
  left_join(oii_sub[, c("gene_id", "chr")], by = "gene_id")

# -------------------------------
# Step 6: Compute mean expression per individual per chromosome
# -------------------------------
chr_expr <- gene_expr_long %>%
  group_by(iid, chr) %>%
  summarise(mean_expr = mean(expression, na.rm = TRUE), .groups = "drop")

# Optional: order chromosomes
desired_order <- c(as.character(1:29), "X", "Y")
chr_expr$chr <- factor(chr_expr$chr, levels = desired_order)

subset_iids <- c("15-3026", 
                 "15-2694", 
                 "15-3063",
                 "15-3154",
                 "15-21907",
                 "15-2845",
                 "15-2589",
                 "15-30-17",
                 "04-2467") 

label_positions <- chr_expr %>%
  filter(iid %in% subset_iids) %>%
  group_by(iid) %>%
  summarise(y_pos = max(mean_expr, na.rm = TRUE) + 0.2, .groups = "drop")

ggplot(chr_expr, aes(x = iid, y = mean_expr)) +
  geom_boxplot(aes(group = chr), alpha = 0.5, outlier.shape = NA) +
  geom_jitter(aes(color = chr), width = 0.2, alpha = 0.7, size = 1) +
  geom_text(data = label_positions, aes(x = iid, y = y_pos, label = iid),
            angle = 45, hjust = 0, size = 3, color = "black") +
  theme_bw() +
  labs(x = "Individual", y = "Mean Gene Expression per Chromosome", color = "Chromosome") +
  ggtitle("Average Gene Expression per Chromosome per Individual") +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )

