library(tidyverse)

# --- Hardcoded input files ---
input_files <- c(
  "/scratch/user/s4693165/results/tblup_final_1.00_pca_4.rsq",
  "/scratch/user/s4693165/results/tblup_final_0.75_pca_4.rsq",
  "/scratch/user/s4693165/results/tblup_final_0.5_pca_4.rsq",
  "/scratch/user/s4693165/results/tblup_final_0.25_pca_4.rsq",
  "/scratch/user/s4693165/results/tblup_final_0.1_pca_4.rsq"
)

# --- Output file ---
output_file <- "~/honours/data/plots/tblup/reml_pca_4_nolog_no_pca.png"

# --- Read each .rsq and extract V(O)/Vp ---
herit_df <- map_dfr(input_files, function(f) {
  df <- read.table(f, header = TRUE, sep = "", stringsAsFactors = FALSE, fill = TRUE)
  h2 <- df$Variance[df$Source == "V(O)/Vp"]
  se <- df$SE[df$Source == "V(O)/Vp"]
  tibble(File = basename(f),
         h2 = as.numeric(h2),
         SE = as.numeric(se))
})

# Optional: numeric index for plotting
herit_df <- herit_df %>% mutate(Index = 1:n())

# --- Plot ---
p <- ggplot(herit_df, aes(x = Index, y = h2)) +
  geom_point(size = 3) +
  geom_line(group = 1) +
  geom_errorbar(aes(ymin = h2 - SE, ymax = h2 + SE), width = 0.2, alpha = 0.5) +
  theme_bw() +
  scale_x_continuous(breaks = herit_df$Index, labels = herit_df$File) +
  labs(x = "Input file", y = expression(h^2), title = "V(T)/V(P)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --- Save plot ---
output_file1 <- "~/honours/data/plots/tblup/offdiag_0.75_nolog_nopca.png"
output_file2 <- "~/honours/data/plots/tblup/diag_0.75_nolog_nopca.png"
output_file3 <- "~/honours/data/plots/tblup/phea_0.75_nolog_nopca.png"
ggsave(output_file, p, width = 8, height = 5)

cat("Plot saved to:", output_file, "\n")

