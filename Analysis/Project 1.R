## 0) Packages
needed <- c("readr","ggplot2","scales","broom","dplyr","stringr","tidyr")
to_install <- setdiff(needed, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)
library(readr); library(ggplot2); library(scales)
library(broom); library(dplyr); library(stringr); library(tidyr)

## 1) Paths 
clean_path <- "~/Documents/Math 261A/Project 1/Clean_Equity_Index_Census_Tracts.csv"
fig_path   <- "~/Documents/Math 261A/Project 1/education_vs_income_model.png"
pred_path  <- "~/Documents/Math 261A/Project 1/tables/predictions.csv"

dir.create(dirname(fig_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(pred_path), recursive = TRUE, showWarnings = FALSE)

## 2) Load cleaned data
df <- read_csv(clean_path, show_col_types = FALSE)

## 2a) Force numeric types (strip $ and commas if any slipped in)
df <- df %>%
  mutate(
    INCMEDIANINCOME = as.numeric(str_replace_all(as.character(INCMEDIANINCOME), "[\\$,]", "")),
    EDULESSTHANHSRATIO = as.numeric(EDULESSTHANHSRATIO)
  ) %>%
  drop_na(INCMEDIANINCOME, EDULESSTHANHSRATIO)

## Quick sanity checks (prints to console)
cat("\nClasses:\n")
print(sapply(df[c("INCMEDIANINCOME","EDULESSTHANHSRATIO")], class))
cat("\nAny NA left?\n")
print(colSums(is.na(df[c("INCMEDIANINCOME","EDULESSTHANHSRATIO")])))

## 3) Fit the model
m <- lm(INCMEDIANINCOME ~ EDULESSTHANHSRATIO, data = df)
print(summary(m))

## 4) Tidy and glance
coef_table <- broom::tidy(m)
glance_row <- broom::glance(m)
print(coef_table); print(glance_row)

## 5) Predictions across range
x_seq <- seq(min(df$EDULESSTHANHSRATIO), max(df$EDULESSTHANHSRATIO), length.out = 100)
newdat <- data.frame(EDULESSTHANHSRATIO = x_seq)
pred_ci <- predict(m, newdata = newdat, interval = "confidence")
pred_pi <- predict(m, newdata = newdat, interval = "prediction")

pred_df <- newdat %>%
  mutate(
    fit    = pred_ci[,"fit"],
    lwr_ci = pred_ci[,"lwr"],
    upr_ci = pred_ci[,"upr"],
    lwr_pi = pred_pi[,"lwr"],
    upr_pi = pred_pi[,"upr"],
    pct_no_hs = 100 * EDULESSTHANHSRATIO
  )
write_csv(pred_df, pred_path)
cat("Saved predictions to:", pred_path, "\n")

## 6) Helper for point predictions
predict_income <- function(percent_without_hs) {
  nd <- data.frame(EDULESSTHANHSRATIO = percent_without_hs / 100)
  out_ci <- predict(m, nd, interval = "confidence")
  out_pi <- predict(m, nd, interval = "prediction")
  data.frame(
    percent_without_hs = percent_without_hs,
    fit   = out_ci[,"fit"],
    lwrCI = out_ci[,"lwr"],
    uprCI = out_ci[,"upr"],
    lwrPI = out_pi[,"lwr"],
    uprPI = out_pi[,"upr"]
  )
}
print(rbind(predict_income(5), predict_income(10), predict_income(20)))

## 7) Plot with explicit y breaks & labels (avoids NA labels)
ybreaks <- scales::pretty_breaks(n = 6)
dollar_lab <- function(b) paste0("$", formatC(b, format = "f", digits = 0, big.mark = ","))

p <- ggplot(df, aes(x = EDULESSTHANHSRATIO, y = INCMEDIANINCOME)) +
  geom_point(alpha = 0.75) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1, color = "blue") +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  scale_y_continuous(breaks = ybreaks, labels = dollar_lab) +
  labs(
    title = "Education vs. Income in Santa Clara County",
    subtitle = "Median household income predicted by % of adults without a high school diploma",
    x = "Percent without High School Education",
    y = "Median Household Income"
  ) +
  theme_minimal(base_size = 13)

print(p)
ggsave(fig_path, p, width = 7, height = 5, dpi = 300)
cat("Saved figure to:", fig_path, "\n")




#####################################################
#####################################################
#####################################################


# Save a tidy coefficient table (report-ready)
dir.create("~/Documents/Math 261A/Project 1/tables", showWarnings = FALSE, recursive = TRUE)

coef_out <- broom::tidy(m) |>
  mutate(
    term = recode(term,
                  "(Intercept)" = "Intercept",
                  "EDULESSTHANHSRATIO" = "Percent without High School (ratio)"),
    estimate = round(estimate, 0),
    std.error = round(std.error, 0),
    statistic = round(statistic, 2),
    p.value = signif(p.value, 3)
  )

readr::write_csv(coef_out, "~/Documents/Math 261A/Project 1/tables/regression_results_table.csv")

# Quick console summary line for the paper
slope_pp <- coef(m)[["EDULESSTHANHSRATIO"]] * 0.01
cat(sprintf("\nEffect per +1 percentage point: %s\n", scales::dollar(slope_pp)))
cat(sprintf("R-squared: %.3f | Adj R-squared: %.3f\n\n",
            summary(m)$r.squared, summary(m)$adj.r.squared))


#####################################################


