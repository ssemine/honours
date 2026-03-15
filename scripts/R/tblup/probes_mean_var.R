library(ggplot2)
source("/home/s4693165/honours/scripts/R/tblup/config/paths.R")

setwd(working_dir)

mean_path_initial <- file.path(probe_dir, "initial_auto.mean.txt")
var_path_initial  <- file.path(probe_dir, "initial_auto.var.txt")
mean_path_std <- file.path(probe_dir, "std_auto.mean.txt")
var_path_std <- file.path(probe_dir, "std_auto.var.txt")
mean_path_final <- file.path(probe_dir, "final.mean.txt")
var_path_final <- file.path(probe_dir, "final.var.txt")

mean_df_initial <- read.table(mean_path_initial, header = FALSE)
var_df_initial  <- read.table(var_path_initial,  header = FALSE)
mean_df_std <- read.table(mean_path_std, header = FALSE)
var_df_std <- read.table(var_path_std, header = FALSE)
mean_df_final <- read.table(mean_path_final, header=FALSE)
var_df_final <- read.table(var_path_final, header=FALSE)

colnames(mean_df_initial) <- c("probe", "mean")
colnames(var_df_initial)  <- c("probe", "variance")
colnames(mean_df_std) <- c("probe", "mean")
colnames(var_df_std) <- c("probe", "variance")
colnames(mean_df_final) <- c("probe", "mean")
colnames(var_df_final) <- c("probe", "variance")

df_initial <- merge(mean_df_initial, var_df_initial, by = "probe")
df_std <- merge(mean_df_std, var_df_std, by = "probe")
df_final <- merge(mean_df_final, var_df_final, by = "probe")

ggplot(df_final, aes(x = abs(mean), y = variance)) +
  geom_point(alpha = 1, color = "blue") +
  geom_point(data = df_std, aes(x = abs(mean), y = variance), color="red", alpha=0.01) +
  scale_x_log10() +
  labs(
    title = "Mean vs Variance of Probes",
    x = expression(mu),
    y = expression(sigma^2)
  ) +
  theme_bw()

