library(ggplot2)

pheno_file <- "/scratch/user/s4693165/pheno_data/iid_pheno.txt"

df <- read.table(pheno_file, header = TRUE, stringsAsFactors = FALSE)

# Encode non-numeric columns
df_encoded <- as.data.frame(lapply(df, function(col) {
  if(!is.numeric(col)) as.numeric(factor(col, exclude = NULL)) else col
}))

cols <- names(df_encoded)
results <- data.frame(col1=character(),
                      col2=character(),
                      correlation=numeric(),
                      pval=numeric(),
                      stringsAsFactors = FALSE)

# Pairwise Spearman correlation with NA-safe handling
for(i in 1:(length(cols)-1)) {
  for(j in (i+1):length(cols)) {
    x <- df_encoded[[i]]
    y <- df_encoded[[j]]
    finite_idx <- is.finite(x) & is.finite(y)
    if(length(unique(x[finite_idx])) > 1 && length(unique(y[finite_idx])) > 1) {
      test <- cor.test(x[finite_idx], y[finite_idx], method = "spearman")
      results <- rbind(results, data.frame(col1=cols[i],
                                           col2=cols[j],
                                           correlation=test$estimate,
                                           pval=test$p.value))
    }
  }
}

results_clean <- results[!is.na(results$correlation), ]

# Make symmetric matrix (duplicate x/y)
results_sym <- rbind(results_clean,
                     data.frame(col1=results_clean$col2,
                                col2=results_clean$col1,
                                correlation=results_clean$correlation,
                                pval=results_clean$pval))

phenotypes <- c("heifer_age_calving")
covariates <- c("adj_FW_kg", 
                "calf_sex",
                "cg",
                "hef_wks_preg",
                "heifer_age_joining",
                "year")     

custom_annotation <- c(
  "heifer_age_calving" = "AFC (days)",
  "adj_FW_kg" = "?",
  "cg" = "Contemporary group",
  "hef_wks_preg" = "Foetal age (weeks)",
  "heifer_age_joining" = "Age of joining (days)",
  "hef_age_at_pregtest" = "?",
  "hef_DTC" = "Days to calving",
  "mate_in_date" = "?",
  "calving_success" = "Calved before 900 days",
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

# Tick labels with optional annotation (no NA in brackets)
x_labels <- sapply(levels(results_sym$col1), function(x) {
  ann <- custom_annotation[x]
  if(!is.null(ann) && !is.na(ann) && ann != "?") paste0(x, " (", ann, ")") else x
})
y_labels <- sapply(levels(results_sym$col2), function(x) {
  ann <- custom_annotation[x]
  if(!is.null(ann) && !is.na(ann) && ann != "?") paste0(x, " (", ann, ")") else x
})

x_colors <- sapply(levels(results_sym$col1), axis_color)
y_colors <- sapply(levels(results_sym$col2), axis_color)

ggplot(results_sym, aes(x = col1, y = col2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(is.na(correlation), "", sprintf("%.2f", correlation))),
            size = 3) +
  scale_fill_gradient2(low = "blue", mid = "lightgray", high = "red",
                       midpoint = 0, na.value = "grey") +
  scale_x_discrete(labels = x_labels) +
  scale_y_discrete(labels = y_labels) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, color = x_colors),
    axis.text.y = element_text(color = y_colors)
  ) +
  labs(x = "", y = "", fill = expression(rho), title = "Phenotype x Covariate Spearman correlation matrix")

ggplot(results_sym, aes(x = col1, y = col2, fill = log10(pval))) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(is.na(pval), "", sprintf("%.1f", log10(pval)))),
            size = 3) +
  scale_fill_gradient(low = "red", high = "white", na.value = "grey") +
  scale_x_discrete(labels = x_labels) +
  scale_y_discrete(labels = y_labels) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, color = x_colors),
    axis.text.y = element_text(color = y_colors)
  ) +
  labs(x = "", y = "", fill = "p-value", 
       title = "Phenotype x Covariate Spearman correlation p-values")
