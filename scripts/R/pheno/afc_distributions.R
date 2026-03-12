library(ggplot2)
library(tidyr)
library(dplyr)
setwd("/home/s4693165/honours/scripts/R")
file_path <- "/scratch/user/s4693165/pheno_data/filtered_newest_version_phenotypes_Myworkingfile.txt"
df <- read.table(file_path, header = TRUE, sep = "", stringsAsFactors = FALSE)

p1 <- ggplot(df, aes(x = heifer_age_calving)) + 
  geom_histogram(binwidth = 5,
                 fill = "black",
                 color = "black") +
  theme_minimal() +
  labs(
    title="AFC distribution",
    x="Age at First calf (days)",
    y="Count"
  )

# visualising afc vs wks_preg
p2 <- ggplot(df, aes(x = heifer_age_calving, y = hef_wks_preg)) +
  geom_hex(bins=20) +
  theme_minimal() +
  labs(
    title="Hexmap of AFC vs pregnancy duration",
    x="Age at First calf (days)",
    y="Pregnancy duration (weeks)"
  )

ggsave(filename = "~/honours/data/plots/pheno/afc_dis.png",
       plot = p1,
       width = 10,      # width in inches
       height = 6,      # height in inches
       dpi = 300) 
ggsave(filename = "~/honours/data/plots/pheno/hex_afc_wks.png",
       plot = p2,
       width = 10,      # width in inches
       height = 6,      # height in inches
       dpi = 300) 
  
