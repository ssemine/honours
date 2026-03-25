# Load required libraries
library(ggplot2)
library(dplyr)
library(stringr)

# Set base directory
base_dir <- "/scratch/user/s4693165/results"  # change if needed

# Get directories, exclude *_pca1
dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
#dirs <- dirs[!grepl("_pca1$", dirs)]

# Storage
all_data <- data.frame()

for (d in dirs) {
  
  sol_file <- file.path(d, "sol.rsq")
  if (!file.exists(sol_file)) next
  
  # Robust read
  df <- tryCatch({
    read.table(
      sol_file,
      header = TRUE,
      sep = "",                 # auto-detect whitespace
      fill = TRUE,              # handle uneven rows
      strip.white = TRUE,
      stringsAsFactors = FALSE,
      comment.char = "",
      blank.lines.skip = TRUE
    )
  }, error = function(e) {
    message("Skipping (read error): ", sol_file)
    return(NULL)
  })
  
  if (is.null(df)) next
  
  # Ensure required columns exist
  if (!all(c("Source", "Variance", "SE") %in% colnames(df))) {
    message("Skipping (bad format): ", sol_file)
    next
  }
  
  # Clean possible whitespace issues
  df$Source <- trimws(df$Source)
  
  # Extract V(O)/Vp row
  vo_row <- df[df$Source == "V(O)/Vp", ]
  if (nrow(vo_row) == 0) {
    message("Skipping (no V(O)/Vp): ", sol_file)
    next
  }
  
  # Parse directory name
  dir_name <- basename(d)
  parts <- unlist(strsplit(dir_name, "_"))
  
  # Safety check
  if (length(parts) < 3) {
    message("Skipping (unexpected dir name): ", dir_name)
    next
  }
  
  cut_val <- suppressWarnings(as.numeric(parts[2]))
  if (is.na(cut_val)) {ß
    message("Skipping (bad cut value): ", dir_name)
    next
  }
  
  group_val <- paste(parts[-c(1,2)], collapse = "_")
  
  # Append
  all_data <- rbind(all_data, data.frame(
    cut = cut_val,
    group = group_val,
    variance = as.numeric(vo_row$Variance[1]),
    se = as.numeric(vo_row$SE[1])
  ))
}

# Remove any NA rows just in case
all_data <- na.omit(all_data)

# Sort for nicer plotting
all_data <- all_data %>%
  arrange(group, cut)

# Factor for consistent legend ordering
all_data$group <- factor(all_data$group, levels = unique(all_data$group))
group_labels <- c(
  "3" = "CG",
  "5" = "Joining age",
  "7" = "Foetal age",
  "3_5" = "CG + Joining Age",
  "3_7" = "CG + Foetal age",
  "5_7" = "Joining Age",
  "3_5_7" = "CG+Joining age+Foetal age"
)
all_data$group_label <- group_labels[as.character(all_data$group)]

# Make it a factor for consistent ordering
all_data$group_label <- factor(all_data$group_label, levels = unique(group_labels))
# Plot
# Plot using the descriptive labels
p <- ggplot(all_data, aes(x = cut, y = variance, color = group_label)) +
  geom_point(size = 2.5) +
  geom_line(aes(group = group_label), linewidth = 0.8) +
  geom_errorbar(aes(ymin = variance - se, ymax = variance + se),
                width = 0.01, linewidth = 0.5) +
  labs(
    x = "Cut",
    y = "V(O)/Vp",
    color = "Component",
    title = "V(O)/Vp vs Cut"
  ) +
  theme_bw(base_size = 14)

print(p)

