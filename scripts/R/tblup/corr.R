library(ggplot2)
library(corrplot)

pheno_file <- "/scratch/user/s4693165/pheno_data/iid_pheno_final_pca10.txt"

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
results_clean <- results[!is.na(results$correlation), ]
results_sym <- results_clean
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

# Optional annotation for some columns
custom_annotation <- c(
  "heifer_age_calving" = "AFC (days)",
  "adj_FW_kg" = "?",
  "cg" = "Conteprorary group",
  "hef_wks_preg" = "Foetal age (weeks)",
  "heifer_age_joining" = "Age of joining (days)",
  "hef_age_at_pregtest" = "?",
  "hef_DTC" = "Days to calving",
  "mate_in_date" = "?",
  "calving success" = "Calved before 900 days",
  "class_calving" = "?",
  "mate_group" = "?",
  "year_mate" = "?",
  "date_diff" = "?",
  "hef_preg_success" = "?"
)

axis_color <- function(x) {
  if(x %in% phenotypes) {
    "green"
  } else if(x %in% covariates) {
    "violet"
  } else {
    "black"
  }
}

results_sym$col1 <- factor(results_sym$col1, levels = unique(results_sym$col1))
results_sym$col2 <- factor(results_sym$col2, levels = unique(results_sym$col2))

# Create tick labels only if annotation exists
x_labels <- sapply(levels(results_sym$col1), function(x) {
  if(!is.na(custom_annotation[x])) {
    paste0(x, " (", custom_annotation[x], ")")
  } else {
    x
  }
})
y_labels <- sapply(levels(results_sym$col2), function(x) {
  if(!is.na(custom_annotation[x])) {
    paste0(x, " (", custom_annotation[x], ")")
  } else {
    x
  }
})

x_colors <- sapply(levels(results_sym$col1), axis_color)
y_colors <- sapply(levels(results_sym$col2), axis_color)

ggplot(results_sym, aes(x = col1, y = col2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(is.na(correlation), "", sprintf("%.2f", correlation))),
            size = 3) +
  scale_fill_gradient2(low = "blue", mid = "lightgray", high = "red", midpoint = 0, na.value = "grey") +
  #scale_x_discrete(labels = x_labels) +
  #scale_y_discrete(labels = y_labels) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, color = x_colors),
    axis.text.y = element_text(color = y_colors)
  ) +
  labs(x = "", y = "", fill = expression(~r^2), title = "Phenotype x Covariate correlation matrix")

