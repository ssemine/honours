library(ggplot2)

pheno_file <- "/scratch/user/s4693165/pheno_data/iid_pheno.txt"

df <- read.table(pheno_file, header = TRUE, stringsAsFactors = FALSE)

# Encode non-numeric columns
df_encoded <- as.data.frame(lapply(df, function(col) {
  if(!is.numeric(col)) as.numeric(factor(col, exclude = NULL)) else col
}))


ggplot(df_encoded, aes(x = heifer_age_joining)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black", alpha = 0.7) +
  theme_bw() +
  labs(
    x = "Joining age (days)",
    y = "Count",
    title = "Histogram"
  )

