library(ggplot2)
library(corrplot)

pheno_file <- "/scratch/user/s4693165/pheno_data/filtered_newest_version_phenotypes_Myworkingfile.txt"

df <- read.table(pheno_file, header = TRUE, stringsAsFactors = FALSE)
df_encoded <- as.data.frame(lapply(df, function(col) {
  if(!is.numeric(col)) as.numeric(factor(col, exclude = NULL)) else col
}))
cols <- names(df_encoded)
results <- data.frame(col1=character(), col2=character(), correlation=numeric(), stringsAsFactors = FALSE)
for(i in 1:(length(cols)-1)) {
  for(j in (i+1):length(cols)) {
    x <- df_encoded[[i]]
    y <- df_encoded[[j]]
    finite_idx <- is.finite(x) & is.finite(y)
    if(sum(finite_idx) >= 2) {
      cor_val <- cor(x[finite_idx], y[finite_idx], method = "pearson")
      results <- rbind(results, data.frame(col1=cols[i], col2=cols[j], correlation=cor_val))
    }
  }
}
results
results_clean <- results[!is.na(results$correlation), ]
results_sym <- subset(results_clean, col1 != "barcode" & col2 != "barcode")
results_sym <- rbind(
  results_sym,
  data.frame(col1 = results_sym$col2, col2 = results_sym$col1, correlation = results_sym$correlation)
)
phenotypes <- c("heifer_age_calving")
covariates <- c("adj_FW_kg", 
                "calf_sex",
                "cg",
                "hef_wks_preg",
                "heifer_age_joining",
                "year")     
axis_color <- function(x) {
  if(x %in% phenotypes) {
    "green"
  } else if(x %in% covariates) {
    "red"
  } else {
    "black"
  }
}
x_colors <- sapply(levels(factor(results_sym$col1)), axis_color)
y_colors <- sapply(levels(factor(results_sym$col2)), axis_color)
ggplot(results_sym, aes(x = col1, y = col2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(is.na(correlation), "", sprintf("%.2f", correlation))),
            size = 3) +
  scale_fill_gradient2(low = "blue", mid = "lightgray", high = "red", midpoint = 0, na.value = "grey") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, color = x_colors),
    axis.text.y = element_text(color = y_colors)
  ) +
  labs(x = "", y = "", fill = expression(~r^2), title = "Phenotype x Covariate correlation matrix")

