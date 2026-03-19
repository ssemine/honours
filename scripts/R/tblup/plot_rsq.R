library(tidyverse)

# --- Hardcoded input files ---
input_files <- c(
)

# --- Output file ---
output_file <- "/scratch/user/s4693165/results/herit_plot.pdf"

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
  theme_minimal() +
  scale_x_continuous(breaks = herit_df$Index, labels = herit_df$File) +
  labs(x = "Input file", y = expression(h^2), title = "Heritability (V(O)/Vp) across files") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# --- Save plot ---
ggsave(output_file, p, width = 8, height = 5)

cat("Plot saved to:", output_file, "\n")