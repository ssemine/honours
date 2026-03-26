library(ggplot2)
library(corrplot)

pheno_file <- "/scratch/user/s4693165/pheno_data/iid_filtered_newest_version_phenotypes_Myworkingfile.txt"

df <- read.table(pheno_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
df_encoded <- df

for(col in names(df_encoded)) {
  if(!is.numeric(df_encoded[[col]])) {
    df_encoded[[col]] <- as.numeric(factor(df_encoded[[col]], exclude = NULL))
  }
}
cor_matrix <- cor(df_encoded, use = "pairwise.complete.obs", method = "pearson")

corrplot(cor_matrix, 
         method = "color",   
         type = "upper",    
         order = "hclust",      
         tl.col = "black",  
         addCoef.col = "black", 
         number.cex = 0.7)      