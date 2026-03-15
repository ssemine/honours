source("/home/s4693165/honours/scripts/R/tblup/config/paths.R")

setwd(working_dir)

mean_path <- file.path(probe_dir, "probes.mean.txt")
var_path  <- file.path(probe_dir, "probes.var.txt")

mean_df <- read.table(mean_path, header = FALSE)
var_df  <- read.table(var_path,  header = FALSE)

colnames(mean_df) <- c("probe", "mean")
colnames(var_df)  <- c("probe", "variance")

df <- merge(mean_df, var_df, by = "probe")

library(ggplot2)

ggplot(df, aes(x = mean, y = variance)) +
  geom_point(alpha = 0.3, color = "blue") +
  scale_x_log10() +                       
  scale_y_log10() +                         
  labs(
    title = "Mean vs Variance of Probes",
    x = "Mean expression (log10)",
    y = "Variance of expression (log10)"
  ) +
  theme_minimal()