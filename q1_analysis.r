# Load necessary libraries (install them first using install.packages() if you haven't)
library(dplyr)
library(readr)
library(purrr)

#Define the absolute folder path using forward slashes
folder_path <- "D:/projects/Defence_Project/Defence_Dataset"

#Get a list of all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

#Read all files and combine them into one dataframe, creating an 'id' column for the file path
df <- file_list %>%
  set_names() %>%
  map_dfr(read_csv, .id = "File_Path", show_col_types = FALSE) %>%
  #Extract just the ticker symbol from the file path
  mutate(Ticker = gsub(".NS(.*)\\.csv", "", basename(File_Path)))

#Clean the dataset: Remove NAs to avoid calculation errors
df_clean <- na.omit(df)

#Create a custom function to calculate the Mode 
#R does not have a built-in base function for statistical mode
get_mode <- function(v) {
  unique_v <- unique(v)
  unique_v[which.max(tabulate(match(v, unique_v)))]
}
#1 Measures of Central Tendency

#Calculate mean, median, and mode for the 'Close' price across all data
overall_mean <- mean(df_clean$Close)
overall_median <- median(df_clean$Close)
overall_mode <- get_mode(df_clean$Close)

cat("--- Central Tendency (Overall Close Price) ---\n")
cat("Mean:", overall_mean, "\n")
cat("Median:", overall_median, "\n")
cat("Mode:", overall_mode, "\n\n")

#Calculate Central Tendency grouped by Ticker for better contextual understanding
central_tendency_by_ticker <- df_clean %>%
  group_by(Ticker) %>%
  summarise(
    Mean_Close = mean(Close),
    Median_Close = median(Close)
  )

print("--- Central Tendency by Ticker ---")
print(as.data.frame(central_tendency_by_ticker))
#2 Measures of Dispersion

#Calculate range, variance, and standard deviation for 'Close' prices
overall_range <- range(df_clean$Close) #Returns min and max
overall_variance <- var(df_clean$Close)
overall_sd <- sd(df_clean$Close)

cat("\n--- Dispersion (Overall Close Price) ---\n")
cat("Range: Min =", overall_range[1], ", Max =", overall_range[2], "\n")
cat("Range Difference:", diff(overall_range), "\n")
cat("Variance:", overall_variance, "\n")
cat("Standard Deviation:", overall_sd, "\n\n")

#Calculate Dispersion grouped by Ticker to see which stock is most volatile
dispersion_by_ticker <- df_clean %>%
  group_by(Ticker) %>%
  summarise(
    Range_Min = min(Close),
    Range_Max = max(Close),
    Variance = var(Close),
    StdDev = sd(Close)
  )

print("--- Dispersion by Ticker ---")
print(as.data.frame(dispersion_by_ticker))
results <- data.frame(
  Measure = c("Mean", "Median", "Mode",
              "Minimum", "Maximum",
              "Variance", "Standard Deviation"),
  Value = c(
    overall_mean,
    overall_median,
    overall_mode,
    overall_range[1],
    overall_range[2],
    overall_variance,
    overall_sd
  )
)

View(results)

write.csv(results, "statistics_results.csv", row.names = FALSE)