library(ggplot2)
source("/home/s4693165/honours/scripts/R/tblup/config/paths.R")

setwd(working_dir)

mean_path_initial <- file.path(probe_dir, "initial_auto.mean.txt")
var_path_initial  <- file.path(probe_dir, "initial_auto.var.txt")
mean_path_final <- file.path(probe_dir, "final.mean.txt")
var_path_final <- file.path(probe_dir, "final.var.txt")

mean_df_initial <- read.table(mean_path_initial, header = FALSE)
var_df_initial  <- read.table(var_path_initial,  header = FALSE)
mean_df_final <- read.table(mean_path_final, header=FALSE)
var_df_final <- read.table(var_path_final, header=FALSE)

colnames(mean_df_initial) <- c("probe", "mean")
colnames(var_df_initial)  <- c("probe", "variance")
colnames(mean_df_final) <- c("probe", "mean")
colnames(var_df_final) <- c("probe", "variance")

df_initial <- merge(mean_df_initial, var_df_initial, by = "probe")
df_final <- merge(mean_df_final, var_df_final, by = "probe")

ggplot(df_initial, aes(x = mean, y = variance)) +
  geom_point(alpha = 0.3, color = "blue") +
  geom_point(data = df_final, aes(x = mean, y = variance), color="red", alpha=0.5) +
  labs(
    title = "Mean vs Variance of Probes",
    x = expression(mu),
    y = expression(sigma^2)
  ) +
  theme_bw()

