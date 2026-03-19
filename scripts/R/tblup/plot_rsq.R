library(tidyverse)

rsq_dir <- "/scratch/user/s4693165/gene_exp_data/final"
rsq_files <- list.files(rsq_dir, pattern = "\\.rsq$", full.names = TRUE)

read_rsq_h2 <- function(f) {
  df <- read.table(f, header = TRUE, sep = "", stringsAsFactors = FALSE, fill = TRUE)
  h2 <- df$Variance[df$Source == "V(O)/Vp"]
  se <- df$SE[df$Source == "V(O)/Vp"]  # optional, for error bars
  trm_cutoff <- gsub(".*_(0\\.[0-9]+)\\.rsq", "\\1", basename(f))
  tibble(File = basename(f),
         trm_cutoff = as.numeric(trm_cutoff),
         h2 = h2,
         SE = se)
}

herit_df <- map_dfr(rsq_files, read_rsq_h2)

# Plot with optional error bars
ggplot(herit_df, aes(x = trm_cutoff, y = h2)) +
  geom_point() +
  geom_line(group = 1) +
  geom_errorbar(aes(ymin = h2 - SE, ymax = h2 + SE), width = 0.01, alpha = 0.5) +
  theme_minimal() +
  labs(title = "Heritability vs TRM cutoff",
       x = "TRM cutoff",
       y = expression(h^2))