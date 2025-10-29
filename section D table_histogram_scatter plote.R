# Load packages
library(readr)
library(ggplot2)
library(dplyr)
library(scales)
library(knitr)

## 2) Load data (use file picker so you don’t worry about paths)
#    Click your "Equity_Index_Census_Tracts.csv" when prompted.
dat <- read_csv(file.choose(), show_col_types = FALSE)

# Keep only needed variables
df <- dat %>%
  select(INCMEDIANINCOME, EDULESSTHANHSRATIO) %>%
  na.omit()

# ---- 1) Summary table ----
summary_table <- df %>%
  summarise(
    Mean_Income = round(mean(INCMEDIANINCOME), 0),
    Median_Income = round(median(INCMEDIANINCOME), 0),
    Min_Income = min(INCMEDIANINCOME),
    Max_Income = max(INCMEDIANINCOME),
    Mean_NoHS = round(mean(EDULESSTHANHSRATIO) * 100, 1),
    Median_NoHS = round(median(EDULESSTHANHSRATIO) * 100, 1),
    Min_NoHS = round(min(EDULESSTHANHSRATIO) * 100, 1),
    Max_NoHS = round(max(EDULESSTHANHSRATIO) * 100, 1)
  )

kable(summary_table, caption = "Table 1. Summary statistics for income and education variables.")



###### ---- 2) Histograms ----

# Histogram of Median Household Income
ggplot(df, aes(x = INCMEDIANINCOME)) +
  geom_histogram(binwidth = 10000, fill = "skyblue", color = "black") +
  scale_x_continuous(labels = dollar_format()) +
  labs(
    title = "Distribution of Median Household Income",
    x = "Median Household Income",
    y = "Number of Census Tracts"
  ) +
  theme_minimal()

# Histogram of % without HS Education
ggplot(df, aes(x = EDULESSTHANHSRATIO)) +
  geom_histogram(binwidth = 0.02, fill = "salmon", color = "black") +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Distribution of Adults Without High School Education",
    x = "Percent without High School Education",
    y = "Number of Census Tracts"
  ) +
  theme_minimal()




###### ---- 3) Scatterplot (Descriptive) ----
ggplot(df, aes(x = EDULESSTHANHSRATIO, y = INCMEDIANINCOME)) +
  geom_point(alpha = 0.6) +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Scatterplot of Education vs. Income",
    x = "Percent without High School Education",
    y = "Median Household Income"
  ) +
  theme_minimal()

